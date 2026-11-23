# 跨客户端兼容性

## 一、为什么这些技能能通用

**Agent Skills 是开放标准**,不是某个厂商的私有格式。一个技能就是一个目录:

```
<skill-name>/
├── SKILL.md      # 必需:YAML frontmatter + Markdown 指令
├── scripts/      # 可选:可执行脚本
├── references/   # 可选:按需加载的参考文档
└── assets/       # 可选:模板与静态资源
```

frontmatter 只有**六个**规范字段:

| 字段 | 必需 | 约束 |
|---|---|---|
| `name` | 是 | 1–64 字符,小写字母数字连字符,**必须与目录同名** |
| `description` | 是 | ≤1024 字符,非空;**触发场景写第一句** |
| `license` | 否 | 许可名或指向许可文件 |
| `compatibility` | 否 | ≤500 字符,环境要求说明 |
| `metadata` | 否 | 任意键值对(建议键名唯一,避免冲突) |
| `allowed-tools` | 否 | 预授权工具,**实验性,各客户端行为不一致** |

正文无格式限制。

**本仓库的六个技能全部符合规范**,且刻意做了两件事:

1. **触发词前置** —— 描述第一句就说"什么场景该用我"。
   规范明确指出:目录预算紧的客户端(如 Codex)可能截断描述,触发句必须扛得住截断。
2. **不用 `allowed-tools`** —— 规范标注为实验性,跨客户端行为不一致,故省略。

`skills-ref validate <目录>` 可校验规范(官方参考校验器)。

---

## 二、各客户端的技能扫描目录

`.agents/skills/` 是**跨客户端约定目录**,越来越多客户端在向它收敛。

| 客户端 | 项目级 | 用户级 |
|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| Codex | `.codex/skills/` | `~/.codex/skills/` |
| Cursor | `.cursor/skills/`、`.agents/skills/` | `~/.cursor/skills/`、`~/.agents/skills/` |
| VS Code / Copilot | `.github/skills/`、`.agents/skills/` | `~/.copilot/skills/`、`~/.claude/skills/`、`~/.agents/skills/` |
| Gemini CLI | `.gemini/skills/`、`.agents/skills/` | `~/.gemini/skills/`、`~/.agents/skills/` |
| OpenCode | `.opencode/skills/`、`.claude/skills/`、`.agents/skills/` | `~/.config/opencode/skills/`、`~/.claude/skills/`、`~/.agents/skills/` |
| Windsurf | — | `~/.codeium/windsurf/skills/`、`~/.agents/skills/` |

**注意**:多数客户端会**同时**扫描 Claude 与 Codex 的目录。所以放在
`.agents/skills/` 或 `.claude/skills/`,往往一次就覆盖多个客户端。

本仓库把 `.agents/skills/` 作为**单一源**,安装脚本负责分发到各客户端目录。

---

## 三、装法

```powershell
# 自动检测本机已装的客户端并安装(项目级)
.\scripts\install.ps1

# 只装指定客户端
.\scripts\install.ps1 -Target claude,codex

# 用户级(所有项目可用)
.\scripts\install.ps1 -UserScope

# 只看会做什么
.\scripts\install.ps1 -DryRun
```

脚本**只复制技能目录**,不碰任何客户端配置文件。
MCP 配置请手动粘贴 [`MCP-CONFIG.md`](MCP-CONFIG.md) 里的片段。

---

## 四、能力矩阵:各客户端实际能做到什么

技能是"知识与流程",MCP 是"能碰到哪个软件"。**没有 MCP 的部分,只有流程没有执行能力。**

| 技能 | 需要的执行通路 | 无 MCP 时会怎样 |
|---|---|---|
| `qgis-ops` | **QGIS MCP** | ❌ 完全不可用——所有操作都要 MCP |
| `arcgis-ops` | arcpy(Pro 自带 Python) | ✅ 不需要 MCP,脚本直接跑 |
| `autocad-ops` | AutoCAD COM / ezdxf | ✅ 不需要 MCP |
| `cad-survey-drawing` | AutoLISP / ezdxf | ✅ 不需要 MCP |
| `gee-ops` | 浏览器自动化 | ⚠️ 依赖全局 `gee-export-automation` 技能 |
| `geo-knowledge-base` | 无 | ✅ 纯知识,任何客户端都能用 |

**结论**:
- 想要**完整能力**,至少要配好 QGIS MCP。
- 只想要**知识问答 + 文档/表格处理**,零配置即可用(复制技能目录就行)。
- ArcGIS 与 AutoCAD 两条线**不依赖任何 MCP**,装好软件就能跑。

