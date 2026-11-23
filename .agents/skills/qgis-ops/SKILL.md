---
name: qgis-ops
description: |
  Use when the task involves QGIS: reading a .qgz project, inspecting or editing layers,
  styling, running Processing algorithms, making maps and print layouts, or exporting to
  GeoPackage/GeoJSON/Shapefile. Drives a running QGIS desktop through the qgis MCP bridge
  (project, layer, features, field, editing, style, render, processing, query, analysis,
  transform). Does NOT cover ArcGIS Pro (use arcgis-ops), AutoCAD (use autocad-ops),
  or Google Earth Engine (use gee-ops).license: GPL-2.0
compatibility: Requires Windows with the matching GIS software installed; QGIS tasks need a running QGIS desktop, AutoCAD tasks need AutoCAD or ezdxf, ArcGIS tasks need ArcGIS Pro.
metadata:
  author: mengzhuoer
  version: "1.0"
---

# QGIS Operations

QGIS is driven through the `qgis` MCP server, which bridges to the **running QGIS desktop app** over
TCP 9876. The MCP toolset is split by concern; pick the group that matches the task.

## Inputs to collect

- Which project or data source (`.qgz`, `.gpkg`, `.tif`, `.geojson`, `.shp`, or a layer id already in the session)
- The target output path, if the task writes anything
- Whether the user wants a rendered preview or a final deliverable

If the project is not loaded and no layer is named, load the project first rather than guessing.

## Prerequisite check

MCP calls fail with a transport error when the desktop app is closed. The bridge is alive only while
QGIS runs. If the first call errors out, start the app before continuing:

```powershell
Start-Process -FilePath 'C:\Program Files\QGIS 3.44.14\bin\qgis-ltr-bin.exe' -WorkingDirectory 'C:\Program Files\QGIS 3.44.14\bin'
```

Wait for the window to come up, then call `system` with action `ping` — it must return `{"pong": true}`.
Do not repeat a failing call more than once before diagnosing; the plugin takes ~20 s to register its port.

## Tool groups

**Full tool reference (125 tools, annotations, resources, prompts)**: `references/mcp-tools-reference.md`
— taken verbatim from the upstream project `nkarasiak/qgis-mcp` (GPL-2.0), which is exactly what
this machine runs (`<QGIS_MCP_DIR>` v0.15.2 + `qgis_mcp_plugin`). Read it when you need
an exact tool name, its `readOnly`/`destructive`/`idempotent` annotation, or the resource/prompt list.

| Need | Tool group | Key actions |
|---|---|---|
| Project lifecycle | `project` | `load`, `create`, `save`, `get_info`, `set_crs`, `create_checkpoint`, `export_session` |
| Layer inventory & schema | `layer` | `find`, `list`, `get_info`, `get_schema`, `get_extent`, `get_crs`, `add_vector`, `add_raster`, `export` |
| Attributes & edits | `features` | `get`, `get_statistics`, `add`, `update`, `update_geometry`, `delete` |
| Attribute schema | `field` | `add`, `rename`, `calculate`, `unique_values`, `delete` |
| Undoable edit sessions | `editing` | `start`, `commit`, `rollback`, `undo`, `redo`, `status` |
| Symbology & labels | `style`, `layer_property` | `set`, `set_raster`, `set_labeling`, `save_style`, `apply_style` |
| Rendering & layouts | `render`, `canvas` | `map`, `screenshot`, `create_layout`, `add_map`, `add_legend`, `add_scalebar`, `export_layout` |
| Processing algorithms | `processing` | `execute`, `execute_batch`, `list_algorithms`, `get_help`, `start_job` |
| Raw PyQGIS | `code` | `execute` — for anything the groups above do not cover |
| Query & identify | `query` | `sql` (cross-layer), `identify` (click a coordinate) |
| Analysis | `analysis` | `spatial_join`, `zonal_statistics`, `raster_calculator`, `sample_raster` |
| Coordinate transform | `transform` | `coordinates` (points or bbox between CRS) |

## Upstream semantics that change how you should call these tools

Verified against the upstream AGENTS.md of `nkarasiak/qgis-mcp` (the server this machine runs):

- **Edit sessions are a real buffer.** `add_features` / `update_features` / `delete_features` /
  `update_feature_geometry` check `layer.isEditable()`: with a session open they write to the
  layer's undo buffer (discardable by `rollback_edits`); without one they write straight to the
  data provider. Every response reports which path it took via `buffered`. **Start an edit session
  before destructive edits** so they stay reversible.
- **`features.get` refuses `limit` above 50** (default 10) rather than clamping it — page with `offset`.
- **Timeouts are never retried.** A timeout closes the socket because the abandoned response would
  desync every later call; retrying would run the command a second time (adding a layer or writing
  the file twice). On a timeout, check the result before re-issuing.
- **`processing.execute` has a 55 s plugin-side deadline** and the socket timeout sits 5 s above it.
  For anything heavier, use `processing.start_job` (no deadline, returns a job id) and poll with `get_job`.
- **A `TEMPORARY_OUTPUT` / `memory:` sink needs `load_results: true`** or the result is discarded.
- **Checkpoints are per-QGIS, max 20.** `create_checkpoint` snapshots the project *including memory
  layer features*, but **not** uncommitted edits or file/database data — it lists the layers that
  do have uncommitted edits. `restore_checkpoint` rewinds the session journal too.
