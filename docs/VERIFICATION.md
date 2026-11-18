# 实测验证记录

> 记录于作者机器(Windows / QGIS 3.44.14 / ArcGIS Pro 3.5.2 / AutoCAD 2025 / Python 3.11.9)。
> 目的是让使用者区分**已实测**与**仅文档依据**的部分。

---

## 一、QGIS MCP 桥接

| 项 | 结果 |
|---|---|
| 服务端 | `qgis-mcp-server.exe`(上游 `nkarasiak/qgis-mcp` v0.15.2,GPL-2.0) |
| 桥接 | TCP 9876,**需 QGIS 桌面端运行**才注册 |
| `ping` | `{"pong": true}` ✅ |
| `layer.find` | 返回 15 个图层 ✅ |
| 工程加载 | `测量实习.qgz` 加载成功,15 图层,EPSG:4547 ✅ |
| 要素统计 | `已知控制点` = **25** 个(`query.sql` 与 `get_statistics` 双路互证)✅ |

### 本机构建缺陷(已写入技能)

| 现象 | 处置 |
|---|---|
| `layer.list` 传 `limit` → 类型错误 | 改用 `layer.find` |
| `layer.find` 传**空** `name_pattern` → 返回 0 层 | 必须用通配符 `*名称*` |
| `features.get` 对**所有图层**报错 | 改用 `query.sql` / `features.get_statistics` |
| `message_log` 传 `limit` → `slice indices must be integers` | 去掉该参数 |

---

## 二、ArcGIS Pro / arcpy

| 项 | 结果 |
|---|---|
| arcpy | 3.5.2,build 57366,Python 3.11.11 ✅ |
| `SpatialReference(4547)` | 解析为 `CGCS2000_3_Degree_GK_CM_114E` ✅ |
| `CreateFileGDB` → 要素类 → 游标 → Buffer | 全链路通过 ✅ |
| `mcp__arcgis__*` 工具 | **当前档未注册**,调用报 `Tool not found` ❌(故走 arcpy 脚本路线) |

### 实测踩坑

```python
# 参数名是 out_name,不是 name
arcpy.management.CreateFileGDB(out_folder_path, out_name)

# 行必须是 list
with arcpy.da.InsertCursor(fc, ['SHAPE@']) as cur:
    cur.insertRow([arcpy.Point(382000.0, 4180000.0)])

# 返回 None 而非空列表
arcpy.ListFeatureClasses(gdb) or []
```

### ArcGIS Pro MCP 不可用

`Knight60/ArcGIS-Pro-MCP` 要求 **ArcGIS Pro 3.7**,本机 3.5.2 → add-in 无法加载。
且其为 AGPL-3.0 并附商业许可条款。已写入 `arcgis-ops/references/arcgis-learning.md`。

---

## 三、AutoCAD / COM / ezdxf

| 项 | 结果 |
|---|---|
| COM ProgID `AutoCAD.Application` | 可解析 ✅ |
| 冷启动(`Dispatch`) | 成功,版本 25.0s,`visible=False` ✅ |
| ezdxf | 已装,可读写 DXF ✅ |

### 中文测量 LISP 工具集(实测加载)

来源 `Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD`,
权威 blob 41215 字节,sha256 `940c64a3f361d14ea85eb19ba9404eb45802f275db9dc9836059bcca1824e0cd`。

**编码事实**:文件为 **GBK/GB18030**。按 GB18030 解码得 **1380 个可读汉字**
(如「功能：生成地形图方格网数据文件」);按 UTF-8 直读仅剩 16 个可识别汉字。
AutoCAD 按 ANSI 代码页读 LISP,**原文件本身可直接加载**。

**加载与命令验证**(本机 AutoCAD 2025 实测):

```
LOAD_OK
C:zzArea=DEFINED       C:zzArea2File=DEFINED    C:zzBC=DEFINED
C:zzArea2Table=DEFINED C:zzFGW=DEFINED          C:zzExport2Dat=DEFINED
```

### 实测踩坑