### GEE 的额外依赖

`gee-ops` 技能本身不含浏览器自动化细节,它复用全局的 `gee-export-automation` 技能。
若目标客户端没有这个技能,需一并安装:

```powershell
git clone <gee-export-automation 的仓库> <目标>/skills/gee-export-automation
```

---

## 五、不可移植的部分(诚实清单)

技能**格式**完全通用,但**内容**里有几处绑定特定环境:

| 内容 | 位置 | 换机器要做什么 |
|---|---|---|
| 软件安装路径 | `agent.md` Environment facts 表、各技能里的 `C:\Program Files\...` | 改成本机路径,或先探测再替换 |
| QGIS MCP 服务端路径 | `docs/MCP-CONFIG.md` 各片段 | 改成本机 `qgis-mcp-server.exe` 位置 |
| 项目目录 | `agent.md`、`project-conventions.md` | 改成本项目路径 |
| 模型配置 | `agent/config.yaml` | MiniMax Code 专属,其他客户端忽略 |

**这些是有意保留的**:它们是"怎么把这套东西真正跑起来"的操作信息,
抹掉反而会让技能变成空话。规范所说的"不可移植"指的是**硬编码某个客户端专有工具名**
(比如只对 Claude 有效的斜杠命令),而不是"写了具体路径"。

本仓库已做过一轮清理:所有本机绝对路径已参数化为 `<PROJECT_DIR>` 等占位符,
且技能正文里**没有**任何 `mcp__qgis__` / `mavis(...)` 之类的厂商专有调用
(QGIS 技能的工具名以 `project` / `layer` / `features` 这类**中性分组名**表述,
任何 MCP 客户端都能对上)。

---

## 六、跨客户端的 MCP 配置差异(最容易踩的坑)

| 客户端 | 根键 | 文件位置 |
|---|---|---|
| Claude Code | `mcpServers` | `~/.claude.json`、项目 `.mcp.json` |
| Codex | `[mcp_servers.<name>]`(TOML) | `~/.codex/config.toml` |
| Cursor | `mcpServers` | `~/.cursor/mcp.json`、项目 `.cursor/mcp.json` |
| VS Code / Copilot | `mcpServers` | `~/.copilot/mcp-config.json`、工作区 `.mcp.json` |
| Gemini CLI | `mcpServers` | `~/.gemini/settings.json` |
| Windsurf | `mcpServers` | `~/.codeium/windsurf/mcp_config.json` |
| OpenCode | `mcp` | `~/.config/opencode/opencode.json` |

**VS Code 的例外**:`.vscode/mcp.json`(Local harness)用 `servers` 根键,
但该 harness 已被弃用(2026-11-11 弃用,2027-02 移除),默认 Copilot harness 不直接读它。
请用 `~/.copilot/mcp-config.json` 或工作区 `.mcp.json`。

详见 [`MCP-CONFIG.md`](MCP-CONFIG.md)。

---

## 七、实测记录

| 验证项 | 结果 |
|---|---|
| 六个技能的 frontmatter 解析 | ✅ 全部符合规范(name 合规、描述 ≤1024、触发句前置) |
| `scripts/install.ps1` 幂等性 | ✅ 重复运行不报错,覆盖式安装 |
| 自动客户端探测 | ✅ 本机识别出 claude / codex / copilot / vscode |
| 安装后文件一致性 | ✅ 45 个文件在三个客户端目录中 sha256 完全一致 |
| **Claude Code 2.1.220 实测** | ✅ **独立发现全部 6 个技能**,description 首句与源文件逐字一致 |
| Claude Code 读取 references | ✅ 正确读出 332 个指数、S2 的 NIR=B8 / SWIR1=B11 / SWIR2=B12、水体类 34 个,并正确标注引用来源 |
| Codex 技能发现 | ✅ 技能已装入 `~/.codex/skills/`(Codex 从该目录扫描);本机 Codex 仅有桌面版,无 CLI 可做命令行验证 |
| 跨客户端 frontmatter 兼容性 | ✅ 同一份 SKILL.md 被两个不同厂商的客户端正确解析 |

**最关键的一条**:Claude Code 在**完全独立的运行时**里,读的是我们发布的
`.agents/skills/` 里的同一份文件,却给出了正确的领域答案——这证明技能包是真的可移植,
而不是"在本客户端里凑巧能用"。
