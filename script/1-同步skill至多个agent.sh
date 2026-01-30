#!/bin/bash
#* ============================================================================
#* 同步 S2-Agent-Skill 到多个 Agent 的 skills 目录
#* ============================================================================

#* ============================================================================
#* 配置区开始
#* ============================================================================

SOURCE_DIR="/mnt/f/onedrive/文档（科研）/脚本/Download/S2-Agent-Skill/skills" #! 将此路径替换为你的 S2-Agent-Skill skills 目录路径

#! codex的路径一般在 ~/.codex/skills/,若没有可以mkdir -p 创建
#! claude的路径一般在 ~/.claude/skills/,若没有可以mkdir -p 创建
TARGET_DIRS=(
    "/home/luolintao/.codex/skills/"
    "/home/luolintao/.claude/skills/"
    # "/home/luolintao/.cursor/skills/"
    # 可以添加更多目标目录，例如：
)
#* ============================================================================
#* 配置区结束
#* ============================================================================
# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================"
echo "  S2-Agent-Skill 同步脚本"
echo "============================================"
echo ""

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}错误: 源目录不存在: $SOURCE_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}源目录: $SOURCE_DIR${NC}"
echo ""

# 全局重复检测：在处理任何目标目录之前先检测所有重复
echo "=========================================="
echo -e "${YELLOW}全局检查重复的 skill name...${NC}"
declare -A GLOBAL_SKILL_NAMES=()
declare -a GLOBAL_DUPLICATE_SKILLS=()

while IFS= read -r -d '' SKILL_FILE; do
    # 提取SKILL.md中的name字段
    SKILL_NAME=$(awk '/^name:/ {gsub(/^name: */, ""); print; exit}' "$SKILL_FILE" 2>/dev/null)
    
    if [ -n "$SKILL_NAME" ]; then
        if [[ -n "${GLOBAL_SKILL_NAMES[$SKILL_NAME]}" ]]; then
            # 发现重复
            if [[ ! " ${GLOBAL_DUPLICATE_SKILLS[@]} " =~ " $SKILL_NAME " ]]; then
                GLOBAL_DUPLICATE_SKILLS+=("$SKILL_NAME")
                echo -e "${RED}警告: 发现重复的 skill name '$SKILL_NAME'${NC}"
                echo -e "${RED}  第一个位置: ${GLOBAL_SKILL_NAMES[$SKILL_NAME]}${NC}"
            fi
            echo -e "${RED}  重复位置: $SKILL_FILE${NC}"
        else
            GLOBAL_SKILL_NAMES["$SKILL_NAME"]="$SKILL_FILE"
        fi
    fi
done < <(find "$SOURCE_DIR" -type f -name "SKILL.md" -print0)

