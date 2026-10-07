# Python 可视化示例

## 离散色板辅助函数

```python
from matplotlib.colors import to_rgb, to_hex

DISCRETE_1 = ["#0072b2", "#56b4e9", "#009e73", "#f0e442", "#e69f00", "#d55e00"]
DISCRETE_2 = ["#8ecae6", "#219ebc", "#023047", "#ffb703", "#fb8500"]


def interpolate_hex(colors: list[str], n: int) -> list[str]:
    if n <= len(colors):
        return colors[:n]
    anchors = [to_rgb(c) for c in colors]
    positions = [i / (len(anchors) - 1) for i in range(len(anchors))]
    out = []
    for i in range(n):
        x = i / (n - 1)
        for left in range(len(positions) - 1):
            if positions[left] <= x <= positions[left + 1]:
                span = positions[left + 1] - positions[left]
                t = 0.0 if span == 0 else (x - positions[left]) / span
                rgb = tuple(
                    anchors[left][k] + t * (anchors[left + 1][k] - anchors[left][k])
                    for k in range(3)
                )
                out.append(to_hex(rgb))
                break
    return out


def categorical_palette(n: int) -> list[str]:
    if n <= 6:
        return DISCRETE_1[:n]
    if n <= 11:
        return DISCRETE_1 + DISCRETE_2[: n - 6]
    anchor = DISCRETE_1 + DISCRETE_2
    print("Warning: more than 11 categories reduce color discrimination.")
    return interpolate_hex(anchor, n)
```

## matplotlib 或 seaborn 分类图

```python
import seaborn as sns
import matplotlib.pyplot as plt

palette = categorical_palette(4)
ax = sns.boxplot(data=df, x="group", y="value", palette=palette)
ax.set_title("显式使用 code-visualization-palette 生成的颜色")
plt.show()
```

## matplotlib 连续热图

```python
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt

sequential = [
    "#0b0405", "#30203e", "#3e4d93", "#366b9f", "#3488a6",
    "#36a4ab", "#49c1ad", "#60ceac", "#84d8b0", "#c4e9cf", "#def5e5",
]
cmap = LinearSegmentedColormap.from_list("continuous-single-2", sequential)

plt.imshow(matrix, cmap=cmap)
plt.colorbar()
plt.show()
```

## matplotlib 连续双色热图

```python
from matplotlib.colors import LinearSegmentedColormap, TwoSlopeNorm
import matplotlib.pyplot as plt

diverging = [
    "#5b53a4", "#456fb1", "#368cbb", "#4fa8af", "#69c3a5", "#8ad0a4",
    "#addda3", "#c9e99d", "#e6f598", "#fefdbc", "#fef0a6", "#fdc877",
    "#f88f52", "#e55848", "#bc2349", "#a20643",
]
cmap = LinearSegmentedColormap.from_list("continuous-diverging-5", diverging)
norm = TwoSlopeNorm(vmin=-3, vcenter=0, vmax=3)

plt.imshow(log2fc_matrix, cmap=cmap, norm=norm)
plt.colorbar()
plt.show()
```

## Plotly 显式设置颜色

```python
import plotly.express as px

fig1 = px.scatter(
    df,
    x="x",
    y="y",
    color="group",
    color_discrete_sequence=categorical_palette(df["group"].nunique()),
)

fig2 = px.imshow(
    matrix,
    color_continuous_scale=[
        "#0b0405", "#30203e", "#3e4d93", "#366b9f", "#3488a6",
        "#36a4ab", "#49c1ad", "#60ceac", "#84d8b0", "#c4e9cf", "#def5e5",
    ],
)
```

## 连续分箱取色

```python
def sample_evenly(colors: list[str], n: int) -> list[str]:
    if n <= 1:
        return [colors[0]]
    idx = [round(i * (len(colors) - 1) / (n - 1)) for i in range(n)]
    return [colors[i] for i in idx]


binned = sample_evenly(sequential, 5)
```
