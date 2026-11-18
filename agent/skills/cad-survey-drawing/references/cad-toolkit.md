# AutoCAD 测绘出图参考

## 一、中文测量工具集文件清单

来源：`Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD`（未声明许可，最后推送 2019-08-31）

| 文件 | 大小 | 作用 | 括号配对 |
|---|---|---|---|
| `zzACAD16ToolBox.lsp` | 41215 B | 主工具箱：`ZZzzArea`/`ZZzzA`、`ZZzzArea2Table`、`ZZzzArea2File`、`ZZzzFGW`、`ZZzzBC`、`ZZzzQydx`、`ZZzzQywdx`、`ZZzzExport2Dat`、`ZZzzDcx` | 1523/1523 ✓ |
| `zzAreaTable(面积统计列表).lsp` | 18.8 KB | 面积统计列表 | 719/719 ✓ |
| `CorrectElevation.lsp` | 3.4 KB | 高程改正 | 106/106 ✓ |
| `CASS-Export2Dat.lsp` | 1.9 KB | CASS 数据导出 DAT | 89/89 ✓ |
| `CASS2POINT.lsp` | 0.4 KB | CASS 转点文件 | 28/28 ✓ |
| `标尺(不带水平标尺)-QinDong-2003.lsp` | 5.1 KB | 标尺绘制 | — |
| `zzACAD16ToolBox.VLX` | 22.1 KB | 主工具箱编译版 | — |

（括号配对为实际下载后校验结果，全部平衡。主文件权威 blob sha256 `940c64a3f361d14ea85eb19ba9404eb45802f275db9dc9836059bcca1824e0cd`。）

### 获取方式

```powershell
gh api 'repos/Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD/contents/zzACAD16ToolBox.lsp' --jq '.content'
# PowerShell 中把 base64 解码后按 GB18030 写回
```

**编码事实（已用权威 blob 核实）**：仓库 `main` 分支的 `zzACAD16ToolBox.lsp` 是
**GBK/GB18030 编码**，blob 大小 **41215 字节**，sha256 `940c64a3f361d14ea85eb19ba9404eb45802f275db9dc9836059bcca1824e0cd`。

- 按 GB18030 解码：**1380 个汉字，全部可读**（如「功能：生成地形图方格网数据文件」「面积序号起始值」）
- 按 UTF-8 直读：仅 16 个可识别汉字 → 乱码

AutoCAD 在简体中文 Windows 上按 ANSI 代码页（GBK）读 LISP，所以**原文件本身可以直接加载**。
真正的问题在用 UTF-8 读写它的人身上。

**⚠️ 务必先诊断再转码**：如果你把「用 UTF-8 读一遍再写回」当成修复，会得到
**双重 mojibake**（UTF-8 文本被当 GBK 解码后又存成 UTF-8），把本来好的文件弄坏。
用附带脚本 `scripts/fix_cad_lsp_mojibake.py`，它会先测量再决定：

```powershell
python scripts\fix_cad_lsp_mojibake.py "<PATH>/zzACAD16ToolBox.lsp" "<PATH>/norm.lsp"
```

实测两种输入的输出：

```
# 输入 GBK 原文（41215 字节）
diagnosis  : gb18030   CJK readable = 1380
parens     : 1523 open / 1523 close -> BALANCED

# 输入双重 mojibake（42652 字节）
diagnosis  : utf8      CJK readable = 1380
parens     : 1523 open / 1523 close -> BALANCED
```

脚本统一输出 **GB18030 字节**，AutoCAD 可直接 APPLOAD / load。


## 二、实测：加载方式、编码修复与命令验证

本机 AutoCAD 2025 + COM 上逐项实测（2026-11-17）。

### 2.1 加载：必须处理 SECURELOAD

`(load "...")` 在 `SECURELOAD=1`（默认）时会弹出 **「安全性 - 未签名的可执行文件」** 对话框
（窗口类 `#32770`，标题即该字符串）。这个模态框会让 AutoCAD 拒绝所有 COM 调用，
表现为 `pywintypes.com_error: (-2147418111, 'Call was rejected by callee')`，重试也无效。

