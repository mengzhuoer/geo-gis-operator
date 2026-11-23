---
name: cad-survey-drawing
description: |
  Use when the task involves surveying drawing output in AutoCAD: area annotation and area
  statistics tables, elevation correction, terrain grid generation, CASS data export, and
  AutoLISP batch drafting. Covers the Chinese ZZ* AutoLISP toolset (area label, area table,
  grid, cross-section) plus the encoding and SECURELOAD pitfalls that break it.
  Does NOT cover general CAD editing (use autocad-ops).license: GPL-2.0
compatibility: Requires Windows with the matching GIS software installed; QGIS tasks need a running QGIS desktop, AutoCAD tasks need AutoCAD or ezdxf, ArcGIS tasks need ArcGIS Pro.
metadata:
  author: mengzhuoer
  version: "1.0"
---

# CAD Survey Drawing

Surveying-specific AutoCAD drafting: the AutoLISP routines Chinese surveyors actually use, the
AutoCAD MCP server options, and the failure modes that break LISP in practice.

**Reference**: `references/cad-toolkit.md` — verified file list with paren-balance checks, the
GB18030 decode procedure, the tested non-interactive LISP probe, this project's symbol conventions,
entmake templates, and licence notes.

## Inputs to collect

- The drawing (.dwg) or the coordinate data to plot, and the drawing's CRS/units
- The drawing convention: layer names, symbol sizes (圆半径/十字/字高), text styles
- Whether the output is a DWG, a DXF, a printed PDF, or an area statistics table
- Whether non-measured (补充/非实测) data is included — if so, it needs the project's caveat text

## AutoLISP surveying toolkit (Chinese, ready to use)

