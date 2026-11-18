# ArcGIS 学习资源与工具链参考

> 来源：GitHub 官方与社区仓库核查（2026-11-17 核实）。含许可标注，集成前已逐个验证仓库存在性与活跃度。

## 一、官方权威来源

| 资源 | 链接 | 许可 | 用途 |
|---|---|---|---|
| **Esri/arcgis-python-api** | https://github.com/Esri/arcgis-python-api | Apache-2.0 | **官方** arcpy / ArcGIS API for Python 文档与示例仓库，2240★，持续维护（最后推送 2026-11-13） |
| Esri 官方文档站 | https://developers.arcgis.com/python/ | — | arcpy API 参考、GIS API for Python（Web）文档 |
| Esri Pro Python 环境文档 | ArcGIS Pro 附带 `Python\envs\arcgispro-py3` | — | 本机解释器即此环境 |

`Esri/arcgis-python-api` 仓库结构要点：`items_metadata.yaml`（78 KB，元数据架构）、
`update_items.py`（同步脚本）、`land_parcel_extraction_using_edge_detection_deep_learning_model.ipynb`
（深度学习与 ArcGIS 集成范例）。

**用法**：查 arcpy 具体函数签名与参数时，优先 `arcpy.Describe` / `help(arcpy.management.X)`，
其次查官方文档站；GitHub 仓库用于找**完整可运行范例**而非 API 签名（签名以本机 3.5.2 实际为准）。

## 二、ArcGIS Pro MCP（重要，但本机装不上）

| 资源 | 链接 | 许可 | 状态 |
|---|---|---|---|
| **Knight60/ArcGIS-Pro-MCP** | https://github.com/Knight60/ArcGIS-Pro-MCP | AGPL-3.0 | 71★，v1.1.1（2026-09-06） |

它是 ArcGIS Pro 的 **add-in**，把 MCP 直接放进 Pro 进程内：

- **112 个 C# 命名工具**（图层、属性、选择、符号化、布局、栅格、编辑），在 Pro 进程内执行，约 9 ms/次
- **`run_geoprocessing_tool`**：按名称运行 Pro 约 2000 个地理处理工具，用具名参数而非位置参数
- **`execute_arcpy_code`**：任意 arcpy 直通（需可选的 Python 桥）

三层降级机制：命名工具 → 地理处理工具 → 任意 arcpy，覆盖"没有缺失的工具"。

### ⚠️ 本机不兼容（已核实）

- **要求 ArcGIS Pro 3.7**，而本机是 **3.5.2.57366** → add-in 无法加载。
- 另附 `COMMERCIAL-LICENSE.md`，AGPL-3.0 与商业分发条款并存，商业使用需先读该文件。
- 仓库 `dist/` 目录提交的是经 release validation 的构建产物（CI 无 Pro 无法自行构建）。

**结论**：本机继续走 arcpy 脚本路线（见 arcgis-ops）。若将来升级到 Pro 3.7+，此 add-in 值得评估：
它能把 ArcGIS 也纳入 MCP 统一编排，与 QGIS 侧体验对齐。升级 Pro 是前置条件，不是这个插件的问题。

## 三、社区 arcpy 工具集

| 仓库 | 星标 | 许可 | 最后推送 | 说明 |
|---|---|---|---|---|
| Dan-Patterson/Tools_for_ArcGIS_Pro | 92 | 未声明 | 2026-09-20 | Python 代码样例与工具箱（Pro 用） |
| U-C4N/Autocad-MCP（见 CAD 参考） | 306 | MIT | 2026-11-06 | 双后端架构范式值得借鉴 |
| romain974/arcpy_snippets | 2 | GPL-3.0 | 2018-02-16 | 实用片段；**已 8 年未更新**，仅作片段参考 |
| ucd-cws/arcpy_metadata | 99 | — | 2026-10-28 | arcpy 元数据编辑类 |
| Bolton-and-Menk-GIS/restapi | 103 | — | 2026-10-27 | 独立于 Pro 的 Python REST API 客户端 |

**注意**：`Dan-Patterson/Tools_for_ArcGIS_Pro` 仓库树只有 README（6.6 KB）与 `_config.yml`，
实际代码通过 README 链接分发；`romain974/arcpy_snippets` 停更 8 年，引用前须对照本机 3.5.2 验证。

