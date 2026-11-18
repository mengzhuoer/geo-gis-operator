---
name: arcgis-ops
description: |
  Run ArcGIS Pro geoprocessing through arcpy in Pro's own Python environment — FileGDB
  workspaces, feature classes, spatial analysis (buffer/clip/intersect), raster processing,
  field calculations, and batch vector conversion. Use for ArcGIS Pro-side work, or when the
  user explicitly asks for arcpy, geoprocessing tools, or .gdb output. Do NOT use for QGIS
  (use qgis-ops), AutoCAD (use autocad-ops), or GEE (use gee-ops).
---

# ArcGIS Pro / arcpy Operations

ArcGIS Pro is driven by **arcpy scripts**, not MCP. The `mcp__arcgis__*` tools are not registered in
this profile — calling them fails. Use Pro's bundled Python.

## Interpreter

```powershell
$acpy = 'C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe'
& $acpy -c "import arcpy; print(arcpy.GetInstallInfo()['Version'])"
```

arcpy 3.5.2, Python 3.11.11. Never use the system `python` for arcpy — it lacks the arcpy module.
This interpreter has no `ezdxf`/`win32com`; those live in the system `python` 3.11.9.

## Learning resources

`references/arcgis-learning.md` holds the verified external material:
the official `Esri/arcgis-python-api` repo, community arcpy toolkits, and a
**6-step self-study path with runnable snippets** for this machine. Read it when you need
an unfamiliar arcpy function, a worked geoprocessing chain, or an assessment of an
ArcGIS MCP add-in. Note it records that `Knight60/ArcGIS-Pro-MCP` **requires ArcGIS Pro 3.7
while this machine runs 3.5.2** — that add-in cannot be installed here.

## Inputs to collect

- Input data path and its format (shapefile, FileGDB feature class, GeoTIFF, GeoJSON)
- The target output path and format — prefer a FileGDB workspace over a folder of shapefiles
- The output CRS (must be a **projected** CRS for area/length work) and the tolerance/parameters
  of the operation

## Verified signatures and gotchas

These were run on this machine; do not re-derive them:

```python
# FileGDB — note: out_folder_path + out_name, NOT a single path with .gdb
gdb = arcpy.management.CreateFileGDB(r'<WORKDIR>', '_probe2.gdb').getOutput(0)
arcpy.env.workspace = gdb

# Feature class with an explicit CRS
fc = arcpy.management.CreateFeatureclass(gdb, 'pts', 'POINT',
                                         spatial_reference=arcpy.SpatialReference(4547)).getOutput(0)

# Insert cursor: the row must be a LIST, and geometry uses 'SHAPE@'
with arcpy.da.InsertCursor(fc, ['SHAPE@']) as cur:
    cur.insertRow([arcpy.Point(382000.0, 4180000.0)])

# Read back
with arcpy.da.SearchCursor(fc, ['SHAPE@X', 'SHAPE@Y']) as cur:
    rows = [(r[0], r[1]) for r in cur]
```

Failure signatures seen in practice:
- `CreateFileGDB() got an unexpected keyword argument 'name'` → the parameter is `out_name`.
- `TypeError: fields size must match size of the row` → you passed a bare Point; wrap it in a list.
- `TypeError: argument must be a list or tuple of values` → same cause, wrong insertRow form.
- `ERROR 000732 / 000735: the location is not supported` → the output path is malformed for the
  tool. For FileGDB use the folder + name form; for other tools check that the parent folder exists.
- `arcpy.ListFeatureClasses(gdb)` returning `None` → the workspace has no feature classes yet;
  it returns `None`, not an empty list, so guard with `or []`.

## CRS on this project

`arcpy.SpatialReference(4547)` resolves to `CGCS2000_3_Degree_GK_CM_114E` — the project CRS for
`<PROJECT_DIR>`. Use it for all projected measurement. Chinese local geodetic: 1985 National Height
Datum, E (easting) first then N (northing).

## Procedure

1. **Inspect the input first.** `arcpy.Describe` for the dataset's shape type, extent, and CRS.
   Confirm the CRS is what the user thinks it is — a mismatch is the most common cause of wrong
   results and empty outputs.
2. **Create the workspace** if the output is a geodatabase (see verified signatures above).
3. **Set the environment** with `arcpy.env.workspace`, and `arcpy.env.overwriteOutput = True` only
   when you have confirmed the target is disposable.
4. **Run the geoprocessing tool**, capturing the result via `.getOutput(0)`. Pass `arcpy.env.extent`
   or `arcpy.env.mask` only when the user has specified a clipping boundary.
5. **Verify.** `arcpy.ListFeatureClasses` for the outputs, `arcpy.Describe` for the schema, and a
   feature count via `arcpy.da.SearchCursor` or `arcpy.management.GetCount`.
6. **Clean up probes.** Remove any temporary scratch geodatabase you created for the run.

## Output contract

- Report the output path, feature count, and the CRS of the result.
- For area/length/distance outputs, give the unit and note whether it is geodesic or planar.
- If the operation was approximate (buffered, dissolved, simplified), state the tolerance used.

## Failure handling

- **arcpy import fails** → wrong interpreter. Use the Pro Python path above, not system `python`.
- **A spatial op returns empty** → CRS mismatch between inputs. Reproject both to the target
  projected CRS and re-run; do not report the empty result as a real finding.
- **A tool fails with ERROR 000732/000735** → output path problem, not a data problem. Re-read the
  tool's parameter list before changing the data.
- **License-gated tool (e.g. some 3D/advanced analysis) fails** → report the exact error and the
  unlicensed tool; do not silently swap in a different algorithm.

## Examples

Input: "在 <PROJECT_DIR>/成果 下一个 FileGDB，把水准点做成缓冲区"
Output: `CreateFileGDB` 建库 → `CreateFeatureclass` (CGCS2000_3_Degree_GK_CM_114E) → `CreateFeatureClass`
from the source layer → `analysis.Buffer(距离 m)` → `GetCount` 校验 → 报告 gdb 路径、要素数、缓冲区宽度。