**Repo**: `Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD`
(<https://github.com/Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD>) — 未声明许可,最后推送 2019-08-31,
5★。主文件 `zzACAD16ToolBox.lsp`（41 KB）,编译版 `zzACAD16ToolBox.VLX`,另有 `zzAreaTable(面积统计列表).lsp`。

**编码事实（已用权威 blob 核实）**：仓库 `main` 分支的 LISP 是 **GBK/GB18030 编码**
（blob 41215 字节）。按 GB18030 解码得 **1380 个可读汉字**；按 UTF-8 直读只剩 16 个 → 乱码。
AutoCAD 按 ANSI 代码页读 LISP，所以**原文件可直接加载**。

**⚠️ 先诊断再转码**：把「用 UTF-8 读一遍再写回」当修复会制造**双重 mojibake**，把好文件弄坏。
用附带脚本 `scripts/fix_cad_lsp_mojibake.py`（自动判定 GBK 原文 / 双重乱码，统一输出 GB18030 字节）：

```powershell
python scripts\fix_cad_lsp_mojibake.py "<PATH>/zzACAD16ToolBox.lsp" "<PATH>/norm.lsp"
```

实测：两种输入均得 `CJK readable = 1380`、`1523/1523` 括号配对、输出 AutoCAD 可加载。

加载时还需处理 SECURELOAD：`SECURELOAD=1`（默认）会弹「安全性 - 未签名的可执行文件」
模态框，导致所有 COM 调用被拒（`-2147418111 Call was rejected by callee`）。
脚本内用 `(setq sl (getvar "SECURELOAD")) (setvar "SECURELOAD" 0)` → load → 恢复 即可。

主文件命令（所有命令以 `ZZ` 开头，加载后在命令行输入 `ZZ` 可列出菜单）。
**LISP 符号名是 `C:zzArea` 这种形式**（小写 `c:` 前缀 + 原命令名），命令名才是大写 `ZZzzArea`：

| 命令 | 作用 |
|---|---|
| `ZZzzArea` / `ZZzzA` | 面积标注（拾取封闭面或对象） |
| `ZZzzArea2Table` | 面积写入 ACAD Table（可与字段联动编号与对象） |
| `ZZzzArea2File` | 面积写入文件 |
| `ZZzzBC` | 方格网/地形图坐标方格网数据 |
| `ZZzzDcx` | 调用 VBA 描述码集（`acad.dvb`，需 AutoCAD 安装目录） |

**实测警告 — 交互命令会阻塞整个 COM 命令队列**：在 AutoCAD 2025 上实测确认，`(zzArea)` 一旦发送，
AutoCAD 进入拾取等待状态，后续所有 `SendCommand` 全部排队不执行，且 `acad.Documents` 会抛
`TypeError: This object does not support enumeration`，COM 对象进入半失效状态，只能
`Stop-Process -Name acad -Force` 恢复。

对策：
- 交互式命令（`ZZzzArea` 等）**必须在可见 AutoCAD 窗口中人工操作**，不要写进 COM 脚本。
- 脚本里加载 LISP 后，只做**非交互**调用（写文件、写变量）。
- 确认 LISP 是否加载成功：不要用 `vl-symbol-function` / `fboundp`（对 `C:zzArea` 会抛错并
  **中断整个 progn 表达式**，导致同表达式后续 `write-line` 全部不执行、marker 文件为空）。
  用 `vl-catch-all-apply (quote eval) (list (read "C:zzArea"))` 逐个探测
  （`references/cad-toolkit.md` 第 2.2 节有完整可用的表达式）。
- AutoCAD 忙碌时 COM 调用返回 `-2147418111 Call was rejected by callee`，需带退避重试；
  并优先用早期绑定 `gencache.EnsureDispatch('AutoCAD.Application')`（`references/cad-toolkit.md` 第 2.5 节）。
- 队列卡住时先 `doc.SendCommand('\x1b\x1b\x1b')` 发 ESC 中断。

**实测已验证可用**（本机 AutoCAD 2025，加载的文件字节与仓库 `main` 权威 blob 一致）：
`C:zzArea`、`C:zzArea2Table`、`C:zzArea2File`、`C:zzFGW`、`C:zzBC`、`C:zzExport2Dat` 全部 DEFINED。

**⚠️ 实测陷阱**：反复启停 AutoCAD 后可能出现「命令通道整体失效」——COM 属性读取
（`Documents.Count`/`ActiveDocument`/`CMDACTIVE`）**全部正常**，窗口可见无模态框，
但**任何 `SendCommand` 都静默失效**，`doc.Activate()`、`SetForegroundWindow`、
模拟键盘事件均无效。**不要用属性读取正常来推断命令通道正常。**
对策：先用一个极简探针（写一个 1 行文件）确认通道；失效则重启 acad 进程。
详见 `references/cad-toolkit.md` 第 2.6 节。


配套独立文件：

| 文件 | 作用 |
|---|---|
| `CASS2POINT.lsp` / `CASS-Export2Dat.lsp` | CASS 碎部点 → 点文件 / DAT 导出 |
| `CorrectElevation.lsp` | 高程改正 |
| `标尺(不带水平标尺)-QinDong-2003.lsp` | 标尺绘制 |
| `zzAreaTable(面积统计列表).lsp` | 面积统计列表 |

**许可注意**：仓库 README 声明"部分代码采用了网上收集的代码，在此基础上作了部分修改"，且源自
Lee Mac 的公开 AutoLISP 套件（`www.lee-mac.com`，Copyright ©2011，AreaLabel v1.9）。
**直接复制其源码进商业项目前需确认授权**；作为参考实现学习、或在你的工程中重写等价逻辑则无碍。

### 在本项目中落地的方式

不要直接改 `<PROJECT_DIR>` 下的成果图。用 AutoCAD COM 加载 LISP 到一个**副本**上执行：

```python
import win32com.client
acad = win32com.client.GetActiveObject('AutoCAD.Application')   # 或 Dispatch 冷启动
doc = acad.Documents.Open(SRC)          # 先 SaveAs 到新路径，再操作
doc.SendCommand('(load "C:/path/zzACAD16ToolBox.lsp")\n')
doc.SendCommand('(ZZzzArea)\n')        # 命令行交互型命令需人工点选
```

`ZZzzArea` 是**交互式拾取**命令（等你在图上点选封闭边界），无法纯脚本化批量执行。
若目标是批量出图，优先用 `ezdxf` 直接写几何与文字，再按需要导入 AutoCAD 出图。

## AutoCAD MCP server 选项（评估结论）

| 仓库 | 星标 | 许可 | 适配本机（AutoCAD 2025） |
|---|---|---|---|
| `puran-water/autocad-mcp` | 656 | MIT | ⚠️ File IPC 后端要求 **AutoCAD LT 2024+**（AutoLISP 从 LT 2024 才支持）；本机是完整版 AutoCAD 2025，非 LT → **File IPC 后端不可用**，仅 **ezdxf 无头后端**可用 |
| `U-C4N/Autocad-MCP` | 306 | MIT | ✅ 双后端（COM + ezdxf），**COM 后端适配本机完整版 AutoCAD**；约 250 工具，含 layers/实体/布局/标注/算量 |
| `beiming183-cloud/AutoCAD-skills` | 22 | MIT | GB/T 机械制图 skill 集合（含 `README.zh-CN.md`），**偏机械制图非测绘出图**，可借鉴 skill 组织方式 |
| `thepiruthvirajan/autocad-mcp-server` | 70 | — | 覆盖绘图/编辑/查询/标注/布局/打印/3D 实体 |
| `LokmenoWer/best-cad-mcp` | 47 | — | 含 GB/T 机械 CAD skill，含 DRC 与安全门禁 |
| `puran-water/autocad-drafting` | 1 | — | **已归档**，并入 PuranOS；但其 `SKILL.md` 是 AutoCAD MCP 的**skill 范式样板**，值得读 |

**结论**：本机已有 AutoCAD COM 直连能力（见 autocad-ops），**当前不必引入 AutoCAD MCP**——
COM 已在用且验证通过。若将来需要 250+ 工具与现成 CAD 工作流，优先评估 `U-C4N/Autocad-MCP`
（MIT、双后端、适配完整版 AutoCAD）。

**引入任何 AutoCAD MCP 前必查**：该仓库含 `security.py`（26 KB）、`security_lisp.py`（38 KB）、
`policy.py`（11 KB）、`http_guard.py`——说明该领域存在 LISP 注入与越权风险面，须先审这几份文件。

## AutoLISP 实战陷阱（来自 `autocad-drafting` skill 的实战总结）

| 陷阱 | 原因 | 对策 |
|---|---|---|
| **绝不要并行调用 AutoCAD 工具** | File IPC 单线程，并发会交错 `PostMessageW` 键盘事件，触发 APPLOAD 对话框与超时 | 严格串行调用 |
| 批量超时 | 批次过大或命令在等待输入 | 单批 ≤ 7 个命令、≤ 500 行；超时默认 10 s |
| 命令卡死 | 上次超时把 AutoCAD 留在命令提示行 | 发命令前补 ESC 前缀 |
| **`_TEXT` / `_SOLID` 卡住** | `(command "_TEXT" "J" "ML" ...)` 的提示序列不可靠，会让 AutoCAD 进入等待输入状态 | **改用 `entmake`**，完全不碰命令行 |
| `SECURELOAD` 弹窗 | `(load)` 不受信任路径 | `(setvar "SECURELOAD" 0)` → load → 恢复为 1 |
| 非 ASCII 崩溃 | LISP 写 cp1252，Python 读 UTF-8 | 读 LISP 文件按 GB18030；文本写入注意编码 |
| `drawing.create` 重置图 | 该操作会清空并 purge 当前图（**不是** `_.NEW`） | 会话作用域内不要调用 |

### entmake 文本注记模板（比 command 可靠）

```lisp
(progn
  (setvar "CLAYER" "ANNOTATION")
  (defun make-tag (x y tag desc ht /)
    (entmake
      (list '(0 . "TEXT") (cons 10 (list x y 0)) (cons 40 ht)
            (cons 1 tag) (cons 72 1) (cons 11 (list x y 0)) '(8 . "ANNOTATION")))
    (entmake
      (list '(0 . "TEXT") (cons 10 (list x (- y (* ht 1.3)) 0))
            (cons 40 (* ht 0.7)) (cons 1 desc) (cons 72 1)
            (cons 11 (list x (- y (* ht 1.3)) 0)) '(8 . "ANNOTATION"))))
  (make-tag 10 25 "TP-1" "水准点 TP-1" 2.2)
  "annotations placed"
)
```

`(cons 72 1)` 是右中对齐；`(cons 11 ...)` 给第二对齐点。字高 2.2、圆半径 1.2、十字 1.2
是本项目成果图的既有约定，改动前先核对现有图元。

## 出图流程（测绘场景）

1. **确认基准与单位**：EPSG:4547，m，E 在前 N 在后；高程 1985 基准。图纸单位与实地米的换算
   （如 1:500 图 1 mm = 0.5 m）必须明确。
2. **建图层**：先建层再画几何。数据层与注记层分离，非实测数据单独成层并命名带"非实测"。
3. **写几何**：地形点用 `POINT`、房屋轮廓用闭合 `LWPOLYLINE`、水系用 `PLINE`。
4. **写注记**：`entmake` 的 `TEXT` / `MTEXT`，字高与对齐按图面约定。
5. **出成果表**：`INSERT` + 表格，或 `zzArea2Table` 类命令；表头与数值格式与成果表一致。
6. **加图廓与技术说明**：图名、坐标系、高程基准、比例尺、非实测说明块。
7. **校验**：重新打开，核对点数/面积/坐标；截图复核。
8. **出图**：`PLOT` 到 PDF（`ezdxf` 后端无此能力，须在 AutoCAD 中执行）。

## Output contract

- 报告输出路径（DWG / DXF / PDF）、新增实体数、最终实体总数。
- 注明坐标系与单位；面积注明计算方式（是否含闭合容差）与单位（m² 或 ha）。
- 明确说明图内是否含非实测数据及其标注方式。

## Failure handling

- **LISP 加载报乱码** → 按 GB18030 读取文件内容再写回；不要用 UTF-8 直读。
- **`APPLOAD` 弹窗卡住** → 不要并行调用；检查是否有上一条命令在等待输入。
- **面积标注结果为空** → 拾取的多段线未闭合；面积计算要求闭合环。
- **需要批量出图** → 交互式命令（如 `ZZzzArea`）不可批量化，改用 ezdxf 直接写几何。
- **改了成果图** → 先确认：源文件不得覆盖，一切操作在副本上进行。

## Examples

Input: "给碎步成果图加一个面积统计表"
Output: 确认源图 → SaveAs 副本 → 用 ezdxf 读取闭合多段线并计算面积 → entmake 写统计表
→ 写明坐标系与单位 → 重新打开校验表内数值。

Input: "用现成的测量工具包计算图上每个地块的面积"
Output: 加载 `zzACAD16ToolBox.lsp`（注意 GB18030）→ `ZZzzArea` 交互拾取 → `ZZzzArea2Table` 入表
→ 导出 DXF 复核。注意该命令交互式，一次只能处理一个面。
