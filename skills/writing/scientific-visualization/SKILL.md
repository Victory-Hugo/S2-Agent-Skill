---
name: scientific-visualization
description: 用于生成、修改和审查科研图件的技能，适用于论文出版图、汇报图、展示图和探索性分析图。
---

# 总体原则
图件必须清楚、克制、可复现、可编辑。

# 默认绘图语言和库
若用户没有指定语言，**优先使用 R 绘图**。
绘图默认使用 ggplot2。
R 主题统一使用 theme_classic()。
Python 仅保留 Matplotlib 和 Seaborn。
不要主动引入复杂依赖。
若使用 Python，默认使用 aquarel 的 boxy_light 主题。
若环境缺少 aquarel，应提示安装：pip install aquarel。
# 文字语言规则
默认情况下，图中所有文字必须使用英文。
包括标题、坐标轴、图例、分组标签、注释、分面标签和统计标注。
除非用户明确要求中文，否则图中不准出现中文。
代码注释和解释可以使用中文，但图中文字不应使用中文。
英文标签使用简洁表达。
单位写在英文括号中，例如 Distance (km)。
避免全大写标签，除非是基因名、缩写或期刊要求。
# 字体规则
所有图中文字默认使用 Arial。
所有图中文字默认字号为 6 pt。
坐标轴标题、刻度文字、图例文字、注释文字和分面标签默认都使用 6 pt。
除非用户或期刊明确要求，不要自行放大或缩小不同元素。
字体必须在导出的矢量文件中保持可编辑。
不要把文字转成路径、轮廓或不可编辑对象。
不要使用会导致文字转曲的导出方式。
若 Arial 不可用，应明确说明，并使用最接近的无衬线字体临时代替。
正式交付前应尽量恢复 Arial。
# Python 默认设置
使用 Python 绘图时，采用以下最小配置。
```python
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from aquarel import load_theme

# Install with: pip install aquarel
# sns.set_style("white")
theme = load_theme("boxy_light")
theme.apply()

plt.rcParams["font.sans-serif"] = ["Arial"]
plt.rcParams["font.size"] = 6
plt.rcParams["axes.labelsize"] = 6
plt.rcParams["xtick.labelsize"] = 6
plt.rcParams["ytick.labelsize"] = 6
plt.rcParams["legend.fontsize"] = 6
plt.rcParams["pdf.fonttype"] = 42
plt.rcParams["ps.fonttype"] = 42
plt.rcParams["svg.fonttype"] = "none"
```
pdf.fonttype = 42 和 ps.fonttype = 42 用于保留可编辑 TrueType 字体。
svg.fonttype = "none" 用于让 SVG 中的文字保持为文本。
保存 PDF 或 SVG 后，应检查文字是否可以在 Illustrator、Inkscape 或类似软件中编辑。
完整模板位于 templates/python_minimal_template.py。
# R 默认设置
使用 R 绘图时，默认使用 ggplot2。
默认主题为 theme_classic(base_family = "Arial", base_size = 6)。
所有文字元素继承 6 pt 和 Arial。
若额外设置 theme，必须保持 Arial、6 pt 和可编辑字体。
默认使用 ggsave() 导出图件。
若需要保证 PDF 字体可编辑，优先使用 device = cairo_pdf。
不要默认使用 showtext 将字体转为轮廓。
不要默认使用会让文字不可编辑的位图导出方式作为唯一结果。
完整模板位于 templates/r_minimal_template.R。
# 配色规则
本 skill 不强制规定配色方案。
若用户指定配色，应遵守用户指定。
若其他 skill 已指定配色，应遵守其他 skill 的配色规则。
# 图形选择
根据数据类型选择图形。
连续变量之间的关系优先考虑散点图、回归图或二维密度图。
时间序列优先考虑线图。
分组连续值优先考虑箱线图、小提琴图、点图或均值误差图。
组成比例可以使用堆叠柱图，但避免过多类别。
相关矩阵、距离矩阵和表达矩阵可以使用热图。
样本量较小时，优先显示原始点。
样本量较大时，可使用透明度、密度或汇总统计。
不要只显示柱状图而隐藏原始数据，除非用户明确要求。
# 坐标轴和标签
坐标轴必须有明确英文标签。
有单位的变量必须标注单位。
不要使用过密刻度。
不要让刻度标签相互重叠。
标签只能为 90° 或 0°，除非用户明确要求。
# 图例、注释和统计标注
图例应简洁，且不能遮挡数据。
若直接标注曲线或分组更清楚，可以省略图例。
注释只用于解释必要信息，不要在图中堆叠长段文字。
统计显著性标注必须基于实际统计结果。
# 多面板图
多面板图必须保持统一字体、字号、线宽、点大小和标签风格。
面板标签使用英文大写字母：A, B, C。
面板标签默认使用 Arial、6 pt、加粗。
# 导出规则
默认导出为 PDF + 配套 PNG。
PNG 不能作为唯一正式交付格式，除非用户明确要求。
Python 默认使用 bbox_inches = "tight"。
R 默认使用 ggsave()。
导出后应检查字体、裁切、图例、分辨率和文字可编辑性。
# 交付前检查
图中文字是否全部为英文。
字体是否为 Arial。
字号是否为 6 pt。
PDF 或 SVG 中字体是否可编辑。
坐标轴和单位是否清楚。
图例是否必要且不遮挡数据。
多面板风格是否一致。
是否避免了 JPEG。
是否输出了可继续编辑的矢量文件。
是否没有强行套用配色。
是否没有添加未经计算的统计标注。
# 文件结构
本精简版 skill 只保留少量文件。
SKILL.md 是主要规则文件。
templates/python_minimal_template.py 是 Python 最小模板。
templates/r_minimal_template.R 是 R 最小模板。
references/essential_references.md 只保留必要参考说明。
优先维护 SKILL.md，不要扩展出大量参考文件。