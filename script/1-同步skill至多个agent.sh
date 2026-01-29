#!/bin/bash
#* ============================================================================
#* 同步 S2-Agent-Skill 到多个 Agent 的 skills 目录
#* ============================================================================

#* ============================================================================
#* 配置区开始
#* ============================================================================

SOURCE_DIR="/mnt/f/onedrive/文档（科研）/脚本/Download/S2-Agent-Skill/skills" #! 将此路径替换为你的 S2-Agent-Skill skills 目录路径

#! codex的路径一般在 ~/.codex/skills/.system,若没有可以mkdir -p 创建
#! claude的路径一般在 ~/.claude/skills/,若没有可以mkdir -p 创建
TARGET_DIRS=(
    "/home/luolintao/.codex/skills/.system"
    "/home/luolintao/.claude/skills/"
    # "/home/luolintao/.cursor/skills/.system"
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
