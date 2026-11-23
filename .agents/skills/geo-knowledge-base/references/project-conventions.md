# 项目约定与数据资产（示例模板 · 按你的项目替换）

> ⚠️ **这份文件是作者项目的真实约定（数字测图实习 · 校园测区），公开版本把绝对路径
> 参数化成了 `<PROJECT_DIR>` 等占位符。** 换成你自己的项目时,请整体替换下面的
> 表格与编号约定——尤其是**坐标系、坐标序、方位角定义、图层命名规则**,
> 这四项错了,智能体产出的成果会系统性出错。
>
> 保留通用原则(本文件末节)即可,那些与具体项目无关。

## 一、主工作区 `<PROJECT_DIR>`

数字测图实习项目(师大北校区)。目录结构:

| 目录 | 内容 |
|---|---|
| `data/` | GPKG(`测量实习.gpkg` 为主库)、GeoTIFF 底图与配准影像、GeoJSON、QML 样式、Excel 控制点 |
| `docs/` | 组内手册:测量计算方法、地物测量实施细则、全站仪导线外业与内业指导、湖区闭合导线布设方案(均含 .md 与 .docx) |
| `scripts/` | 自动化脚本(QGIS/PyQGIS、AutoCAD COM、ezdxf、栅格配准) |
| `tools/` | 水准数据处理系统(HTML + .bat 启动 + 使用说明) |
| `work/` | 中间产物与 JSON 配准参数 |
| `成果/` | **输出目录**:DWG/DXF 成果图、备份 .bak |
| `测量实习.qgz` | 主 QGIS 工程 |

`docs/` 中的组内手册**对课程作业具有权威性**——与本知识库冲突时以手册为准。

## 二、坐标与基准约定

- 平面坐标系:**CGCS2000 / 3°带,中央子午线 114°E = EPSG:4547**
- 高程基准:**1985 国家高程基准**
- 坐标序:**E 在前、N 在后**,单位 m
- 方位角:**从北起顺时针**
- 已知控制点:项目 `data/` 下的控制点成果表(Excel)

## 三、QGIS 主工程图层（示例 · 按你的工程替换）

| 图层名 | 类型 | 说明 |
|---|---|---|
| 卫星正射底图 | raster | `data/` 下的正射影像 GeoTIFF |
| 图幅 / 测区 | polygon | 测区范围 |
| 图幅内测区 | polygon | |
| OSM建筑与场地 | polygon | OSM 矢量数据 |
| OSM道路与水体 | line | |
| 导线点 | point | 实测边长与骨架锚定后的成果点 |
| 导线 | line | 同上 |
| 已知控制点 / 历史控制点 | point | |
| 水准点 | point | |
| 水准路线 | line | |
| 方格网_5m | line | |
| 技术要求 | annotation | 图廓说明 |
| 测站负责关系 | line | |

图层面 id 是不透明字符串（如 `OSM______8be97922_5741_4fbf_a41d_63c431760f07`），
必须用 `layer.find` 按名称查，**不能用图层名替代 id**。

## 四、AutoCAD 成果目录约定

`成果/` 内主文件（示例命名，替换成你的）：

- `碎步测量成果图.dwg`、`碎步测量成果图_草图成图.dwg/.dxf`
- `碎步点坐标图_CGCS2000.dwg`、`碎步点坐标图_CGCS2000_含h2-h7.dwg/.dxf`
- 备份为 `.bak`（AutoCAD 自动生成）

**每个 .dwg 都配一份 .dxf** —— ezdxf 工作流优先用 DXF，避免启动 AutoCAD。

已验证的成果图约定（来自 `<PROJECT_DIR>/scripts/` 下的自动化脚本）：

- 图层命名：数据层 `补充h点_非实测`、注记层 `补充h点注记_非实测`、表格层 `补充成果表_非实测`
- 符号尺寸：圆半径 1.2、十字 1.2、字高 2.2（图纸单位）
- 标注偏移按点间距调整，避免相近点（如仅相距 3.8 m 的两点）碰撞
- **图内写明说明块**：数据来源、基准假设、被排除的点及量化依据（偏移量 vs 底图范围）
- 成果表列：点号 / X / Y，位于固定图面位置

