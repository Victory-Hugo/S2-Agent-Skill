#!/bin/bash
#* ============================================================================
#* 为多个 Claude Code 账号建立共享数据软链接
#*
#* 作用：
#*   将 ~/.claude-shared/ 作为共享层，存放所有账号通用的数据。
#*   各账号目录下的对应子目录均为指向共享层的软链接。
#*
#*   共享内容：
#*     memory/   - 个人偏好、记忆（所有账号共用同一份）
#*     skills/   - 自定义技能（由 1-同步skill至多个agent.sh 填充）
#*     projects/ - 对话存档（/resume 跨账号可见的关键）
#*
#*   注意：projects/ 共享后，两账号同时运行时理论上可能写冲突（实际概率极低）。
#*         建议同一时间只用一个账号活跃写入。
#*
#* 使用场景：
#*   - 初次建立共享结构时运行一次
#*   - 新增 claude 账号后运行以接入共享层
#*   - skills 同步仍由 1-同步skill至多个agent.sh 负责，本脚本只管链接结构
#* ============================================================================

#* ============================================================================
#* 配置区开始
#* ============================================================================

SHARED_DIR="/home/luolintao/.claude-shared"

# memory 迁移来源（最完整的那份账号）
MEMORY_SOURCE="/home/luolintao/.claude-account-Biglin/memory"

# 需要建立共享链接的 Claude 账号目录
CLAUDE_ACCOUNTS=(
    "/home/luolintao/.claude"
    "/home/luolintao/.claude-account-Biglin"
    "/home/luolintao/.claude-account-Gianthui"
    # 新增账号在此追加，例如：
    # "/home/luolintao/.claude-account-NewAccount"
)

# 简单共享的子目录（各账号原有数据备份后直接链接到共享层）
SIMPLE_SHARED_SUBDIRS=(
    "memory"
    "skills"
)

# 需要合并后共享的子目录（来自多个账号的数据先合并，再统一链接）
MERGE_SHARED_SUBDIRS=(
    "projects"
)

#* ============================================================================
#* 配置区结束
#* ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "============================================"
echo "  Claude 共享数据链接建立脚本"
echo "============================================"
echo ""

# ── Step 1：建立共享目录结构 ──────────────────────────────────────────────────
echo -e "${CYAN}[Step 1] 建立共享目录: $SHARED_DIR${NC}"
ALL_SUBDIRS=("${SIMPLE_SHARED_SUBDIRS[@]}" "${MERGE_SHARED_SUBDIRS[@]}")
for SUBDIR in "${ALL_SUBDIRS[@]}"; do
    TARGET="$SHARED_DIR/$SUBDIR"
    if [ -d "$TARGET" ]; then
        echo -e "  ${GREEN}✓ 已存在: $TARGET${NC}"
    else
        mkdir -p "$TARGET"
        echo -e "  ${GREEN}✓ 已创建: $TARGET${NC}"
    fi
done
echo ""

# ── Step 2：迁移 memory（仅当共享 memory 为空时从 Biglin 迁移）───────────────
echo -e "${CYAN}[Step 2] 迁移 memory 数据${NC}"
SHARED_MEMORY="$SHARED_DIR/memory"

if [ -z "$(ls -A "$SHARED_MEMORY" 2>/dev/null)" ]; then
    if [ -d "$MEMORY_SOURCE" ] && [ ! -L "$MEMORY_SOURCE" ]; then
        echo -e "  从 $MEMORY_SOURCE 迁移数据..."
        cp -r "$MEMORY_SOURCE/." "$SHARED_MEMORY/"
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓ memory 迁移完成 ($(ls "$SHARED_MEMORY" | wc -l) 个文件)${NC}"
        else
            echo -e "  ${RED}✗ memory 迁移失败，请手动检查${NC}"
            exit 1
        fi
    elif [ -L "$MEMORY_SOURCE" ]; then
        echo -e "  ${YELLOW}来源已是软链接，跳过迁移（共享 memory 为空，请手动放入数据）${NC}"
    else
        echo -e "  ${YELLOW}来源目录不存在: $MEMORY_SOURCE，跳过迁移${NC}"
    fi
