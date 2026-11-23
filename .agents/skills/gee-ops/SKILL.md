---
name: gee-ops
description: |
  Use when the task involves Google Earth Engine: authoring GEE JavaScript, running it in
  the Code Editor, exporting Sentinel-2/Landsat imagery or spectral indices (NDVI, NDBI,
  BSI, LST) by AOI and year, and checking Export task status. Covers GEE-specific data
  sources and export quota discipline. Does NOT cover local raster processing
  (use qgis-ops or arcgis-ops).license: GPL-2.0
compatibility: Requires Windows with the matching GIS software installed; QGIS tasks need a running QGIS desktop, AutoCAD tasks need AutoCAD or ezdxf, ArcGIS tasks need ArcGIS Pro.
metadata:
  author: mengzhuoer
  version: "1.0"
---

# Google Earth Engine Operations

GEE runs in the browser. There is no local GEE binary — the workflow is: write the JS locally, inject
it into the Code Editor, run it, submit the Export tasks, then check Drive for the results.

The global skill `gee-export-automation` covers the browser mechanics in depth (ACE injection, Tasks
shadow DOM). Load it when you need those details; this skill covers the geospatial side — script
authoring, dataset choice, index computation, export routing, and verification.

## Inputs to collect

- The AOI: coordinates or an asset path. Always know the region before scripting.
- Time window and the target year set.
- The product: collection id, bands, resolution, cloud mask rule.
- The destination: a Drive folder name unique per region and per task family.
- The output format and naming convention.

## Procedure

1. **Read the existing assets before writing new scripts.** `<MINEGEOAI_DIR>\tools\gee_export_indices.js`
   is a working multi-index, multi-year export script — use it as the structural template rather
   than starting from scratch.
2. **Author the JS with an explicit CONFIG block** at the top: `driveFolder`, `fileNamePrefix`,
   `region`, `years`, `indices`, `scale`, `crs`. Keep the Drive folder unique per region — the Tasks
   panel cannot distinguish two tasks with the same display name.
3. **Compute indices in GEE**, not locally: `NDVI = (NIR - Red) / (NIR + Red)`,
   `NDBI = (SWIR - NIR) / (SWIR + NIR)`, `BSI = ((SWIR + Red) - (NIR + Blue)) / ((SWIR + Red) + (NIR + Blue))`,
   `NDWI = (Green - NIR) / (Green + NIR)`. Apply the cloud mask and an AOI mask before export.
   For band selection, load the `geo-knowledge-base` skill and open its spectral-indices
   reference (band→sensor mapping table): Sentinel-2 — NIR=B8, NIR2=B8A, SWIR1=B11, SWIR2=B12,
   Red=B4, Green=B3, Blue=B2; Landsat-8/9 — NIR=B5, SWIR1=B6, SWIR2=B7, Red=B4, Green=B3, Blue=B2.
4. **Inject and run** via the browser skill: the editor is ACE, not CodeMirror — read
   `.ace_editor`, set the value, and verify with `ed.getValue().length` plus a unique marker string
   from the CONFIG block.
5. **Submit exports** with the Tasks panel's **Run all** button (not per-task Run — that means one
   confirmation dialog per task). Confirm submission by snapshotting the Submitted tasks region
   8–10 s later.
6. **Verify by Drive file count**, not by task name. A finished run should have
   `years × indices` files in the target folder. Task names alone cannot prove which region
   produced them.


## Output contract

Report: which script was injected, how many tasks were submitted, the Drive destination folder, the
expected file count, the expected turnaround, and how to re-run any failed task.

## Failure handling

- **GEE page does not open** → check network/proxy access to `code.earthengine.google.com` first.
- **Login wall** → the user must sign in themselves in the browser window. Never request or type
  their credentials.
- **Console shows an error after Run** → the script failed client-side. Fix the script (wrong band
  name, empty collection, quota) before submitting tasks; do not submit known-broken tasks.
- **A task fails server-side** (cloud, quota, tile exhaustion) → re-inject the script and click Run
  on that one task.
- **Files land in the wrong folder** → `CONFIG.driveFolder` was not unique. Files are routed by that
  string; changing it requires re-running the export.

## Cost and quota discipline

GEE exports consume quota and write to the user's Google Drive. Batch exports over many years and
indices are large. Before a large batch, confirm the AOI size, the number of years and indices, the
resolution, and the export format — and get the user's approval before submitting. Prefer a
small-pilot test (one year, one index) before a full batch.

## Examples

Input: "导出某矿区 2000–2020 每五年的 NDVI 和 NDBI"
Output: 确定 AOI 与集合(Sentinel-2 TOA / Landsat 8 OLI) → 写带 CONFIG 的 JS → 注入运行 → 校验无报错 →
Run all 提交 → 报告任务数、Drive 文件夹、预期文件数(年数 × 指数数)。
