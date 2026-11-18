# geo-gis-operator · 地理空间操作员

[![License: GPL-2.0](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

一个可独立分发的 **MiniMax Code 智能体**,用于测绘与 GIS 生产作业:
直接操作 **QGIS**、**ArcGIS Pro**、**AutoCAD**、**Google Earth Engine**,并自带测绘与遥感知识库。

不是"聊天式 GIS 顾问"——任务能在本机执行时,它就**真去执行**,然后报告跑出来的真实数字。

---

## 它能做什么

| 技能包 | 覆盖 | 实际通路 |
|---|---|---|
| `qgis-ops` | 工程/图层/样式/制图布局/Processing 算法/编辑/坐标转换 | QGIS MCP 桥接(TCP 9876) |
| `arcgis-ops` | FileGDB、要素类、缓冲/裁剪/相交、栅格处理、字段计算 | arcpy(Pro 自带 Python) |
| `autocad-ops` | DWG/DXF 增删实体、注记、图层、导出、几何校验 | AutoCAD COM + ezdxf |
| `cad-survey-drawing` | 面积标注与统计表、高程改正、方格网、CASS 导出、中文 AutoLISP 工具集 | AutoLISP + ezdxf |
| `gee-ops` | GEE 脚本编写、批量导出 NDVI/NDBI/BSI/LST、任务状态查询 | 浏览器自动化 |
| `geo-knowledge-base` | 导线/水准计算判据、坐标系与投影、遥感原理与指数、精度评定、光谱指数库 | 内置知识库(5 份 reference) |

知识库内含 **332 个光谱指数**分类索引与**广义波段→传感器波段映射表**
(Sentinel-2 / Landsat-8-9 / Landsat-4-7 / MODIS)。

## 设计要点

**先探测,再动手。** 每个技能都要求先读实际数据(schema、CRS、要素数),禁止凭字段名硬编码。
本项目图层字段是中文(`点名`/`E`/`N`/`Z`),猜 `name` 会静默返回空。

**写操作需确认。** 分析类(查询、统计、渲染预览、启动软件)自动执行;
覆盖/删除既有文件、删要素、对外发布、提交 GEE 导出任务(消耗配额且写 Drive)必须先征得同意,
并按 **改什么 → 哪些路径 → 怎么回退** 三要素说明。

**如实报告。** 数字必须来自实际运行,不拿预期值充数;失败要报确切错误与恢复步骤,
不静默换用别的工具。

**把坑写进技能。** 下面这些是实测踩出来的,不是文档抄的:

- QGIS MCP `layer.find` 传**空** `name_pattern` 返回 0 层,必须用通配符
- QGIS MCP `features.get` 在部分构建上对所有图层报错,改用 `query.sql` / `features.get_statistics`
- arcpy `CreateFileGDB` 的参数是 `out_name` 而非 `name`;`insertRow` 的行必须是 list
- AutoLISP 里 `vl-symbol-function` 探测 `C:xxx` 会抛错并**中断整个 `progn`**,
  改用 `vl-catch-all-apply` + `eval` + `(read "C:zzArea")`
- AutoCAD 的 `SECURELOAD=1` 会弹「安全性 - 未签名的可执行文件」对话框并阻断所有 COM 调用
- AutoCAD COM 属性读取正常 **不代表** 命令通道可用,必须先跑极简探针

## 安装

### 方式 A(推荐):先建智能体,再覆盖文件

```powershell
# 1) 在目标机器创建智能体
#    MiniMax Code 内执行:
#    mavis({ command: "agent create",
#            args: { name: "geo-gis-operator", display_name: "地理空间操作员" } })

# 2) 把本仓库的 agent/ 目录内容复制到
#    %USERPROFILE%\.minimax\agents\geo-gis-operator\
```

### 方式 B:整体复制

```powershell
Copy-Item -Recurse .\agent "$env:USERPROFILE\.minimax\agents\geo-gis-operator"
```

复制后若目标目录存在 `.agent-instance-id`,请删除它——那是本机运行时绑定,应由运行时重建。

### 验证

```powershell
mavis agent list                      # 应出现 geo-gis-operator
mavis agent get --name geo-gis-operator
```

技能在**下一个会话**生效,无需重启运行时。

### 安装后必改的三处

1. `agent/agent.md` frontmatter 的 `defaultWorkspaceDir` → 你的项目目录
   (出厂为**空字符串**;占位符不是合法绝对路径,运行时 会拒绝加载整个智能体,
   必须填真实绝对路径或留空)
2. `agent/agent.md` 的 **Environment facts** 表 → 你机器上的软件版本与路径
   (表中是作者机器的实测值,**先探测再改**,别直接照抄)
3. `agent/skills/geo-knowledge-base/references/project-conventions.md` → 你项目的
   坐标系、坐标序、方位角定义、图层命名规则(**这四项错了,成果会系统性出错**)

## 前置条件

| 组件 | 要求 | 随包提供 |
|---|---|---|
| MiniMax Code | 支持 agent + skill | — |
| QGIS | 3.44.x + `qgis_mcp_plugin` + MCP 服务端 | 否 |
| ArcGIS Pro | 3.5+(含 arcpy) | 否 |
| AutoCAD | 2020+(COM `AutoCAD.Application`) | 否 |
| Python | 3.11+,ezdxf / win32com / pyproj / geopandas | 否 |
| Google Earth Engine | 浏览器可访问 code.earthengine.google.com | 否 |

**QGIS MCP 桥接需要桌面端处于运行状态**,否则所有 QGIS 调用都会失败——技能里已写明启动命令。

## 仓库结构

```
.
├── README.md                     本文件
├── LICENSE                       GPL-2.0
├── NOTICE                        版权与第三方来源声明
├── THIRD_PARTY-LICENSES.md       第三方组件许可清单
├── agent/                        智能体本体(可直接复制安装)
│   ├── agent.md                  系统提示词
│   ├── config.yaml               模型配置
│   └── skills/                   6 个技能包 + 8 份 reference + 1 个脚本
└── docs/
    ├── INSTALL.md                详细安装与验证
    └── VERIFICATION.md           各项能力的实测验证记录
```

## 许可

本仓库采用 **GPL-2.0**。

原因:`agent/skills/qgis-ops/references/mcp-tools-reference.md` 直接取自
[`nkarasiak/qgis-mcp`](https://github.com/nkarasiak/qgis-mcp) 的
`.claude/skills/qgis-mcp-tools/SKILL.md`,该文件为 **GPL-2.0**(仅 v2,非 "or later"),
因此整仓以 GPL-2.0 发布以保证兼容。

第三方组件的详细来源与许可见 [THIRD_PARTY-LICENSES.md](THIRD_PARTY-LICENSES.md)。

## 安全

- 本智能体**不会**代输 Google / ArcGIS 账号密码,登录须由用户本人在浏览器完成。
- 引入任何第三方 MCP 服务端前,请先审其 `security.py` / `policy.py` / `.env.example`
  ——AutoCAD 领域已有此类文件,说明该领域存在 LISP 注入与越权风险面。
- 默认工作区之外不做写操作;对外发布与消耗配额的导出操作一律先确认。
