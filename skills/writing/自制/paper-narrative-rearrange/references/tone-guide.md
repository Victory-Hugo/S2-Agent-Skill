# Writing Register & Tone — Extended Guide

本文件是 SKILL.md 中 Writing Register & Tone 节的扩展版，包含完整示范段落、禁用词汇表和更多 Before/After 对照。

---

## 禁用词汇与短语列表

以下词汇出现在正文中时须替换或删除：

**报告/管理腔触发词：**
- 本研究对……进行了……
- 分析结果显示……
- 经分析……
- 数据显示字段……
- 结果表明……（单独作为段落开头且无科学主语时）

**QA/内部核查触发词：**
- 经核查
- 经验证
- 以下为最终结果
- 经过质量控制过滤后（若后接枚举而非叙述）

**元数据/技术标识符触发词：**
- 任何出现在正文中的变量名、列名、字段名（如 `os_days`、`cohort_group`、`stage_group`）
- 文件路径、脚本名
- 参数名

**过度清单/编号触发词：**
- （1）……；（2）……；（3）……（在正文主体中）
- 首先……其次……再次……最后……（替换为连接词衔接的自然句）

---

## 完整示范段落

### 示例 1：队列描述（中文）

**Before（禁止）：**

本研究对纳入的患者样本进行了基线特征统计，相关字段包括 age_group、sex、stage_group 及 os_days。经质量控制过滤后，最终纳入分析的样本共计1,284例。统计结果如下：（1）中位年龄58岁；（2）男女比例1.4:1；（3）晚期患者（III-IV期）占68%。

**After（正确）：**

队列共纳入1,284例经质量控制筛选的患者（Table 1），中位年龄58岁（IQR 47–66），男女比例为1.4:1。晚期病例（III–IV期）占总队列的68%，提示本研究人群以进展期疾病为主。

---

### 示例 2：主要结局（中文）

**Before（禁止）：**

对os_days字段与治疗分组的关联进行了Kaplan-Meier分析，结果显示治疗组vs对照组的中位生存数据存在统计学差异（P < 0.05）。经核查，上述结论已有Fig. 2A支撑。

**After（正确）：**

治疗组患者的中位总生存期为23.4个月，较对照组的15.1个月延长了8.3个月（log-rank P = 0.03；Fig. 2A），提示该治疗方案具有潜在临床获益。

---

### 示例 3：生物标志物关联（英文）

**Before（禁止）：**

The variable "biomarker_score" showed significant association with "response_group" after performing correlation analysis. Results indicated a difference (P = 0.001). Analysis was conducted using standard statistical methods.

**After（正确）：**

Patients with high biomarker expression were significantly more likely to achieve objective response than those with low expression (odds ratio 2.8, 95% CI 1.6–4.9, P = 0.001; Fig. 4B), consistent with the proposed predictive role of this marker.

---

### 示例 4：机制描述（英文）

**Before（禁止）：**

After performing pathway enrichment analysis on the differentially expressed gene list (DEG_list.csv), results showed that the top enriched pathway was the mTOR signaling pathway (adjusted P < 0.01).

**After（正确）：**

Pathway enrichment analysis of differentially expressed genes revealed significant upregulation of mTOR signaling components (adjusted P < 0.01; Fig. 5C), suggesting that mTOR pathway activation may contribute to the observed phenotype.

---

## 连接词速查表

| 语义关系 | 中文连接词 | 英文连接词 |
|----------|-----------|-----------|
| 一致/支持 | 与之一致；与上述发现相符 | Consistent with; In line with |
| 对比/转折 | 相比之下；然而；与此相反 | In contrast; However; Conversely |
| 递进/补充 | 此外；进一步地 | Furthermore; Moreover; Additionally |
| 因果 | 提示；表明；由此推测 | suggesting; indicating; thus |
| 总结 | 综合以上；总体而言 | Together, these findings; Collectively |

---

## 结论强度标定词汇

从弱到强排列，选择与证据质量匹配的强度：

**弱（关联性/描述性）：**
- was associated with / 与……相关
- is consistent with / 与……一致
- supports the hypothesis that / 支持……的假说

**中（提示性）：**
- suggests / 提示
- indicates / 表明
- may contribute to / 可能参与

**强（因果性，需直接实验证据）：**
- demonstrates that / 证明
- establishes / 确立
- drives / 驱动（仅适用于功能性实验结论）

> **注意**：在纯队列研究或相关性分析中，禁止使用强因果性表述。
