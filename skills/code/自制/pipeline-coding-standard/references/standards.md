# Pipeline Coding Standard Reference

## 目录职责

| 目录 | 职责 | 允许内容 | 禁止内容 |
| --- | --- | --- | --- |
| `conf/` | 统一配置入口 | `Config.yaml` | 分散的业务配置 |
| `pipe/` | 总控脚本 | 流程编排、建目录、依赖检查、模块调用 | 业务算法实现 |
| `script/` | 辅助脚本 | 环境检查、轻量包装脚本 | Python/R/C++ 业务逻辑 |
| `python/` | Python 模块 | `.py` 脚本或模块 | 其他语言 |
| `src/` | 非 Python 模块 | R、C++、其他语言模块 | Python 主模块 |

## 总控脚本职责边界

总控脚本负责以下工作：

1. 定位项目根目录和 `conf/Config.yaml`
2. 检查依赖是否存在
3. 创建输出目录
4. 解析配置
5. 调用模块
6. 汇总日志或状态

总控脚本不负责以下工作：

1. 承载业务算法实现
2. 在文件内嵌入 Python 或 R 逻辑
3. 直接写死绝对路径和业务参数

## 正例

### 总控脚本调用模块

```bash
python3 python/example_step.py \
  --input "$INPUT_DIR" \
  --output "$OUTPUT_FILE" \
  --ref "$REFERENCE" \
  --jobs "$JOBS"
```

这个模式符合要求，因为：

- 流程控制位于 `pipe/run_pipeline.sh`
- 模块逻辑位于 `python/example_step.py`
- 参数由总控显式下发
- 路径和线程数来自配置

### 配置集中管理

所有路径、阈值、线程数都来自 `conf/Config.yaml`，或由总控脚本在命令行中明确传递。模板默认使用可 `source` 的 shell 加载器解析简单 YAML 子集，不依赖第三方 Python 包。

支持范围仅限：

- 顶层 section 加二级 key 的嵌套映射
- 标量值
- 两空格缩进
- 行尾注释

## 反例

### 反例 1：在 bash 中嵌入 Python heredoc

```bash
python3 <<'EOF'
import os
print(os.listdir("/mnt/data"))
EOF
```

这违反了单文件单语言规则。应改为独立 Python 文件并由 shell 调用。

### 反例 2：模块内硬编码绝对路径

```python
REFERENCE = "/mnt/g/project/reference.fa"
OUTPUT = "C:\\work\\result.txt"
```

这违反了模块禁止硬编码规则。应改为：

```python
parser.add_argument("--ref", required=True)
parser.add_argument("--output", required=True)
```

## 模块接口建议

### Python

使用 `argparse`。模块入口应显式声明参数，不从环境变量或全局状态隐式读取业务参数。

### R

使用 `commandArgs(trailingOnly = TRUE)` 或明确的 CLI 参数解析器。不要在脚本内写死输入输出路径。

### C++

使用 `argc/argv` 或明确的 CLI 参数解析器。不要把文件路径和线程数编译进代码。

## 推荐重构流程

1. 识别现有脚本中的路径、阈值、线程数和工具位置
2. 把这些配置迁移到 `conf/Config.yaml`
3. 把流程控制保留在 `pipe/`
4. 把每一步业务逻辑迁移到 `python/` 或 `src/`
5. 用命名 CLI 参数替代模块内常量
6. 删除跨语言 here-doc 和其他混写模式

## 模板说明

`assets/project-template/` 提供了最小工程模板：

```text
project-template/
- conf/Config.yaml
- pipe/run_pipeline.sh
- script/check_env.sh
- script/load_config.sh
- python/example_step.py
- src/.keep
```

使用初始化脚本复制模板：

```bash
bash scripts/init_pipeline_layout.sh /path/to/new-project
```
