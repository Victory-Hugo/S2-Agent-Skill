# aDNA-downloader Skill

这是一古代 DNA 信息收集与原始测序数据下载 skill。

## 结构

```text
.agents/
└── skills/
    └── aDNA-downloader/
        ├── SKILL.md
        └── template/
            └── 古代DNA收集模板-AI-agent.xlsx
```

## 使用

把 `.agents/` 目录放到项目根目录。之后在相关任务中说明需要使用 `aDNA-downloader`。直接提供 DOI、论文标题等线索。

## API 配置（可选但推荐）

为避免直接爬取出版社网页触发人机验证，本 skill 优先通过 Crossref / Unpaywall / NCBI E-utilities 等官方 API 获取文献元数据、开放获取全文与补充材料。

在 `key/1-NCBI-API.key` 中按行填写：

```
你的邮箱
你的 NCBI API key
```

- NCBI API key 申请：登录 https://www.ncbi.nlm.nih.gov/account/ 后在 Settings 页生成，免费。
- Crossref、Unpaywall 无需注册，复用同一邮箱即可。
- `key/` 目录已加入 `.gitignore`，不会被提交到版本库。
