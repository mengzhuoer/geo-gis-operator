# MCP 配置:把 GIS 软件接到各客户端

技能负责"怎么做",**MCP 服务端负责"能碰到哪个软件"**。没有 MCP,只有知识与流程;
装了 MCP,技能才能真正驱动 QGIS / ArcGIS / AutoCAD。

> 本页只给**配置片段**,不替你改任何文件。各客户端的配置格式互不相同,
> 复制前请看清「根键名」——用错键名是最常见的"服务器明明装了却连不上"的原因。

---

## 一、你要装哪些 MCP 服务端

| 软件 | MCP 服务端 | 来源 | 必需性 |
|---|---|---|---|
| QGIS | `qgis-mcp` | [nkarasiak/qgis-mcp](https://github.com/nkarasiak/qgis-mcp)(GPL-2.0) | QGIS 技能必需 |
| ArcGIS Pro | — | **本机未注册** | ArcGIS 技能走 arcpy 脚本路线,**不需要 MCP** |
| AutoCAD | — | COM 直连 + ezdxf | **不需要 MCP** |
| GEE | — | 浏览器自动化 | 不需要 MCP(GEE 技能复用全局 `gee-export-automation` 技能) |

**好消息**:四个软件里只有 QGIS 需要 MCP。另外三个的技能包已经写明了直连方式。

### 安装 QGIS MCP

```powershell
git clone https://github.com/nkarasiak/qgis-mcp.git
cd qgis-mcp
uv sync
```

然后在 QGIS 里安装插件 `qgis_mcp_plugin`(插件目录:`%APPDATA%\QGIS\QGIS3\profiles\default\python\plugins\qgis_mcp_plugin`)。

⚠️ **桥接需要 QGIS 桌面端处于运行状态**——插件启动后才会监听 TCP 9876。
MCP 服务端进程在跑 ≠ 桥接通。

---

## 二、各客户端配置片段

### Claude Code

**项目级**(推荐,可随仓库共享,放在仓库根目录 `.mcp.json`):

```json
{
  "mcpServers": {
    "qgis": {
      "command": "D:\\Zcode\\mcp\\qgis-mcp\\.venv\\Scripts\\qgis-mcp-server.exe",
      "args": [],
      "env": {
        "QGIS_MCP_TOOL_MODE": "compound"
      }
    }
  }
}
```

**用户级**(所有项目可用):

```powershell
claude mcp add --scope user qgis -- "D:\Zcode\mcp\qgis-mcp\.venv\Scripts\qgis-mcp-server.exe"
```

> Claude Code 远程服务器需带 `"type": "http"`;stdio 型不需要 `type` 字段。

---

### Codex

Codex 用 TOML,不是 JSON。写进 `~/.codex/config.toml`:

```toml
[mcp_servers.qgis]
command = 'D:\Zcode\mcp\qgis-mcp\.venv\Scripts\qgis-mcp-server.exe'
args = []

[mcp_servers.qgis.env]
QGIS_MCP_TOOL_MODE = "compound"
```

或用命令行:

```powershell
codex mcp add qgis -- "D:\Zcode\mcp\qgis-mcp\.venv\Scripts\qgis-mcp-server.exe"
```

---

### Cursor

项目级 `.cursor/mcp.json` 或用户级 `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "qgis": {
      "command": "D:\\Zcode\\mcp\\qgis-mcp\\.venv\\Scripts\\qgis-mcp-server.exe",
      "args": [],
      "env": {
        "QGIS_MCP_TOOL_MODE": "compound"
      }
    }
  }
}
```

> Cursor 用 `mcpServers` 键;远程服务器写 `url` 而非 `command`。

---

### VS Code / GitHub Copilot

VS Code 1.140+ 推荐用**可移植的 Copilot 配置文件**:

- 用户级:`~/.copilot/mcp-config.json`
- 或工作区根目录 `.mcp.json`(可随团队共享)

根键是 `mcpServers`:

```json
{
  "mcpServers": {
    "qgis": {
      "type": "stdio",
      "command": "D:\\Zcode\\mcp\\qgis-mcp\\.venv\\Scripts\\qgis-mcp-server.exe",
      "args": [],
      "env": {
        "QGIS_MCP_TOOL_MODE": "compound"
      }
    }
  }
}
```

> ⚠️ **不要用 `.vscode/mcp.json`**——那属于 VS Code 的 **Local harness**,
> 已在 2026-11-11 弃用、2027-02 移除;默认的 Copilot harness 不直接读它。
> Local harness 那个文件用 `servers` 根键,而 `.mcp.json` / `mcp-config.json` 用 `mcpServers`,
> **两者不通用**。

---

### Gemini CLI

`~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "qgis": {
      "command": "D:\\Zcode\\mcp\\qgis-mcp\\.venv\\Scripts\\qgis-mcp-server.exe",
      "args": [],
      "env": {
        "QGIS_MCP_TOOL_MODE": "compound"
      }
    }
  }
}
```

---

### Windsurf

`~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "qgis": {
      "command": "D:\\Zcode\\mcp\\qgis-mcp\\.venv\\Scripts\\qgis-mcp-server.exe",
      "args": [],
      "env": {
        "QGIS_MCP_TOOL_MODE": "compound"
      }
    }
  }
}
```

---

### OpenCode

`~/.config/opencode/opencode.json`:

```json
{
  "mcp": {
    "qgis": {
      "type": "local",
      "command": ["D:\\Zcode\\mcp\\qgis-mcp\\.venv\\Scripts\\qgis-mcp-server.exe"],
      "enabled": true,
      "environment": {
        "QGIS_MCP_TOOL_MODE": "compound"
      }
    }
  }
}
```

---

## 三、路径要改成你自己的

上面片段里的 `D:\Zcode\mcp\qgis-mcp\...` 是作者机器的路径。请替换为你实际的
`qgis-mcp-server.exe` 位置。

---

## 四、常见坑

| 现象 | 原因 | 解法 |
|---|---|---|
| 服务器显示已装但工具不可用 | 根键名写错 | `.mcp.json` / `mcp-config.json` 用 `mcpServers`;`.vscode/mcp.json` 用 `servers` |
| 客户端提示 type 缺失 | Claude Code 远程服务器需显式 `"type": "http"` | stdio 型不需要 `type` |
| 工具能列出但调用全超时 | QGIS 桌面端没开,桥接未监听 9876 | 启动 QGIS;插件启动后才会监听 |
| VS Code 里读不到配置 | 用了已弃用的 `.vscode/mcp.json` | 改用 `~/.copilot/mcp-config.json` 或工作区 `.mcp.json` |
| 把 URL 写进了桌面端配置 | Claude Desktop 不读项目 `.mcp.json` | 桌面端用 `claude_desktop_config.json` |
| 加了 API key 却连不上 | 本地 stdio 服务不需要 key | 删掉多余字段 |

---

## 五、验证

```powershell
# 1) QGIS 桥接是否活着
Start-Process 'C:\Program Files\QGIS 3.44.14\bin\qgis-ltr-bin.exe' `
              -WorkingDirectory 'C:\Program Files\QGIS 3.44.14\bin'
Get-NetTCPConnection -LocalPort 9876      # 应有 Listen

# 2) 在客户端里问一句
#    "列出当前 QGIS 工程的所有图层"
```

若客户端报"找不到 qgis 工具",问题在 MCP 配置;若工具能列出但报超时,
问题在 QGIS 桌面端没启动。
