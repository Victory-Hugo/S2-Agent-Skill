library(ggsankeyfier)
library(tidyverse)
library(knitr)

#* =====示例数据=====
# 读取四阶段示例数据
dat1 <- read_tsv(
  file = "示例数据.tsv", #* 输入 TSV 示例数据
  show_col_types = FALSE
)
knitr::kable(head(dat1))

# 设置节点顺序和阶段顺序
node_levels <- c(
  "Organic Search",
  "Social Media",
  "Partner Referral",
  "Documentation",
  "Product Demo",
  "Case Studies",
  "Trial Signup",
  "Sales Call",
  "Newsletter",
  "Activated",
  "Nurturing"
)

# 设置显式离散色板
pal1 <- c("#0072b2", "#56b4e9", "#009e73", "#f0e442", "#e69f00", "#d55e00")
pal2 <- c("#8ecae6", "#219ebc", "#023047", "#ffb703", "#fb8500")
pal_node <- c(pal1, pal2)
names(pal_node) <- node_levels

# 转换为 sankey 长格式
dat2 <- dat1 %>%
  mutate(
    channel = factor(channel, levels = node_levels),       #* 第一阶段节点顺序
    touchpoint = factor(touchpoint, levels = node_levels), #* 第二阶段节点顺序
    intent = factor(intent, levels = node_levels),         #* 第三阶段节点顺序
    outcome = factor(outcome, levels = node_levels)        #* 第四阶段节点顺序
  ) %>%
  pivot_stages_longer(
    c("channel", "touchpoint", "intent", "outcome"), #* 依次展开四个桑基阶段
    "amount"                                         #* 流量宽度对应 amount 列
  ) %>%
  group_by(edge_id) %>%
  mutate(
    flow_group = as.character(node[connector == "from"][1]) #* 每段边使用流出节点的颜色
  ) %>%
  ungroup() %>%
  mutate(
    flow_group = factor(flow_group, levels = node_levels)   #* 固定边颜色顺序
  ) %>%
  mutate(
    node = factor(as.character(node), levels = node_levels), #* 固定节点图例和颜色顺序
    stage = factor(
      as.character(stage),
      levels = c("channel", "touchpoint", "intent", "outcome"),
      labels = c("Discovery", "Experience", "Decision", "Outcome")
    )
  )
knitr::kable(head(dat2))

#* =====桑基图=====
# 定义节点和文本位置
pos <- position_sankey(
  order = "ascending", #* 同一阶段内按流量升序堆叠
  v_space = 0.035      #* 节点之间的垂直间距
)

pos_text <- position_sankey(
  order = "ascending", #* 文本与节点使用同一排序方式
  v_space = 0.035,     #* 文本与节点保持相同间距
  nudge_x = 0.075      #* 文本向右偏移，避免压住节点
)

# 初始化基础图层
p <- ggplot(
  dat2,
  aes(
    x = stage,             #* x 轴对应桑基阶段
    y = amount,            #* 流宽对应流量数值
    group = node,          #* 节点按 node 聚合
    connector = connector, #* from/to 定义边连接方向
    edge_id = edge_id      #* edge_id 定义每条边
  )
)

# 绘制柔和流向边
p2 <- p +
  geom_sankeyedge(
    aes(fill = flow_group), #* 边填充颜色对应每段流出的节点
    position = pos,         #* 使用 sankey 专用定位
    alpha = 0.42,           #* 提高透明度以形成叠加层次
    color = "#ffffff",      #* 边界白线分隔相邻流
    linewidth = 0.08,
    show.legend = FALSE
  )

# 绘制节点
p3 <- p2 +
  geom_sankeynode(
    aes(fill = node),  #* 节点填充颜色对应节点名称
    position = pos,    #* 使用 sankey 专用定位
    color = "#ffffff", #* 节点边框颜色
    linewidth = 0.35,
    show.legend = FALSE
  )

# 添加节点标签
p4 <- p3 +
  geom_text(
    aes(label = node),       #* 文本标签对应节点名称
    stat = "sankeynode",     #* 在节点中心统计标签位置
    position = pos_text,     #* 使用带偏移的文本定位
    hjust = 0,               #* 标签左对齐
    size = 3.5,
    lineheight = 0.92,
    color = "#263238",
    fontface = "bold"
  )

# 设置坐标、颜色和标题
p5 <- p4 +
  scale_x_discrete(
    expand = expansion(add = c(0.25, 0.95)), #* 左右保留标签空间
    position = "top"                         #* 阶段名称显示在顶部
  ) +
  scale_fill_manual(
    values = pal_node, #* 使用 11 个显式离散色
    drop = FALSE
  ) +
  coord_cartesian(clip = "off") +
  labs(
    title = "Customer Journey Sankey",
    subtitle = "Example data linking discovery channels, content touchpoints, decisions, and outcomes"
  )

# 美化主题
p6 <- p5 +
  theme_void(base_size = 12) +
  theme(
    plot.background = element_rect(fill = "#fbfaf7", color = NA),
    panel.background = element_rect(fill = "#fbfaf7", color = NA),
    plot.margin = margin(0.55, 1.1, 0.55, 0.55, unit = "cm"),
    plot.title = element_text(
      color = "#263238",
      face = "bold",
      size = 22,
      hjust = 0.02,
      margin = margin(b = 4)
    ),
    plot.subtitle = element_text(
      color = "#56646b",
      size = 10.5,
      hjust = 0.02,
      margin = margin(b = 12)
    ),
    axis.text.x = element_text(
      color = "#263238",
      face = "bold",
      size = 11,
      margin = margin(b = 8)
    )
  )

# 保存图形
ggsave(
  filename = "桑基图.pdf",
  plot = p6,
  width = 11,
  height = 7,
  units = "in",
  bg = "#fbfaf7"
)

p6