| 现象 | 根因 | 处置 |
|---|---|---|
| 探测命令时 marker 文件为空 | `vl-symbol-function` / `fboundp` 对 `C:xxx` 抛错并**中断整个 `progn`** | 改用 `vl-catch-all-apply` + `eval` + `(read "C:zzArea")` |
| COM 全部被拒 `-2147418111` | 弹出「安全性 - 未签名的可执行文件」模态框(SECURELOAD=1) | `(setvar "SECURELOAD" 0)` → load → 恢复;或加 `TRUSTEDPATHS` |
| 命令发出去无反应 | `zzArea` 是拾取交互命令,AutoCAD 进入等待状态,后续全部排队 | 交互命令只在可见窗口人工操作;脚本只做非交互调用 |
| 属性读取正常但命令无效 | AutoCAD「命令通道整体失效」 | 先跑极简探针;失效则重启 acad 进程 |

### 编码修复脚本

`skills/cad-survey-drawing/scripts/fix_cad_lsp_mojibake.py`
先诊断再转换,实测:

```
# GBK 原文
diagnosis  : gb18030   CJK readable = 1380
parens     : 1523 open / 1523 close -> BALANCED

# 双重 mojibake
diagnosis  : utf8      CJK readable = 1380
parens     : 1523 open / 1523 close -> BALANCED
```

**字节级幂等**,且对 GBK 原文**无损透传**(输出 sha256 与原文件完全一致)——不会毁掉好文件。

---

## 四、知识库

| 项 | 结果 |
|---|---|
| `spectral-indices.md` | 332 个指数,分类:植被 223 / 水体 34 / 燃烧 20 / 城市 20 / 土壤 17 / 雪 10 / 云 7 / 地质 1 ✅ |
| 波段映射 | Sentinel-2:NIR=B8、NIR2=B8A、SWIR1=B11、SWIR2=B12、Red=B4、Green=B3、Blue=B2 ✅ |
| 公式核对 | 上游 `src/v1/indices.py` 核对:`MNDWI = (G - S1)/(G + S1)`;`AWEIsh = B + 2.5G - 1.5(N + S1) - 0.25 S2` ✅ |

> 上游 main 分支的 `output/spectral-indices-table.csv` 为 280 行 / 32 类,
> 本知识库对应的是 **v1 目录**的 332 条。以官方站公式为准。

### 基准偏移检验(真实算例)

Google 取点按 WGS84 投影 → 落在正射底图范围内;
若按 GCJ-02 反算 → 整体西移 **ΔE = -557.7 ~ -557.9 m**,超出底图西界 372.6 ~ 470.7 m,
故该解不成立。第五个点偏东约 765 m,超出底图东界 202 m,剔除。

容许对比:1:500 图上 0.1 mm ≈ 实地 0.05 m;558 m 偏移高出 4 个数量级。

---

## 五、仅文档依据(未在本机实测)

| 项 | 说明 |
|---|---|
| `gee-ops` 的 GEE 任务提交 | 依赖浏览器自动化与用户账号,本仓库不含实测记录;流程细节来自既有 `gee-export-automation` 技能 |
| `Esri/arcgis-python-api` 示例代码 | 官方仓库,未逐个在本机运行 |
| 第三方 MCP 服务端 | 未安装,仅做许可与版本兼容性评估 |

---

## 六、复现方式

```powershell
# QGIS
Start-Process 'C:\Program Files\QGIS 3.44.14\bin\qgis-ltr-bin.exe' `
              -WorkingDirectory 'C:\Program Files\QGIS 3.44.14\bin'
# 等待桥接,再 ping

# arcpy
& 'C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe' -c "import arcpy; print(arcpy.GetInstallInfo()['Version'])"

# AutoCAD COM
python -c "import win32com.client as w; a=w.Dispatch('AutoCAD.Application'); print(a.Version)"

# LISP 编码诊断
python skills\cad-survey-drawing\scripts\fix_cad_lsp_mojibake.py <源.lsp> <输出.lsp>
```
