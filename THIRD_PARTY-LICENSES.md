# Third-Party Licenses

本仓库 (`geo-gis-operator`) 自身以 **GPL-2.0** 发布。以下列出其中引用的第三方内容。

本清单只覆盖**仓库内实际收录或改编的文件**。技能文档中提及但**未收录**的外部项目
(列为「仅提及」),其许可由各自作者所有,使用前请自行查阅。

---

## 一、收录 / 改编的文件

### 1. `agent/skills/qgis-ops/references/mcp-tools-reference.md`

| 项 | 内容 |
|---|---|
| 来源 | [`nkarasiak/qgis-mcp`](https://github.com/nkarasiak/qgis-mcp) |
| 原始路径 | `.claude/skills/qgis-mcp-tools/SKILL.md` |
| 许可 | **GPL-2.0**(仅 Version 2,非 "or later") |
| 改动 | 移除原 frontmatter,加注来源说明头;正文内容未作实质性修改 |

这是本仓库采用 GPL-2.0 的**主要原因**。

### 2. `agent/skills/geo-knowledge-base/references/spectral-indices.md`

| 项 | 内容 |
|---|---|
| 来源 | [`awesome-spectral-indices/awesome-spectral-indices`](https://github.com/awesome-spectral-indices/awesome-spectral-indices) |
| 许可 | **MIT** |
| 改动 | 重排为分类 Markdown 表格;保留其「广义波段→传感器波段映射表」与 332 个指数的官方描述 |

上游保留了每条指数的官方公式链接(<https://awesome-spectral-indices.github.io/>),
本仓库只收录**指数名、全称与波段映射**,公式以官方站为准。

### 3. `agent/skills/geo-knowledge-base/references/remote-sensing.md`

| 项 | 内容 |
|---|---|
| 来源 | `矿地智预` (MineGeoAI-Pre) 系统的 `backend/data/kb/geo-rs.md` |
| 许可 | 同属本仓库作者的作品,随 GPL-2.0 发布 |
| 改动 | 整合去重、补充 EVI 完整公式、GEE 与可复现性要求 |

### 4. `agent/skills/cad-survey-drawing/`(中文 AutoLISP 工具集相关)

| 项 | 内容 |
|---|---|
| 来源 | [`Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD`](https://github.com/Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD) |
| 许可 | **上游未声明许可**;其主体源自 Lee Mac 的公开 AutoLISP 套件(`www.lee-mac.com`, Copyright ©2011) |
| 改动 | **未收录其源码**。仅在技能文档中记录其文件名、命令清单与编码/加载问题,并提供独立编写的编码修复脚本 |

⚠️ 上游未声明许可,商用或再分发前请自行确认授权。
本仓库不含其任何源码文件。

### 5. `agent/skills/cad-survey-drawing/references/cad-toolkit.md`(部分)

| 项 | 内容 |
|---|---|
| 来源 | [`puran-water/autocad-drafting`](https://github.com/puran-water/autocad-drafting) 的 `SKILL.md` |
| 许可 | 该仓库**未声明许可**,且已归档(并入 PuranOS) |
| 改动 | 仅提炼其**实战经验条目**(AutoLISP 陷阱表、entmake 模板、串行调用与批量上限),未收录原文段落 |

⚠️ 同样未声明许可,仅作经验参考,未逐字收录。

---

## 二、仅提及、未收录

以下项目仅在技能文档中作为**工具选项/评估结论**被提及,仓库内不含其任何代码:

| 项目 | 许可 | 提及位置 | 说明 |
|---|---|---|---|
| [`Esri/arcgis-python-api`](https://github.com/Esri/arcgis-python-api) | Apache-2.0 | `arcgis-ops/references/arcgis-learning.md` | 官方文档与示例仓库 |
| [`Esri/large-network-analysis-tools`](https://github.com/Esri/large-network-analysis-tools) | — | 同上 | 网络分析工具样例 |
| [`ucd-cws/arcpy_metadata`](https://github.com/ucd-cws/arcpy_metadata) | — | 同上 | arcpy 元数据编辑类 |
| [`riccardoklinger/OSMquery`](https://github.com/riccardoklinger/OSMquery) | — | 同上 | OSM 数据接入 |
| [`JamesRamm/archook`](https://github.com/JamesRamm/archook) | — | 同上 | ArcGIS 发现与 arcpy 注入 |
| [`sshuair/awesome-gis`](https://github.com/sshuair/awesome-gis) | MIT | 同上 | GIS 资源总索引 |
| [`Knight60/ArcGIS-Pro-MCP`](https://github.com/Knight60/ArcGIS-Pro-MCP) | AGPL-3.0 + 商业许可条款 | `arcgis-ops/references/arcgis-learning.md` | **要求 ArcGIS Pro 3.7**,Pro 3.5.x 无法安装 |
| [`puran-water/autocad-mcp`](https://github.com/puran-water/autocad-mcp) | MIT | `cad-survey-drawing/SKILL.md` | File IPC 后端要求 AutoCAD **LT 2024+** |
| [`U-C4N/Autocad-MCP`](https://github.com/U-C4N/Autocad-MCP) | MIT | 同上 | 双后端(COM + ezdxf),适配完整版 AutoCAD |
| [`beiming183-cloud/AutoCAD-skills`](https://github.com/beiming183-cloud/AutoCAD-skills) | MIT | 同上 | GB/T 机械制图 skill 集合(非测绘出图) |
| [`thepiruthvirajan/autocad-mcp-server`](https://github.com/thepiruthvirajan/autocad-mcp-server) | — | 同上 | AutoCAD MCP 备选 |
| [`LokmenoWer/best-cad-mcp`](https://github.com/LokmenoWer/best-cad-mcp) | — | 同上 | 含 GB/T 机械 CAD skill |
| [`cameronking4/google-earth-engine-mcp`](https://github.com/cameronking4/google-earth-engine-mcp) | MIT | `gee-ops`(评估) | GEE MCP 备选 |
| [`attibalazs/awesome-remote-sensing`](https://github.com/attibalazs/awesome-remote-sensing) | — | 知识库来源说明 | 遥感资源索引 |
| [`mozman/ezdxf`](https://github.com/mozman/ezdxf) | MIT | `autocad-ops`(间接依赖) | DXF 读写库 |
| `gee-export-automation` 技能 | 内部 | `gee-ops` | GEE Code Editor 浏览器自动化(ACE 注入 / Tasks 面板) |

---

## 三、注意事项

- 引入任何第三方 **MCP 服务端**前,请先审其 `security.py` / `policy.py` / `.env.example`。
  AutoCAD MCP 生态中确实存在这类文件,说明该领域有 LISP 注入与越权风险面。
- `Knight60/ArcGIS-Pro-MCP` 为 **AGPL-3.0 且附带商业许可条款**,
  若你的组织对 AGPL 敏感,请先读其 `COMMERCIAL-LICENSE.md`。
- 本仓库自身代码为 GPL-2.0;上游若为 GPL-2.0(非 "or later"),
  衍生作品必须同样以 GPL-2.0 发布。