- **`export_session`** renders the journal of mutating commands as a Python script that replays them
  from the QGIS Python console, remapping layer ids by name — a ready-made reproducibility artifact.
- **`project.load` dismisses QGIS's "Handle Unavailable Layers" dialog automatically** and reports
  those layers in `unavailable_layers`; without that it would block until a human closes it.
- **Batches cannot nest.** `batch` and the always-confirm destructive commands are refused inside a batch.
- **Destructive tools carry a `destructiveHint` annotation** that the client's own confirmation gate reads.
  The server's internal confirmation is *not* a safety boundary — it fails open on clients without
  elicitation support. **Your own confirmation step is the real gate.**


## Procedure

1. **Load or confirm the project.** `project.load` with the `.qgz` path. Then `layer.find` with a
   **wildcard** `name_pattern` (e.g. `*已知控制点*`, or `*` to list everything) to get layer ids —
   ids are opaque strings, names are not accepted in their place, and an empty pattern returns
   nothing in this build.
2. **Inspect before acting.** `layer.get_schema` and `features.get` reveal the real field names and
   a sample row. Compute statistics with `features.get_statistics` when a count, sum, or range matters.

   **This project's fields are Chinese-named** — `点位` / `点名` / `E` / `N` / `Z` / `类型` / `所属路线`.
   An English guess like `name` or `x` will silently return nothing. Always read the schema first;
   never hardcode a field name. Note the pair `E`/`N` is easting-first, matching the project convention
   in the knowledge base, and `Z` carries the 1985-datum height.
3. **Run the operation.** Prefer `processing.execute` over hand-written PyQGIS; it handles the
   temporary-output lifecycle for you. Pass `load_results: true` to keep a `TEMPORARY_OUTPUT`
   result alive and visible in `loaded_layers`.
4. **Use `processing.start_job` for anything slow** (large rasters, heavy buffers). It returns a job id
   immediately; poll with `get_job`. The default `execute` timeout is 55 s and will cancel the run.
5. **Render the result.** `render.map` returns an inline image for a quick look;
   `canvas.screenshot` shows the current canvas state. For a deliverable, build a layout with
   `render.create_layout` + `add_map`/`add_legend`/`add_scalebar`, then `export_layout` to PDF.
6. **Verify.** Re-query the output layer (`features.get` count, `layer.get_extent`) and confirm the
   exported file exists with a non-zero size.

## Output contract

- State the output path, format, and the CRS of the result.
- For rendered output: mention the file path and what it shows.
- For statistics: give the numbers with units and the CRS they were computed in.

## Failure handling

- **MCP transport error on first call** → the desktop app is not running. Start it, wait, `ping`.
- **`layer.list` fails with a type error** → the `limit` parameter has a bug in this build; use
  `layer.find` instead. This is a known defect, not your mistake.
- **`layer.find` with an EMPTY `name_pattern` returns 0 layers** → another build defect in this
  compound-mode server. Always pass a wildcard pattern such as `*已知控制点*` or `*` to list layers.
  An empty pattern is *not* "match everything" here.
- **`features.get` fails on every layer** with `Error executing tool features` → build-level defect
  in the compound wrapper (the server log records no matching error, so the failure is in the
  wrapper's serialization). It is **not** layer-specific. Get counts and samples through the
  alternatives below instead of retrying `features.get`.
- **Message log with `limit` fails** with `slice indices must be integers` → drop the `limit`
  parameter.
- **Processing algorithm not found** → `processing.list_algorithms` with a search term, then
  `processing.get_help` for the exact parameter names before retrying.
- **Empty result from a spatial op** → check CRS compatibility first. Reproject both inputs to a
  common projected CRS (never a geographic one) before the operation; a silent empty result is the
  usual symptom of a CRS mismatch.
- **Editing a layer fails** → the layer may be read-only on disk. Copy it to a new path first and
  edit the copy; never edit a file that is the user's only copy.

## Working around `features.get`

When `features.get` is unavailable, these all work and are verified on this machine:

```text
query(sql="SELECT count(*) AS n FROM \"已知控制点\"")        → rows [{n: 25}]
features.get_statistics(layer_id, field_name="点号")        → count 25, distinct_values [...]
features.get_statistics(layer_id, field_name="E")           → sum / mean / min / max / stdev
layer.get_schema(layer_id)                                  → field names and types
layer.get_extent(layer_id)                                  → spatial extent
```

`query.sql` needs the layer **name** in double quotes (Chinese names included), not the layer id.
`get_statistics` on a numeric field returns sum/mean/min/max/stdev; on a string field it returns
`count`, `distinct_count`, and the distinct values — which doubles as a good way to read a
layer's identifier column.


## Examples

Input: "把测量实习.qgz 里的卫星正射底图范围告诉我"
Output: `layer.find` → 取得栅格图层 id → `layer.get_extent` + `layer.get_crs` → 报告范围坐标与坐标系。

Input: "把水准点图层导出成 GeoJSON 放到 data 目录"
Output: 确认目标文件不存在 → `layer.export` 指定 `.geojson` 输出路径 → 校验文件存在且要素数与源一致。
