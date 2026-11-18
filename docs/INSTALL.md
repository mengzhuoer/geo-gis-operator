# 安装与验证

## 一、安装

### 前置

- MiniMax Code(需支持 agent 与 skill)
- 目标机器已装好所需 GIS 软件(见 README「前置条件」)

### 步骤

**1. 创建智能体**

在 MiniMax Code 内执行:

```text
mavis({ command: "agent create",
        args: { name: "geo-gis-operator",
                display_name: "地理空间操作员",
                description: "Operates ArcGIS Pro, QGIS, AutoCAD and Google Earth Engine for surveying and geospatial production work, backed by a built-in surveying/remote-sensing knowledge base." } })
```

**2. 覆盖文件**

把本仓库 `agent/` 目录下的 `agent.md`、`config.yaml`、`skills/` 复制到:

```text
%USERPROFILE%\.minimax\agents\geo-gis-operator\
```

也可以整体复制:

```powershell
Copy-Item -Recurse .\agent "$env:USERPROFILE\.minimax\agents\geo-gis-operator"
```

**3. 清理运行时绑定(仅当目标目录已有该文件)**

```text
.agent-instance-id
```

这是本机运行时实例绑定,必须由目标机器的运行时重新生成。

**4. 按本机情况改三处**

| 位置 | 改什么 |
|---|---|
| `agent/agent.md` frontmatter | `defaultWorkspaceDir` → 你的项目目录。**出厂为空字符串**——占位符(如 `<PROJECT_DIR>`)不是合法绝对路径,运行时 会以 `AGENT_CONFIG_INVALID` 拒绝加载整个智能体,所以必须填真实绝对路径或保持为空 |
| `agent/agent.md`「Environment facts」表 | 软件版本与路径 → 你机器上的实际值 |
| `agent/skills/geo-knowledge-base/references/project-conventions.md` | 坐标系、坐标序、方位角定义、图层命名规则 |

第 3 项尤其重要:**这四项错了,智能体产出的成果会系统性出错**,且不会报错。

**5. 验证**

```powershell
mavis agent list                      # 应出现 geo-gis-operator
mavis agent get --name geo-gis-operator
```

技能在**下一个会话**生效,无需重启运行时。

---

## 二、装完后的自检

开一个新会话,让智能体依次加载六个技能:

| 技能 | 期望 |
|---|---|
| `qgis-ops` | 加载成功,`references/mcp-tools-reference.md` 可读(125 个工具) |
| `arcgis-ops` | 加载成功,`references/arcgis-learning.md` 可读 |
| `autocad-ops` | 加载成功 |
| `cad-survey-drawing` | 加载成功,`references/cad-toolkit.md` 与 `scripts/fix_cad_lsp_mojibake.py` 可读 |
| `gee-ops` | 加载成功 |
| `geo-knowledge-base` | 加载成功,`spectral-indices.md` 可读(332 个指数) |

### QGIS 联通性检查

QGIS MCP 需要**桌面端运行**。若调用报传输错误:

```powershell
Start-Process -FilePath 'C:\Program Files\QGIS 3.44.14\bin\qgis-ltr-bin.exe' `
              -WorkingDirectory 'C:\Program Files\QGIS 3.44.14\bin'
```

等窗口起来后 `ping` 应返回 `{"pong": true}`。

---

## 三、常见问题

**Q. 装完技能列表里看不到?**
A. 技能在下一个会话生效,开新会话即可;无需重启运行时。

**Q. QGIS 调用全部报传输错误?**
A. 桌面端没开。MCP 服务端进程在跑不代表桥接通——桥接要 QGIS 桌面端注册 TCP 9876。

**Q. `layer.find` 返回 0 层?**
A. 本构建里**空 `name_pattern` 不等于匹配全部**,改用通配符如 `*已知控制点*`。

**Q. `features.get` 报错?**
A. 本构建的已知缺陷,对所有图层都失败。改用 `query.sql`(`SELECT count(*) AS n FROM "图层名"`)
或 `features.get_statistics`。

**Q. arcpy 报 `ModuleNotFoundError`?**
A. 用错了解释器。arcpy 只在 Pro 自带的
`C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe` 里。

**Q. AutoCAD COM 调用被拒(`-2147418111`)?**
A. AutoCAD 弹了模态框(常见是 SECURELOAD 的「安全性 - 未签名的可执行文件」)。
先关对话框;加载 LISP 时用
`(setq sl (getvar "SECURELOAD")) (setvar "SECURELOAD" 0)` → load → 恢复。

**Q. AutoCAD 命令发出去没反应?**
A. 可能处于「命令通道整体失效」:属性读取正常但 `SendCommand` 静默失败。
先跑极简探针(写一个 1 行文件)确认通道;失效则重启 acad 进程。
**不要用属性读取正常来推断命令通道正常。**

**Q. 从 GitHub 拿的中文 LISP 加载后中文乱码?**
A. 用随技能附带的脚本先诊断再处理:

```powershell
python skills\cad-survey-drawing\scripts\fix_cad_lsp_mojibake.py <源.lsp> <输出.lsp>
```

它会判定是 GBK 原文还是双重 mojibake,并统一输出 AutoCAD 可加载的 GB18030 字节。
**不要用「UTF-8 读一遍再写回」当修复**——那会把好文件弄坏。

---

## 四、安全边界

- 本智能体**不会**代输 Google / ArcGIS 账号密码。
- 分析类操作自动执行;写操作、对外发布、消耗配额的导出需先确认。
- 默认工作区之外不做写操作。
- 引入第三方 MCP 前先审 `security.py` / `policy.py` / `.env.example`。
