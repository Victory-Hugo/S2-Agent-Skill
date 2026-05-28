# Essential References

本文件只保留运行本 skill 所需的极简参考说明。

## 可编辑字体

目标是让 PDF 和 SVG 中的文字保持为可编辑文本，而不是路径或轮廓。

Python 默认设置：

```python
plt.rcParams["pdf.fonttype"] = 42
plt.rcParams["ps.fonttype"] = 42
plt.rcParams["svg.fonttype"] = "none"
```

R 默认使用 `ggsave()`。需要更稳定的 PDF 字体输出时，使用 `device = cairo_pdf`。

## 默认字体

所有图中文字默认使用 Arial，字号默认 6 pt。

若系统缺少 Arial，应说明这一点，并在正式图件中尽量恢复 Arial。

## 默认导出

优先导出 PDF。

需要继续编辑时可导出 SVG。

PNG 仅作为预览或辅助文件。

不要使用 JPEG 保存科研图。

## 默认绘图库

R：ggplot2。

Python：Matplotlib 和 Seaborn。

不要使用 Plotly。
