---
name: python-plot-editable-fonts
description: 在Python数据可视化输出中强制使用可编辑的矢量字体文本。凡是在创建或修改Python绘图代码时（matplotlib、seaborn、pandas绘图库），均应使用这一设置，以确保导出的PDF/PS/SVG图像保留可编辑文本状态，避免将字形转换为路径。
---

# Python Plot Editable Fonts

Apply this skill before writing any Python data-visualization code.

## Mandatory Rule

For every Python plotting task, configure editable vector-font settings first, unless the user explicitly asks not to.

## Quick Use

Insert this block near plotting imports:

```python
import matplotlib.pyplot as plt

plt.rcParams['font.sans-serif'] = ['Arial']
plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42
plt.rcParams['svg.fonttype'] = 'none'
```

## Reusable Helper

Use `scripts/editable_fonts.py` to avoid repeating rcParams setup:

```python
from editable_fonts import enable_editable_vector_fonts

enable_editable_vector_fonts(font_family='Arial')
```

## Workflow

1. Detect whether the plotting stack uses matplotlib rendering (matplotlib/seaborn/pandas plotting).
2. Apply editable-font rcParams before creating figures.
3. Keep these settings in final code unless user requests different font behavior.
4. For exports, prefer vector formats (`.pdf`, `.svg`, `.eps`) when editable text is required.

## Limits

For non-matplotlib-native libraries, state that this skill does not guarantee editable text and suggest exporting through matplotlib when feasible.