# 如果发现重复，询问是否继续
if [ ${#GLOBAL_DUPLICATE_SKILLS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}发现 ${#GLOBAL_DUPLICATE_SKILLS[@]} 个重复的 skill name。${NC}"
    echo -e "${YELLOW}重复的名称: ${GLOBAL_DUPLICATE_SKILLS[*]}${NC}"
    echo ""
    read -p "是否继续同步到所有目标目录？(y/N): " CONTINUE_CHOICE
    if [[ ! "$CONTINUE_CHOICE" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}已取消所有同步操作${NC}"
        exit 0
    fi
    echo ""
else
    echo -e "${GREEN}✓ 未发现重复的 skill name${NC}"
fi

echo "=========================================="
echo ""

# 遍历所有目标目录
for TARGET_DIR in "${TARGET_DIRS[@]}"; do
    echo "----------------------------------------"
    # 标准化目标路径，避免以 / 结尾导致 ln -s 报错
    if [[ "$TARGET_DIR" != "/" ]]; then
        TARGET_DIR="${TARGET_DIR%/}"
    fi
    echo -e "${YELLOW}处理目标: $TARGET_DIR${NC}"
    
    # 确保目标父目录存在
    TARGET_PARENT=$(dirname "$TARGET_DIR")
    if [ ! -d "$TARGET_PARENT" ]; then
        echo -e "${YELLOW}创建父目录: $TARGET_PARENT${NC}"
        mkdir -p "$TARGET_PARENT"
    fi
    
    # 如果目标已存在，先删除
    if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
        echo -e "${YELLOW}删除已存在的目标: $TARGET_DIR${NC}"
        rm -rf "$TARGET_DIR"
    fi
    
    # 创建扁平化目录，并为每个 SKILL.md 的父目录创建软链接
    mkdir -p "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ 创建目标目录失败: $TARGET_DIR${NC}"
        continue
    fi

    # 记录已使用的名称，避免重名覆盖
    declare -A USED_NAMES=()
    FOUND_COUNT=0

    # 创建软链接
    while IFS= read -r -d '' SKILL_FILE; do
        SKILL_DIR=$(dirname "$SKILL_FILE")
        LINK_NAME=$(basename "$SKILL_DIR")

        if [[ -n "${USED_NAMES[$LINK_NAME]}" ]]; then
            REL_PATH="${SKILL_DIR#"$SOURCE_DIR"/}"
            LINK_NAME="${REL_PATH//\//__}"
        fi

        USED_NAMES["$LINK_NAME"]=1
        ln -s "$SKILL_DIR" "$TARGET_DIR/$LINK_NAME"
        if [ $? -eq 0 ]; then
            FOUND_COUNT=$((FOUND_COUNT + 1))
        else
            echo -e "${RED}✗ 创建软链接失败: $TARGET_DIR/$LINK_NAME${NC}"
        fi
    done < <(find "$SOURCE_DIR" -type f -name "SKILL.md" -print0)

    if [ $FOUND_COUNT -gt 0 ]; then
        echo -e "${GREEN}✓ 已同步并扁平化: $TARGET_DIR (技能数: $FOUND_COUNT)${NC}"
    else
        echo -e "${YELLOW}未发现任何 SKILL.md: $SOURCE_DIR${NC}"
    fi
done

echo ""
echo "----------------------------------------"
echo -e "${GREEN}同步完成！${NC}"
echo ""

# 显示同步映射表
echo "=========================================="
echo -e "${GREEN}同步映射表${NC}"
echo "=========================================="

# 遍历所有目标目录，显示映射关系
for TARGET_DIR in "${TARGET_DIRS[@]}"; do
    # 标准化目标路径
    if [[ "$TARGET_DIR" != "/" ]]; then
        TARGET_DIR="${TARGET_DIR%/}"
    fi
    
    if [ -d "$TARGET_DIR" ]; then
        echo ""
        echo -e "${YELLOW}目标目录: $TARGET_DIR${NC}"
        echo "----------------------------------------"
        
        # 获取所有软链接并排序
        LINKS=$(find "$TARGET_DIR" -maxdepth 1 -type l | sort)
        
        if [ -n "$LINKS" ]; then
            # 计算最大长度用于对齐
            MAX_SOURCE_LEN=0
            MAX_TARGET_LEN=0
            
            # 创建临时数组存储映射关系
            declare -a MAPPING_ARRAY=()
            
            while IFS= read -r LINK; do
                if [ -n "$LINK" ]; then
                    SOURCE_PATH=$(readlink "$LINK")
                    LINK_NAME=$(basename "$LINK")
                    
                    # 存储映射关系
                    MAPPING_ARRAY+=("$SOURCE_PATH|$LINK_NAME")
                    
                    SOURCE_LEN=${#SOURCE_PATH}
                    TARGET_LEN=${#LINK_NAME}
                    
                    if [ $SOURCE_LEN -gt $MAX_SOURCE_LEN ]; then
                        MAX_SOURCE_LEN=$SOURCE_LEN
                    fi
                    if [ $TARGET_LEN -gt $MAX_TARGET_LEN ]; then
                        MAX_TARGET_LEN=$TARGET_LEN
                    fi
                fi
            done <<< "$LINKS"
            
            # 设置最小列宽和表头长度
            HEADER1="原地址"
            HEADER2="软链接名称"
            HEADER1_LEN=${#HEADER1}
            HEADER2_LEN=${#HEADER2}
            
            if [ $MAX_SOURCE_LEN -lt $HEADER1_LEN ]; then
                MAX_SOURCE_LEN=$HEADER1_LEN
            fi
            if [ $MAX_TARGET_LEN -lt $HEADER2_LEN ]; then
                MAX_TARGET_LEN=$HEADER2_LEN
            fi
            
            # 打印表头
            printf "%-${MAX_SOURCE_LEN}s   →   %-${MAX_TARGET_LEN}s\n" "$HEADER1" "$HEADER2"
            
            # 打印分隔线
            SEPARATOR1=$(printf '%*s' $MAX_SOURCE_LEN '' | tr ' ' '-')
            SEPARATOR2=$(printf '%*s' $MAX_TARGET_LEN '' | tr ' ' '-')
            printf "%s   →   %s\n" "$SEPARATOR1" "$SEPARATOR2"
            
            # 打印映射关系
            for MAPPING in "${MAPPING_ARRAY[@]}"; do
                SOURCE_PATH="${MAPPING%|*}"
                LINK_NAME="${MAPPING#*|}"
                printf "%-${MAX_SOURCE_LEN}s   →   %-${MAX_TARGET_LEN}s\n" "$SOURCE_PATH" "$LINK_NAME"
            done
            
            LINK_COUNT=${#MAPPING_ARRAY[@]}
            echo ""
            echo -e "${GREEN}共 $LINK_COUNT 个软链接${NC}"
        else
            echo -e "${YELLOW}无软链接${NC}"
        fi
    else
        echo ""
        echo -e "${RED}目标目录不存在: $TARGET_DIR${NC}"
    fi
done

echo ""
echo "=========================================="

# 显示当前链接状态
echo "当前链接状态："
for TARGET_DIR in "${TARGET_DIRS[@]}"; do
    # 标准化目标路径，避免以 / 结尾导致状态检测偏差
    if [[ "$TARGET_DIR" != "/" ]]; then
        TARGET_DIR="${TARGET_DIR%/}"
    fi
    if [ -L "$TARGET_DIR" ]; then
        LINK_TARGET=$(readlink -f "$TARGET_DIR")
        echo -e "  ${GREEN}$TARGET_DIR${NC} -> $LINK_TARGET"
    elif [ -d "$TARGET_DIR" ]; then
        COUNT=$(find "$TARGET_DIR" -maxdepth 1 -type l | wc -l | tr -d ' ')
        echo -e "  ${YELLOW}$TARGET_DIR${NC} (目录，非链接，链接数: $COUNT)"
    else
        echo -e "  ${RED}$TARGET_DIR${NC} (不存在)"
    fi
done