两种可靠做法：
1. **临时关闭 SECURELOAD**（脚本内最省事）：
   ```lisp
   (setq sl (getvar "SECURELOAD")) (setvar "SECURELOAD" 0)
   (load "C:/path/zzToolBox_repaired.lsp")
   (setvar "SECURELOAD" sl)
   ```
2. 把目录加入 `TRUSTEDPATHS`（一次配置，长期免弹窗）。

### 2.2 命令验证：不要用 `vl-symbol-function`

实测踩坑：`vl-symbol-function` 与 `fboundp` 对 `C:zzArea` 这类命令符号会**抛错并中断整个
`progn` 表达式**，导致同表达式里后续的 `write-line` 全部不执行（marker 文件被创建但为空）。
`vl-catch-all-apply` 包住也仍然中断。

**可靠做法** —— 用 `eval` + catch-all 逐个探测：

```lisp
(progn
  (setq sl (getvar "SECURELOAD")) (setvar "SECURELOAD" 0)
  (load "C:/path/zzToolBox_repaired.lsp")
  (setvar "SECURELOAD" sl)
  (setq f (open "C:/path/sym_ok.txt" "w"))
  (foreach s (list "C:zzArea" "C:zzArea2Table" "C:zzArea2File"
                    "C:zzFGW" "C:zzBC" "C:zzExport2Dat")
    (setq r (vl-catch-all-apply (quote eval) (list (read s))))
    (write-line (strcat s "=" (if (vl-catch-all-error-p r) "ERROR" "DEFINED")) f))
  (close f) (princ "\n"))
```

符号名是 **`C:zzArea`**（小写 `c:` 前缀 + 原命令名），不是 `zzArea`，也不是大写的 `ZZzzArea`。
AutoCAD 命令名由 `C:` 符号派生。

实测结果（本机已验证）：

```
C:zzArea=DEFINED       C:zzArea2File=DEFINED    C:zzBC=DEFINED
C:zzArea2Table=DEFINED C:zzFGW=DEFINED          C:zzExport2Dat=DEFINED
```

### 2.3 实测：交互式命令会阻塞整个 COM 命令队列

本机 AutoCAD 2025 上实测（COM 启动的实例）：

1. `(load ...)` —— **加载成功**，无报错（`LOAD_OK`）。
2. `(zzArea)` —— 发送成功，但因 `zzArea` 是**拾取交互**命令，AutoCAD 进入等待拾取状态，
   后续所有 `SendCommand` 全部排队不执行。
3. 此时 `acad.Documents` 抛出 `TypeError: This object does not support enumeration`，
   `acad.Documents.Count` 抛 `AttributeError` —— **COM 对象进入半失效状态**，
   只能靠 `Stop-Process -Name acad -Force` 恢复。

### 2.4 结论与对策

| 场景 | 做法 |
|---|---|
| 用 `ZZzzArea` 等交互命令 | **必须在可见 AutoCAD 窗口中人工操作**，不要走 COM 脚本 |
| 批量出图 | 一律走 ezdxf 写几何 → 导入 AutoCAD 出图，不依赖交互命令 |
| COM 脚本里加载 LISP 后 | 只做**非交互**调用（写文件、写变量）；绝不触发拾取类命令 |
| 命令队列卡住时 | 先 `doc.SendCommand('\x1b\x1b\x1b')` 发 ESC 中断；无效则重启 acad 进程 |

### 2.5 实测：COM 调用需要重试与早期绑定

AutoCAD 忙碌时 COM 调用返回 `(-2147418111, 'Call was rejected by callee')`。用带退避的重试：

```python
def retry(fn, tries=40, delay=0.75):
    for i in range(tries):
        try:
            return fn()
        except Exception:
            if i == tries - 1:
                raise
            time.sleep(delay)
```

另注：动态绑定 `win32com.client.Dispatch` 在某些状态下 `Documents.Count` 会抛
`AttributeError: '<unknown>' object has no attribute 'Count'`；
用早期绑定 `win32com.client.gencache.EnsureDispatch('AutoCAD.Application')`
可拿到强类型对象（`IAcadDocuments`），行为稳定得多。

### 2.6 实测陷阱：AutoCAD 命令通道可能整体失效

在反复启停 AutoCAD 之后，观察到过这样一组现象：

- `acad.Documents.Count`、`ActiveDocument`、`CMDACTIVE`、`CMDNAMES` **全部正常**
  （`CMDACTIVE=0`、`CMDNAMES=''`，即命令行为空闲态）