## 五、数据血缘与"非实测"标注原则

本项目已确立并应持续遵守：

1. **Google 地图取点等非实测数据**，在图层名、注记层与图内说明三处同时标注"非实测"。
2. 补充点**不参与**碎部点成果统计与精度评定。
3. 基准冲突时必须量化检验（本项目 GCJ-02 解使四点西移约 559 m，超出底图西界 E381492.96，故排除）。
4. 被剔除的点（如偏移 700 m 的 h1）要在说明中写明剔除理由。

## 六、矿地智预系统（`<MINEGEOAI_DIR>`）

矿区土地利用智能预测系统（SaaS 架构、本地部署、离线可用），**只读参考，不修改其代码/数据/数据库**。

| 资产 | 路径 | 用途 |
|---|---|---|
| 知识库 | `backend/data/kb/geo-rs.md` | 已整合进本智能体 remote-sensing.md |
| GEE 导出技能 | `skills/gee-export-automation/SKILL.md` | 全局技能，浏览器自动化细节在此 |
| GEE 导出脚本 | `tools/gee_export_indices.js` | 多指数多年份导出脚本模板 |
| 真实数据接入 | `tools/import_real_dataset.py` | CLCD+DEM+指数 → 数据集 |
| 新区域数据 | `tools/download_area_data.py` | AOI+年份 → CLCD+DEM，自动代理/跨图幅 |
| 数据集 | `backend/data/<区域>/` | 含 metadata.json 的目录即一个注册数据集 |

该系统真实数据实测结果（2026-09-20，平朔矿区 65.15 km²，30 m）：
变化检测 15,332 像元 / 1,379.9 ha / 21.18%，8 处热点；分类 OA 92.9% / Kappa 0.867；
验证 OA 88.05% / Kappa 0.753。

## 七、相关 GEE 资产（`<GEE_WORKDIR>`）

| 目录 | 内容 |
|---|---|
| `gee-raster-fingerprint/` | 栅格指纹工具 |
| `gee-sen-mk-trend/` | Sen + MK 趋势分析 |
| `lab3_georef/` | 配准实验 |
| `shanxi-gpp-trend/` | 山西 GPP 趋势 |
| `导出/` | 导出成果 |
| `awesome-gee.md` | GEE 资源清单（38 KB） |

## 八、工具链与解释器

| 需求 | 解释器/入口 | 已有模块 |
|---|---|---|
| QGIS MCP | `qgis-mcp-server.exe` → TCP 9876（需桌面端运行） | — |
| QGIS PyQGIS | `C:\Program Files\QGIS 3.44.14\bin\python-qgis-ltr.bat` | osgeo/OGR/GDAL 全套 |
| ArcGIS arcpy | `C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe` | arcpy 3.5.2 |
| 通用脚本 | 系统 `python` 3.11.9 | ezdxf, numpy, scipy, rasterio, geopandas, shapely, pyproj, matplotlib, win32com, PIL, openpyxl, pandas, skimage, cv2 |
| AutoCAD COM | 同上（win32com） | AutoCAD 2025, ProgID `AutoCAD.Application` |
| FreeCAD | MCP + XML-RPC 9875 | 三维建模/FEM |

**系统 `python` 没有 `osgeo`** —— 需要 GDAL/OGR 时用 QGIS 的 python-qgis-ltr.bat。

## 九、命名与产出约定

- 脚本命名：`<动作>_<对象>.py`（如 `build_points.py`、`export_dxf.py`、`verify_pointmap.py`），
  配套 `check_*.py` / `verify_*.py` 做成果校验。
- 成果文件命名：`<主题>_<变体>.<ext>`，中文可读；备份用 `.bak`。
- 中间产物统一放 `work/`，最终成果放 `成果/`，临时脚本不要留在 `成果/`。
