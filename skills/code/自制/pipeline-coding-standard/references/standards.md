# Pipeline Coding Standard Reference

## 目录职责

| 目录 | 职责 | 允许内容 | 禁止内容 |
| --- | --- | --- | --- |
| `conf/` | 统一配置入口 | `Config.yaml` | 分散的业务配置 |
| `pipe/` | 总控脚本 | 流程编排、建目录、依赖检查、模块调用 | 业务算法实现 |
| `script/` | 辅助脚本 | 环境检查、轻量包装脚本 | Python/R/C++ 业务逻辑 |
| `python/` | Python 模块 | `.py` 脚本或模块 | 其他语言 |
| `src/` | 非 Python 模块 | R、C++、其他语言模块 | Python 主模块 |
| `output/` | 结果输出 | 按步骤和结果类型组织的结果文件 | 临时文件、无编号散乱输出 |
| `temp/` | 临时文件 | 按步骤组织的中间文件和缓存 | 最终结果 |

## 文件命名规范

所有承载流程步骤或业务功能的代码文件必须使用数字前缀命名，编号顺序要与流水线执行顺序一致。

推荐模式：

```text
pipe/<主步骤编号>-<module_or_function>.sh
python/<主步骤编号>-<子步骤编号>-<module_or_function>.py
src/<主步骤编号>-<子步骤编号>-<module_or_function>.<ext>
```

正例：

```text
pipe/1-data_preprocessing.sh
python/1-1-data_preprocessing.py
python/1-2-feature_engineering.py
src/2-1-statistical_modeling.R
```

反例：

```text
pipe/run_pipeline.sh
python/example_step.py
python/main.py
```

`script/` 中的非业务辅助工具可以使用描述性名称，例如 `load_config.sh`、`check_env.sh`。如果辅助脚本承载具体业务步骤，也必须使用编号命名。

## 输出目录规范

每个主步骤的输出必须集中到独立步骤目录，并按结果类型拆分：

```text
output/
- 1-data_preprocessing/
  - 1-table/
  - 2-figure/
  - 3-report/
temp/
- 1-data_preprocessing/
```

目录职责：

- `1-table/`：表格、矩阵、统计结果、下游可读数据。
- `2-figure/`：图片、图表、可视化结果。
- `3-report/`：报告、摘要、可读说明文档。
- `temp/<步骤编号>-<步骤名>/`：中间文件、缓存和可删除临时产物。

禁止使用 `output/1/data/`、`output/result/`、`output/tmp/` 这类含义不清或结果类型混杂的目录。

## 总控脚本职责边界

总控脚本负责以下工作：

1. 定位项目根目录和 `conf/Config.yaml`
2. 检查依赖是否存在
3. 创建规范化输出目录和临时目录
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
"$PYTHON_BIN" python/1-1-data_preprocessing.py \
  --input "$INPUT_DIR" \
  --output "$OUTPUT_TABLE" \
  --ref "$REFERENCE" \
  --jobs "$JOBS"
```

这个模式符合要求，因为：

- 流程控制位于 `pipe/1-data_preprocessing.sh`
- 模块逻辑位于 `python/1-1-data_preprocessing.py`
- 参数由总控显式下发
- 路径和线程数来自配置

### 配置集中管理

所有路径、阈值、线程数都来自 `conf/Config.yaml`，或由总控脚本在命令行中明确传递。模板默认使用可 `source` 的 shell 加载器解析简单 YAML 子集，不依赖第三方 Python 包。

支持范围仅限：

- 顶层 section 加二级 key 的嵌套映射
- 标量值
- 两空格缩进
- 行尾注释

推荐按职责拆成以下 section：

- `project`：项目根目录、主输入表等项目级入口
- `paths`：目录路径、步骤输出目录、参考文件
- `tools`：解释器、第三方二进制、conda 相关路径
- `runtime`：线程数、阈值、开关类参数

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
3. 把流程控制保留在 `pipe/`，并按主步骤编号命名
4. 把每一步业务逻辑迁移到 `python/` 或 `src/`，并按主步骤-子步骤编号命名
5. 把输出重组到 `output/<步骤编号>-<步骤名>/{1-table,2-figure,3-report}/`
6. 把临时文件重组到 `temp/<步骤编号>-<步骤名>/`
7. 用命名 CLI 参数替代模块内常量
8. 删除跨语言 here-doc 和其他混写模式

## 模板说明

`assets/project-template/` 提供了最小工程模板：

```text
project-template/
- conf/Config.yaml
- pipe/1-data_preprocessing.sh
- script/check_env.sh
- script/load_config.sh
- python/1-1-data_preprocessing.py
- output/1-data_preprocessing/1-table/
- output/1-data_preprocessing/2-figure/
- output/1-data_preprocessing/3-report/
- temp/1-data_preprocessing/
- src/.keep
```

使用初始化脚本复制模板：

```bash
bash scripts/init_pipeline_layout.sh /path/to/new-project
```