else
    COUNT=$(ls "$SHARED_MEMORY" | wc -l)
    echo -e "  ${GREEN}✓ 共享 memory 已有数据 ($COUNT 个文件)，跳过迁移${NC}"
fi
echo ""

# ── Step 3：合并 projects（从所有账号 rsync 至共享层，UUID 不冲突）────────────
echo -e "${CYAN}[Step 3] 合并 projects 对话存档${NC}"
SHARED_PROJECTS="$SHARED_DIR/projects"
PROJECTS_ALREADY_POPULATED=false

if [ -n "$(ls -A "$SHARED_PROJECTS" 2>/dev/null)" ]; then
    COUNT=$(find "$SHARED_PROJECTS" -mindepth 1 -maxdepth 1 -type d | wc -l)
    echo -e "  ${GREEN}✓ 共享 projects 已有数据 ($COUNT 个项目目录)，执行增量合并${NC}"
    PROJECTS_ALREADY_POPULATED=true
fi

for ACCOUNT_DIR in "${CLAUDE_ACCOUNTS[@]}"; do
    SRC_PROJECTS="$ACCOUNT_DIR/projects"
    # 跳过不存在的目录、以及已经是软链接的目录（说明已完成链接）
    if [ ! -d "$SRC_PROJECTS" ] || [ -L "$SRC_PROJECTS" ]; then
        continue
    fi
    echo -e "  合并: $SRC_PROJECTS → $SHARED_PROJECTS"
    rsync -a --ignore-existing "$SRC_PROJECTS/" "$SHARED_PROJECTS/"
    if [ $? -eq 0 ]; then
        PROJECT_COUNT=$(find "$SRC_PROJECTS" -mindepth 1 -maxdepth 1 -type d | wc -l)
        echo -e "  ${GREEN}✓ 合并完成 ($PROJECT_COUNT 个项目目录)${NC}"
    else
        echo -e "  ${RED}✗ 合并失败: $SRC_PROJECTS，请手动检查${NC}"
    fi
done

TOTAL=$(find "$SHARED_PROJECTS" -mindepth 1 -maxdepth 1 -type d | wc -l)
echo -e "  ${GREEN}共享 projects 共 $TOTAL 个项目目录${NC}"
echo ""

# ── Step 4：为每个账号建立软链接（简单共享 + 合并共享统一处理）───────────────
echo -e "${CYAN}[Step 4] 为各账号建立软链接${NC}"

_link_subdir() {
    local ACCOUNT_DIR="$1"
    local SUBDIR="$2"
    local LINK_PATH="$ACCOUNT_DIR/$SUBDIR"
    local LINK_TARGET="$SHARED_DIR/$SUBDIR"

    # 已经是指向正确目标的软链接
    if [ -L "$LINK_PATH" ] && [ "$(readlink -f "$LINK_PATH")" = "$(readlink -f "$LINK_TARGET")" ]; then
        echo -e "  ${GREEN}✓ $SUBDIR/ 已正确链接${NC}"
        return
    fi

    # 是软链接但指向错误目标
    if [ -L "$LINK_PATH" ]; then
        OLD_TARGET=$(readlink "$LINK_PATH")
        echo -e "  ${YELLOW}$SUBDIR/ 软链接目标不正确 ($OLD_TARGET)，重建...${NC}"
        rm "$LINK_PATH"
    # 是普通目录
    elif [ -d "$LINK_PATH" ]; then
        # Biglin 的 memory 已在 Step 2 迁移，可以安全删除原目录
        if [ "$LINK_PATH" = "$MEMORY_SOURCE" ] && [ "$SUBDIR" = "memory" ]; then
            echo -e "  ${YELLOW}$SUBDIR/ 是已迁移的来源目录，替换为软链接...${NC}"
            rm -rf "$LINK_PATH"
        # projects 已在 Step 3 合并，可以安全删除原目录
        elif [ "$SUBDIR" = "projects" ]; then
            echo -e "  ${YELLOW}$SUBDIR/ 已合并至共享层，替换为软链接...${NC}"
            rm -rf "$LINK_PATH"
        else
            BACKUP_PATH="${LINK_PATH}.bak.$(date +%Y%m%d%H%M%S)"
            echo -e "  ${YELLOW}$SUBDIR/ 已存在实体目录，备份为 $(basename "$BACKUP_PATH")...${NC}"
            mv "$LINK_PATH" "$BACKUP_PATH"
            echo -e "  ${YELLOW}  备份: $BACKUP_PATH（确认无误后可手动删除）${NC}"
        fi
    fi

    ln -s "$LINK_TARGET" "$LINK_PATH"
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ $SUBDIR/ → $LINK_TARGET${NC}"
    else
        echo -e "  ${RED}✗ 创建软链接失败: $LINK_PATH${NC}"
    fi
}