- 主窗口可见、无 `#32770` 模态框、文档可写（`ReadOnly=False`）
- 但 **任何 `SendCommand` 都静默失效** —— 最简的 `(setq f (open "..." "w")) (write-line "X" f)`
  也不产生文件；`doc.Activate()`、`SetForegroundWindow`、甚至模拟键盘事件（`keybd_event`）
  全部无效

**处置**：
- 先用一个**极简探针**确认通道是否通（写一个 1 行文件），再决定是否继续加载 LISP；
  不要在通道已死时反复加载并等待，那只会浪费时间。
- 通道失效时**重启 acad 进程**（`Stop-Process -Name acad -Force` 后重新启动），
  恢复后再试；若仍不通，多半需要人工在窗口里点一下绘图区。
- 这个状态下 COM 属性读取仍正常，**不要用属性读取正常来推断命令通道正常** —— 这两件事是独立的。

### 2.7 小结：命令在 AutoCAD 2025 中真实可用

以下结论在**同一台机器、同一 AutoCAD 2025** 上实测通过（加载文件字节 sha256
`940c64a3f361d14ea85eb19ba9404eb45802f275db9dc9836059bcca1824e0cd`，与仓库 `main`
分支权威 blob 完全一致）：

```
LOAD_OK
C:zzArea=DEFINED       C:zzArea2File=DEFINED    C:zzBC=DEFINED
C:zzArea2Table=DEFINED C:zzFGW=DEFINED          C:zzExport2Dat=DEFINED
```



## 三、本项目成果图的既有约定

来自 `<PROJECT_DIR>/scripts/add_h_to_pointmap.py` 等已验证脚本：

| 项 | 值 |
|---|---|
| 圆半径 | 1.2（图纸单位） |
| 十字尺寸 | 1.2 |
| 字高 | 2.2 |
| 注记偏移 | 按点间距单独调整（两相邻点仅相距 3.8 m，需错开） |
| 图层命名 | 数据层 `补充h点_非实测`、注记层 `补充h点注记_非实测`、表格层 `补充成果表_非实测` |
| 成果表列 | 点号 / X / Y |
| 表位置 | TABLE_X1=382099.78, TABLE_X2=382197.78, ROW_TOP=4180236.0, ROW_STEP=6.5 |

新增符号前先核对现有图元的图层与样式，保持一致。

## 四、entmake 速查（比 command 可靠）

```lisp
;; 点
(entmake (list '(0 . "POINT") (cons 10 (list x y 0)) '(8 . "图层名")))

;; 闭合多段线
(entmake (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") '(8 . "图层名")
                '(100 . "AcDbPolyline") '(90 . 3) '(70 . 1)
                (cons 10 p1) (cons 10 p2) (cons 10 p3)))

;; 单行文字（右中对齐）
(entmake (list '(0 . "TEXT") (cons 10 (list x y 0)) (cons 40 ht)
                (cons 1 "内容") (cons 72 1) (cons 11 (list x y 0)) '(8 . "图层名")))

;; 多行文字
(entmake (list '(0 . "MTEXT") (cons 10 (list x y 0)) (cons 40 ht)
                (cons 1 "内容") (cons 41 w) (cons 71 1) '(8 . "图层名")))
```

`(cons 72 1)` 右中对齐，`(cons 71 1)` 为 MTEXT 左对齐。**不要用 `(command "_TEXT" ...)`**
——其提示序列不可靠，会让 AutoCAD 卡在等待输入状态。

## 五、许可提示

- `Qin-Dong` 仓库 **未声明许可**，README 声明"部分代码采用了网上收集的代码"，主体源自
  Lee Mac 的公开 AutoLISP 套件（`www.lee-mac.com`，Copyright ©2011，AreaLabel v1.9）。
  **商用或公开分发前需确认授权**；作为学习参考或自行重写等价逻辑则无碍。
- `puran-water/autocad-mcp` 与 `U-C4N/Autocad-MCP` 均为 **MIT**，可放心参考代码；
  但其 LISP 加载涉及 `SECURELOAD` 与外部文件执行，引入前仍需审 `security.py` /
  `security_lisp.py` / `policy.py`。
