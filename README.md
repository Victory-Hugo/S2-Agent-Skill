# S2-Agent-Skill

一个用于管理和同步 S2 Agent 技能库的项目。该项目提供了一套预制的技能模块，支持多个 Agent 平台（Codex、Claude 等）的技能同步。

## 项目概述

S2-Agent-Skill 是一个技能库项目，包含多个领域的预制技能模块，可以方便地同步到不同的 Agent 平台的 skills 目录。该项目使用软链接机制实现扁平化的技能组织，避免重名冲突。

## 目录结构

```
S2-Agent-Skill/
├── skills/                 # 技能库主目录
│   ├── databases/         # 数据库相关技能
│   │   ├── clinvar-database/
│   │   ├── ensembl-database/
│   │   ├── gene-database/
│   │   ├── geo-database/
│   │   ├── gwas-database/
│   │   ├── pubmed-database/
│   │   └── uniprot-database/
│   ├── genomics/          # 基因组学相关技能
│   │   ├── anndata/
│   │   ├── biopython/
│   │   ├── gget/
│   │   ├── pydeseq2/
│   │   ├── pysam/
│   │   ├── scanpy/
│   │   ├── scikit-bio/
│   │   └── scvi-tools/
│   ├── pdf/               # PDF 处理技能
│   ├── python-dual-mode/  # Python 双模式技能
│   ├── skill-creator/     # 技能创建工具
│   ├── skill-installer/   # 技能安装工具
│   ├── writing/           # 写作相关技能
│   └── xlsx/              # Excel 处理技能
├── script/                # 脚本目录
│   └── 1-同步skill至多个agent.sh  # 同步脚本
├── docs/                  # 文档目录
└── LICENSE               # 许可证

```

## 技能分类

- **Databases（数据库）** - 包含多个生物信息学数据库的集成技能
- **Genomics（基因组学）** - 基因组数据分析和处理工具
- **PDF** - PDF 文档处理和表单技能
- **Python Dual Mode** - Python 双模式相关工具
- **Skill Creator** - 用于创建新技能的工具
- **Skill Installer** - 技能安装工具
- **Writing** - 写作辅助技能
- **XLSX** - Excel 文件处理技能

## 快速开始

### 前提条件

- Linux 或 macOS 环境（支持 bash）
- 目标 Agent 的 skills 目录已创建或可自动创建

### 使用同步脚本

#### 1. 配置脚本

编辑 `script/1-同步skill至多个agent.sh` 文件，修改配置区的参数：

```bash
# 设置源目录（通常无需修改）
SOURCE_DIR="/mnt/f/onedrive/文档（科研）/脚本/Download/S2-Agent-Skill/skills"

# 配置目标目录（根据实际情况修改）
TARGET_DIRS=(
    "/home/<用户名>/.codex/skills/.system"      # Codex Agent skills 目录
    "/home/<用户名>/.claude/skills/"             # Claude Agent skills 目录
    # "/home/<用户名>/.cursor/skills/.system"   # Cursor Agent skills 目录（可选）
)
```

**常见目标目录路径：**
- Codex: `~/.codex/skills/.system`
- Claude: `~/.claude/skills/`
- Cursor: `~/.cursor/skills/.system`

#### 2. 运行同步脚本

```bash
bash script/1-同步skill至多个agent.sh
```

脚本执行流程：
1. 检查源目录是否存在
2. 验证目标父目录，不存在则自动创建
3. 清理已存在的目标目录
4. 扫描源目录中所有 `SKILL.md` 文件
5. 为每个技能目录创建软链接（扁平化结构）
6. 处理同名技能，使用路径前缀避免冲突
7. 显示同步结果和当前链接状态

### 脚本工作原理

脚本采用以下机制：

- **扁平化设计** - 将嵌套的技能目录扁平化到目标目录，便于 Agent 快速查找
- **软链接机制** - 使用 `ln -s` 创建软链接，避免磁盘空间浪费
- **重名处理** - 自动检测重名技能，使用相对路径作为前缀（如 `databases__gene-database`）
- **原子操作** - 每次同步时清空并重建目标目录，确保状态一致

## 故障排除

### 问题：创建父目录失败
- **原因** - 路径不正确或没有写入权限
- **解决** - 检查路径是否正确，确保有权限写入该位置

### 问题：创建软链接失败
- **原因** - 目标目录已存在同名文件或权限不足
- **解决** - 脚本会自动删除并重建目录，检查权限设置

### 问题：未发现任何 SKILL.md
- **原因** - 源目录中没有有效的技能模块
- **解决** - 确保源目录路径正确，技能模块包含 `SKILL.md` 文件

## 关键特性

✅ **多平台支持** - 支持 Codex、Claude、Cursor 等多个 Agent 平台

✅ **自动化处理** - 自动创建目录结构、处理重名冲突

✅ **软链接方案** - 节省磁盘空间，更新源目录时自动同步

✅ **详细日志** - 彩色输出显示同步过程和结果状态

✅ **安全操作** - 检查目录存在性，验证操作成功状态

## 许可证

详见 [LICENSE](LICENSE) 文件