for ACCOUNT_DIR in "${CLAUDE_ACCOUNTS[@]}"; do
    echo ""
    echo -e "${YELLOW}处理账号: $ACCOUNT_DIR${NC}"

    if [ ! -d "$ACCOUNT_DIR" ]; then
        echo -e "  ${YELLOW}账号目录不存在，跳过${NC}"
        continue
    fi

    for SUBDIR in "${SIMPLE_SHARED_SUBDIRS[@]}"; do
        _link_subdir "$ACCOUNT_DIR" "$SUBDIR"
    done
    for SUBDIR in "${MERGE_SHARED_SUBDIRS[@]}"; do
        _link_subdir "$ACCOUNT_DIR" "$SUBDIR"
    done
done

echo ""
echo "----------------------------------------"

# ── Step 5：验证链接状态 ──────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}[Step 5] 验证链接状态${NC}"
echo ""
printf "  %-48s  %-10s  %s\n" "路径" "类型" "目标"
printf "  %-48s  %-10s  %s\n" "----" "----" "----"

ALL_SHARED=("${SIMPLE_SHARED_SUBDIRS[@]}" "${MERGE_SHARED_SUBDIRS[@]}")
for ACCOUNT_DIR in "${CLAUDE_ACCOUNTS[@]}"; do
    for SUBDIR in "${ALL_SHARED[@]}"; do
        LINK_PATH="$ACCOUNT_DIR/$SUBDIR"
        SHORT_PATH="${LINK_PATH/#\/home\/luolintao\//~/}"

        if [ -L "$LINK_PATH" ]; then
            REAL_TARGET=$(readlink "$LINK_PATH")
            SHORT_TARGET="${REAL_TARGET/#\/home\/luolintao\//~/}"
            printf "  ${GREEN}%-48s${NC}  %-10s  %s\n" "$SHORT_PATH" "symlink" "→ $SHORT_TARGET"
        elif [ -d "$LINK_PATH" ]; then
            printf "  ${YELLOW}%-48s${NC}  %-10s  %s\n" "$SHORT_PATH" "目录" "(未链接!)"
        else
            printf "  ${RED}%-48s${NC}  %-10s  %s\n" "$SHORT_PATH" "不存在" ""
        fi
    done
done

echo ""
echo "============================================"
echo -e "${GREEN}完成！${NC}"
echo ""
echo -e "  共享目录:    ${CYAN}~/.claude-shared/${NC}"
echo -e "  /resume:     任意账号均可看到所有对话"
echo -e "  skills 同步: 继续使用 ${CYAN}1-同步skill至多个agent.sh${NC}"
echo -e ""
echo -e "  ${YELLOW}提示: 同时运行两个账号时避免对同一项目并发写入${NC}"
echo ""
