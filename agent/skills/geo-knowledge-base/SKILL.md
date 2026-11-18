---
name: geo-knowledge-base
description: |
  Answer surveying, coordinate-system and remote-sensing domain questions from a built-in
  knowledge base — traverse computation, levelling adjustment, CGCS2000/UTM/Albers projection choice,
  raster grid alignment, NDVI/NDBI/BSI/NDWI/SAVI/EVI index formulas, classification accuracy
  (OA/Kappa), land-use transition matrices, and reproducibility requirements. Use when the user
  asks "怎么算"、"这个坐标系对不对"、"这个指数什么意思"、"精度够不够" or any conceptual
  geospatial question. Do NOT use for executing software operations (use qgis-ops / arcgis-ops /
  autocad-ops / gee-ops).
---

# Geospatial Knowledge Base

Domain reference for surveying and remote sensing. Answer from these references, cite the section,
and state the CRS/units alongside every numeric claim.

## Layout

| File | Covers |
|---|---|
| `references/surveying.md` | Traverse and levelling computation, adjustment, closure checks, coordinate conventions |
| `references/crs-raster.md` | Coordinate systems, projection selection, raster grid alignment, nodata, DEM derivatives |
| `references/remote-sensing.md` | Band physics, atmospheric correction, indices, classification, accuracy metrics, change detection, prediction models |
| `references/spectral-indices.md` | **332 个光谱指数分类索引** + 广义波段→传感器波段映射表（Sentinel-2 / Landsat-8-9 / Landsat-4-7 / MODIS） |
| `references/project-conventions.md` | This project's CRS, datum, naming rules, data lineage, and the 矿地智预 system layout |

Read the relevant reference file before answering; do not answer from memory. The knowledge base is
the authoritative source for formulas, thresholds, and conventions used in this workspace.

**When the user asks "有没有别的指数" / "还有什么指标可以用"** → `spectral-indices.md` holds the
full catalog by category (vegetation / water / urban / soil / burn / snow / cloud). Use its
band→sensor mapping table to write the formula for a specific sensor.

## Inputs to collect

- The concrete question, and whether it is theoretical (formula/threshold) or about this project's data.
- For project-specific questions: which dataset, area, and period.
- The precision the answer must meet — survey-grade (mm) vs. mapping-grade (m) changes the answer.

## Procedure

1. **Classify the question** — surveying computation, CRS/raster, remote sensing, or project convention.
   Load the matching reference.
2. **Extract the applicable rule** — formulas with their coordinate conventions, thresholds with their
   validity conditions, and the caveats the reference attaches to them.
3. **Check the conventions file** if the question touches this workspace's data (EPSG:4547, 1985
   height datum, E-before-N ordering, the GCJ-02 pitfall).
4. **Answer with units, datum, and precision stated.** A coordinate without a CRS, an area without a
   projection, or an index without its formula is not an answer.
5. **Flag the limits.** Every knowledge-base rule carries conditions — an index that saturates, a
   transition matrix with a zero base area, a datum that shifts points ~500 m. State the condition
   that would break the answer.

## Output contract

- The answer, with formula or threshold stated explicitly.
- The CRS, unit, and datum the answer assumes.
- The condition under which it stops holding.
- The reference section it came from.

## Failure handling

- **Question falls outside the base** — say so plainly, and either answer from verified computation
  in the data or recommend the authoritative source (the group's manuals in `<PROJECT_DIR>/docs/`
  are authoritative for course work; say so when they override the base).
- **The base and the teacher's requirement disagree** — the teacher and the textbook win. Flag the
  conflict explicitly rather than silently choosing one.
- **Numbers are needed but no data is in context** — read the actual file, do not estimate.

## Examples

Input: "怎么判断一条导线的闭合差合不合格?"
Output: 测角闭合差 fθ ≤ 60″√n、边长相对闭合差 fD/D ≤ 1/2000 → 给出判据、适用条件与项目实例
→ 引用 surveying.md。

Input: "NDVI 为什么在这个矿区区分不开?"
Output: 高覆盖植被的 NDVI 饱和 + 土壤背景影响 → 改用 SAVI/EVI → 给出公式与 L 取值 → 引用 remote-sensing.md。
