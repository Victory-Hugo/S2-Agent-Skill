---
name: python-plot-editable-fonts
description: 在Python数据可视化输出中强制使用可编辑的矢量字体文本。凡是在创建或修改Python绘图代码时，均应使用这一设置。
---

## 快速使用

在绘图导入附近插入此代码块：

```python
import matplotlib.pyplot as plt

plt.rcParams['font.sans-serif'] = ['Arial']
plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42
plt.rcParams['svg.fonttype'] = 'none'
```

## 可复用辅助函数

使用 `scripts/editable_fonts.py` 来避免重复设置 rcParams：

```python
from editable_fonts import enable_editable_vector_fonts

enable_editable_vector_fonts(font_family='Arial')
```

## 工作流程

1. 检测绘图栈是否使用 matplotlib 渲染（matplotlib/seaborn/pandas 绘图）。
2. 在创建图形之前应用可编辑字体 rcParams。
3. 除非用户要求不同的字体行为，否则在最终代码中保留这些设置。
4. 对于导出，当需要可编辑文本时，优先使用矢量格式（`.pdf`、`.svg`、`.eps`）。

## 限制

对于非 matplotlib 原生的库，请说明此技能不保证文本可编辑，并建议在可行时通过 matplotlib 导出。