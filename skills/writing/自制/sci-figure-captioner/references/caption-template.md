# 图注模板库（严格面板化）

本模板库用于统一 `sci-figure-captioner` 输出结构。默认先中文后英文，且中英逐项镜像。

## 模板 A：多面板生物医学图（A/B/C...）

### 中文骨架

```text
图X. [一句总体说明：研究对象 + 主要发现方向，不写未证实结论]。
(A) [面板A内容：实验/图像类型 + 组别/条件 + 可见结果]。
(B) [面板B内容：同上，强调与A的关系或补充信息]。
(C) [面板C内容：定量结果 + 误差线定义 + 统计检验与显著性标记（仅在已提供时写）]。
缩写： [缩写1全称]；[缩写2全称]。
统计： [检验方法]，[n定义]，[显著性规则]。
```

### 英文镜像骨架

```text
Figure X. [One-sentence overview: subject + directional finding without unverified claims].
(A) [Panel A: assay/image type + groups/conditions + observable result].
(B) [Panel B: same structure, highlighting relation to panel A].
(C) [Panel C: quantification + error bar definition + statistical test/significance notation only if provided].
Abbreviations: [abbr1, full term]; [abbr2, full term].
Statistics: [test], [definition of n], [significance rule].
```

## 模板 B：单面板定量图

### 中文骨架

```text
图X. [图类型，如柱状图/折线图/散点图] 显示 [比较对象] 在 [条件/时间] 下的变化。
定量结果： [主要趋势描述，不写未经证实因果]。
统计： [检验方法]；误差线表示 [SD/SEM/CI]；n = [定义与数值（若未知写待补充）]；显著性按 [规则] 标注。
```

### 英文镜像骨架

```text
Figure X. A [plot type] showing changes in [comparison target] under [condition/time].
Quantitative result: [main trend without unverified causality].
Statistics: [test]; error bars represent [SD/SEM/CI]; n = [definition and value, or mark as pending if unavailable]; significance follows [rule].
```

## 模板 C：显微图（染色/倍率/比例尺/代表图）

### 中文骨架

```text
图X. [模型/组织/细胞] 的 [成像方式] 代表性图像。
(A) [对照组/基线组]；(B) [处理组1]；(C) [处理组2 或定量面板]。
图像信息： [染色名称]，[倍率]，比例尺 = [数值与单位]。
定量（如有）： [指标] 在各组中的差异；统计方法为 [检验]；误差线为 [定义]。
```

### 英文镜像骨架

```text
Figure X. Representative [imaging modality] images of [model/tissue/cell type].
(A) [control/baseline]; (B) [treatment group 1]; (C) [treatment group 2 or quantification panel].
Imaging details: [staining], [magnification], scale bar = [value and unit].
Quantification (if available): group differences in [metric]; statistics by [test]; error bars denote [definition].
```

## 模板调用规则

1. 先根据图形类型选模板，再按面板逐项填充。
2. 对未知字段保留“待补充”，不得虚构。
3. 中英两版必须逐条同构：
- 相同面板顺序。
- 相同统计事实。
- 相同单位与缩写释义。
4. 用户指定期刊时，仅调整表达风格，不改变模板中的事实约束。
