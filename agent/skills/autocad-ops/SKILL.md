---
name: autocad-ops
description: |
  Edit AutoCAD 2025 drawings and DXF files — add points, text, layers and blocks, export DXF, and
  verify geometry — either through the live AutoCAD COM API or headless via ezdxf. Use for any
  .dwg/.dxf task: adding survey points to a point map, annotating heights, editing layers, or
  checking entity counts and coordinates. Use this skill when the user mentions AutoCAD, a .dwg or .dxf
  file, a drawing, or CAD entity editing. Do NOT use for QGIS (use qgis-ops), ArcGIS Pro
  (use arcgis-ops), or GEE (use gee-ops).
---

# AutoCAD Drawing Operations

Two paths, and the choice matters:

| Path | Use when | Trade-off |
|---|---|---|
| **COM** (`AutoCAD.Application`) | The user has AutoCAD open, or the edit needs AutoCAD's own renderer/commands | Requires a running instance; `Dispatch` cold-starts it invisibly |
| **ezdxf** (headless, system `python`) | Bulk generation, geometry inspection, or any task where AutoCAD need not be visible | Cannot see DWG directly — it reads/writes **DXF**; DWG needs AutoCAD or a converter to cross over |

Both interpreters differ: the system `python` 3.11.9 has `ezdxf` and `win32com`; the ArcGIS Pro
Python has neither. Use system `python` for both paths.

## Inputs to collect

- The source drawing path and the target output path — **never overwrite the source**
- Which entities to add or change: coordinates in the drawing's own CRS, text content, layer names
- The drawing's coordinate system, if it is not the project default (CGCS2000 / EPSG:4547)

## COM path — verified behavior

```python
import win32com.client, pythoncom, time
from array import array

# Attach to a running instance; Dispatch cold-starts an invisible one if none exists.
try:
    acad = win32com.client.GetActiveObject('AutoCAD.Application')
except Exception:
    acad = win32com.client.Dispatch('AutoCAD.Application')   # version 25.0s, visible=False

# SAFETY: refuse to write over the source.
if os.path.normcase(OUT) == os.path.normcase(SRC):
    raise RuntimeError('refusing to overwrite the source drawing')

# Locate the open document by path, else open it.
doc = next((d for d in acad.Documents
            if os.path.normcase(d.FullName) == os.path.normcase(SRC)), None)
if doc is None:
    doc = acad.Documents.Open(SRC)

# SaveAs first — the working document becomes a new file, the original is untouched.
doc.SaveAs(OUT)

# Array parameters need an explicit VARIANT array of doubles.
def vec(x, y, z=0):
    return win32com.client.VARIANT(pythoncom.VT_ARRAY | pythoncom.VT_R8, (x, y, z))
```

Retry helper for COM timing (AutoCAD is busy right after launch):

```python
def retry(fn, tries=20, delay=0.7):
    for i in range(tries):
        try:
            return fn()
        except Exception:
            if i == tries - 1:
                raise
            time.sleep(delay)
```

## ezdxf path

```python
import ezdxf
from ezdxf.enums import TextEntityAlignment

doc = ezdxf.new('R2013', setup=True)      # new drawing
doc = ezdxf.readfile(path)                # read DXF
msp = doc.modelspace()
count = len(msp)                          # entity count
doc.saveas(path)                          # write
```

- Use `ezdxf.new('R2013', setup=True)` so standard linetypes and text styles resolve.
- `TextEntityAlignment` sets label anchoring; plain `add_text` leaves alignment unset.
- For geometry checks use `ezdxf.math.is_point_in_point_2d` / `is_point_in_polygon_2d`.
- Add a geometry `auditor` pass before saving when the drawing came from another tool.

## Procedure

1. **Read the source first.** With ezdxf on the DXF, or COM on the DWG: entity count, layer list,
   extents, and the CRS. Never edit blind.
2. **Copy semantics for output.** Write to a **new** path. Use `SaveAs` (COM) or `saveas` (ezdxf)
   so the original survives.
3. **Write entities.** Use the entity type that matches the drawing's existing conventions —
   check an existing sample entity's layer and style before adding a new one.
4. **Keep the drawing self-documenting.** If the data is not field-measured, write the caveat into
   the drawing (see the project convention: a 说明 block noting the source, the assumed datum, and
   the excluded points). An unexplained extra point in a survey drawing is a defect.
5. **Verify after writing.** Reopen the output, count entities, confirm the expected coordinates are
   present, and confirm the source file's modification time did not change.

## Coordinate handling

Geographic input (lat/lon) must be projected before insertion, and the datum decision must be
explicit:

```python
from pyproj import Transformer
tr = Transformer.from_crs('EPSG:4326', 'EPSG:4547', always_xy=True)
e, n = tr.transform(lon, lat)
```

When a choice exists between datums (WGS84 vs GCJ-02), take it from the user's context or ask —
a GCJ-02 reinterpretation of WGS84 points in China shifts them ~500 m, which is far beyond survey
tolerance. Document whichever assumption was used inside the drawing.

## Output contract

- Report the output path, entity count added, and the final entity count.
- State the CRS and any datum assumption.
- Confirm the source file was not modified.

## Failure handling

- **`GetActiveObject` fails** → no running instance. `Dispatch` cold-starts it invisibly; give it
  time and use the retry helper before giving up.
- **COM calls hang** → AutoCAD may show a modal dialog (unsaved-changes prompt, file-in-use).
  This needs the user to look at the screen; do not force-kill AutoCAD.
- **DWG cannot be read by ezdxf** → expected: ezdxf has no DWG reader. Either ask the user for a
  DXF export, or use COM/AutoCAD to convert.
- **Entities land at the wrong place** → CRS mismatch. Verify the drawing's CRS before assuming
  the coordinates were wrong.

## Examples

Input: "给碎步点坐标图加上 4 个补充高程点并标注"
Output: 确认源文件 → `SaveAs` 到新路径 → 按 EPSG:4547 插入点与注记 → 写入非实测说明 → 重新打开校验点数与坐标。