## 四、ArcGIS 学习路径（本机可执行）

按顺序自测，每步给出可验证的产物：

### 第 1 步 · 环境自检
```powershell
$acpy = 'C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe'
& $acpy -c "import arcpy; i=arcpy.GetInstallInfo(); print(i['ProductName'], i['Version'], i['BuildNumber'])"
```
预期：`ArcGISPro 3.5.2 57366`。

### 第 2 步 · 坐标系与量算
```python
sr = arcpy.SpatialReference(4547)
print(sr.name)          # CGCS2000_3_Degree_GK_CM_114E
arcpy.SpatialReference(4326)   # 地理坐标系，量算前必须转换
```
要点：面积/距离计算必须在投影坐标系；本项目统一 EPSG:4547。

### 第 3 步 · 空间参考与数据集检查
```python
desc = arcpy.Describe(path)
print(desc.spatialReference.name, desc.shapeType, desc.extent)
```
**每次操作前必做**：CRS 不一致是空结果与错误面积的首要原因。

### 第 4 步 · 要素类与游标
```python
fc = arcpy.management.CreateFeatureClass(gdb, 'pts', 'POINT',
                                         spatial_reference=arcpy.SpatialReference(4547)).getOutput(0)
with arcpy.da.InsertCursor(fc, ['SHAPE@']) as cur:
    cur.insertRow([arcpy.Point(382000.0, 4180000.0)])   # 行必须是 list
with arcpy.da.SearchCursor(fc, ['SHAPE@X', 'SHAPE@Y']) as cur:
    print([(r[0], r[1]) for r in cur])
```

### 第 5 步 · 地理处理与链式调用
```python
buf = arcpy.analysis.Buffer(fc, gdb + r'\buf', 50).getOutput(0)
```
每个工具返回 `Result` 对象，用 `.getOutput(0)` 取主输出；链式调用前设 `arcpy.env.workspace`。
批量用 `arcpy.env.overwriteOutput = True`（仅在确认目标可弃时）。

### 第 6 步 · 表格与栅格
```python
arcpy.conversion.ExportFeatures(fc, r'<OUTDIR>/pts.gdb', 'GDB')
arcpy.management.ExportFeatures(fc, r'<OUTDIR>/pts.shp')
arcpy.raster.Clip(ras, clip_fc, r'<OUTDIR>/clip.tif')
```
栅格处理注意 nodata 与同网格（行列数/仿射/坐标系三者一致）。

## 五、常见陷阱速查

| 报错 | 原因 | 解法 |
|---|---|---|
| `CreateFileGDB() got an unexpected keyword argument 'name'` | 参数名错 | 用 `out_name` |
| `TypeError: fields size must match size of the row` | 行未包 list | `insertRow([...])` |
| `TypeError: argument must be a list or tuple of values` | 同上 | 同上 |
| `ERROR 000732 / 000735` | 输出路径不适配该工具 | FileGDB 用 目录+名字 形式；确认父目录存在 |
| `arcpy.ListFeatureClasses(gdb)` 返回 None | 工作空间尚无要素类 | 用 `or []` 保护 |
| 空的空间分析结果 | 两输入 CRS 不一致 | 重投影到统一投影坐标��后重跑 |

## 六、外部 MCP 服务（可选，非本机必需）

| 仓库 | 星标 | 许可 | 说明 |
|---|---|---|---|
| `romain974/arcpy_snippets` 等 | — | — | 见上 |
| `riccardoklinger/OSMquery` | 87 | — | 查询 OSM 数据并加到 ArcGIS 工程 |
| `Esri/large-network-analysis-tools` | 80 | — | 大规模网络分析工具与样例 |
| `JamesRamm/archook` | 82 | — | 在系统内搜索 ArcGIS 并让 arcpy 可用 |

这些都是"可选增强"，不是本机 arcpy 路线的前置条件。**引入任何第三方 MCP 前，先审 `security.py` / `policy.py` /
`.env.example`（U-C4N 仓库即含这三类文件，说明该领域存在投毒与越权风险），并确认许可。**
