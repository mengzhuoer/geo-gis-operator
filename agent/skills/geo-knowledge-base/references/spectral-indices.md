# 光谱指数与波段对应参考

> 来源：`awesome-spectral-indices/awesome-spectral-indices`（MIT，2026-11 核实）。
> 每个指数的完整公式见 <https://awesome-spectral-indices.github.io/awesome-spectral-indices/>。
> 本文给出**波段→传感器映射**与**分类索引**；写公式时以该站点的官方公式为准。

## 一、广义波段 → 传感器波段映射（关键对照表）

| 标准 | 含义 | 范围 (nm) | Sentinel-2 | Landsat-8/9 | Landsat-4/7 | MODIS |
|---|---|---|---|---|---|---|
| `A` | Aerosols | 400–455 | `B1` | `B1` | — | — |
| `B` | Blue | 450–530 | `B2` | `B2` | `B1` | `B3` |
| `G` | Green | 510–600 | `B3` | `B3` | `B2` | `B4` |
| `G1` | Green 1 | 510–550 | — | — | — | `B11` |
| `N` | Near-Infrared | 760–900 | `B8` | `B5` | `B4` | `B2` |
| `N2` | NIR 2 | 850–880 | `B8A` | — | — | — |
| `R` | Red | 620–690 | `B4` | `B4` | `B3` | `B1` |
| `RE1` | Red Edge 1 | 695–715 | `B5` | — | — | — |
| `RE2` | Red Edge 2 | 730–750 | `B6` | — | — | — |
| `RE3` | Red Edge 3 | 765–795 | `B7` | — | — | — |
| `S1` | SWIR 1 | 1550–1750 | `B11` | `B6` | `B5` | `B6` |
| `S2` | SWIR 2 | 2080–2350 | `B12` | `B7` | `B7` | `B7` |
| `T` | Thermal Infrared | 10400–12500 | — | — | `B6` | — |
| `T1` | Thermal IR 1 | 10600–11190 | — | `B10` | — | — |
| `T2` | Thermal IR 2 | 11500–12510 | — | `B11` | — | — |
| `WV` | Water Vapour | 930–960 | `B9` | — | — | — |
| `Y` | Yellow | 585–625 | — | — | — | — |

**用法**：公式里写 `N`（NIR）比写具体波段号更通用——同一公式换传感器只需替换波段映射。
Sentinel-2 的红边 `RE1/RE2/RE3` 与 `B8A` 是其相对 Landsat 的独特优势，植被监测优先用 S2。

## 二、雷达极化与高光谱记法

- 雷达极化：`HH`（同向共极化）、`HV`/`VH`（交叉极化）、`VV`（同向共极化，垂直）
- 高光谱反射率：`R<a>` 表示整数波长 a nm 的反射率（300 ≤ a ≤ 2500）；`R<a>_<b>` 表示 a~b 区间内任一波长
- 支持函数：`max/min`（逐像元）、`tanh`、`log`、`kernel`、以及需配 `reductions` 定义的 `spatial_max/min/mean`

## 三、分类指数索引

全库共 **332** 个指数，分类计数：植被 223、水体 34、燃烧 20、城市 20、土壤 17、雪 10、云 7、地质 1。
（雷达与高光谱部分不计入这 332 个多光谱指数，单独以极化/波长记法组织，见上一节。）

### Vegetation（223 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Vegetation; Name=AFRI1600; Desc=Aerosol Free Vegetation Index (1600 nm)}.Name) | Aerosol Free Vegetation Index (1600 nm) |
| $(@{Cat=Vegetation; Name=AFRI2100; Desc=Aerosol Free Vegetation Index (2100 nm)}.Name) | Aerosol Free Vegetation Index (2100 nm) |
| $(@{Cat=Vegetation; Name=ARI; Desc=Anthocyanin Reflectance Index}.Name) | Anthocyanin Reflectance Index |
| $(@{Cat=Vegetation; Name=ARI2; Desc=Anthocyanin Reflectance Index 2}.Name) | Anthocyanin Reflectance Index 2 |
| $(@{Cat=Vegetation; Name=ARVI; Desc=Atmospherically Resistant Vegetation Index}.Name) | Atmospherically Resistant Vegetation Index |
| $(@{Cat=Vegetation; Name=AshburnVI; Desc=Ashburn Vegetation Index}.Name) | Ashburn Vegetation Index |
| $(@{Cat=Vegetation; Name=ATSAVI; Desc=Adjusted Transformed Soil-Adjusted Vegetation Index}.Name) | Adjusted Transformed Soil-Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=AVI; Desc=Advanced Vegetation Index}.Name) | Advanced Vegetation Index |
| $(@{Cat=Vegetation; Name=BCC; Desc=Blue Chromatic Coordinate}.Name) | Blue Chromatic Coordinate |
| $(@{Cat=Vegetation; Name=BNDVI; Desc=Blue Normalized Difference Vegetation Index}.Name) | Blue Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=bNIRv; Desc=Blue Near-Infrared Reflectance of Vegetation}.Name) | Blue Near-Infrared Reflectance of Vegetation |
| $(@{Cat=Vegetation; Name=BWDRVI; Desc=Blue Wide Dynamic Range Vegetation Index}.Name) | Blue Wide Dynamic Range Vegetation Index |
| $(@{Cat=Vegetation; Name=CCI; Desc=Chlorophyll Carotenoid Index}.Name) | Chlorophyll Carotenoid Index |
| $(@{Cat=Vegetation; Name=CIG; Desc=Chlorophyll Index Green}.Name) | Chlorophyll Index Green |
| $(@{Cat=Vegetation; Name=CIRE; Desc=Chlorophyll Index Red Edge}.Name) | Chlorophyll Index Red Edge |
| $(@{Cat=Vegetation; Name=CRSWIR; Desc=Continuum Removal SWIR}.Name) | Continuum Removal SWIR |
| $(@{Cat=Vegetation; Name=CVI; Desc=Chlorophyll Vegetation Index}.Name) | Chlorophyll Vegetation Index |
| $(@{Cat=Vegetation; Name=DRS; Desc=Distance Red SWIR}.Name) | Distance Red SWIR |
| $(@{Cat=Vegetation; Name=DSI; Desc=Drought Stress Index}.Name) | Drought Stress Index |
| $(@{Cat=Vegetation; Name=DSWI1; Desc=Disease-Water Stress Index 1}.Name) | Disease-Water Stress Index 1 |
| $(@{Cat=Vegetation; Name=DSWI2; Desc=Disease-Water Stress Index 2}.Name) | Disease-Water Stress Index 2 |
| $(@{Cat=Vegetation; Name=DSWI3; Desc=Disease-Water Stress Index 3}.Name) | Disease-Water Stress Index 3 |
| $(@{Cat=Vegetation; Name=DSWI4; Desc=Disease-Water Stress Index 4}.Name) | Disease-Water Stress Index 4 |
| $(@{Cat=Vegetation; Name=DSWI5; Desc=Disease-Water Stress Index 5}.Name) | Disease-Water Stress Index 5 |
| $(@{Cat=Vegetation; Name=DVI; Desc=Difference Vegetation Index}.Name) | Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=DVIplus; Desc=Difference Vegetation Index Plus}.Name) | Difference Vegetation Index Plus |
| $(@{Cat=Vegetation; Name=EBI; Desc=Enhanced Bloom Index}.Name) | Enhanced Bloom Index |
| $(@{Cat=Vegetation; Name=ENDVI; Desc=Enhanced Normalized Difference Vegetation Index}.Name) | Enhanced Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=EVI; Desc=Enhanced Vegetation Index}.Name) | Enhanced Vegetation Index |
| $(@{Cat=Vegetation; Name=EVI2; Desc=Two-Band Enhanced Vegetation Index}.Name) | Two-Band Enhanced Vegetation Index |
| $(@{Cat=Vegetation; Name=EVIv; Desc=Enhanced Vegetation Index of Vegetation}.Name) | Enhanced Vegetation Index of Vegetation |
| $(@{Cat=Vegetation; Name=ExG; Desc=Excess Green Index}.Name) | Excess Green Index |
| $(@{Cat=Vegetation; Name=ExGR; Desc=ExG - ExR Vegetation Index}.Name) | ExG - ExR Vegetation Index |
| $(@{Cat=Vegetation; Name=ExR; Desc=Excess Red Index}.Name) | Excess Red Index |
| $(@{Cat=Vegetation; Name=FCVI; Desc=Fluorescence Correction Vegetation Index}.Name) | Fluorescence Correction Vegetation Index |
| $(@{Cat=Vegetation; Name=GARI; Desc=Green Atmospherically Resistant Vegetation Index}.Name) | Green Atmospherically Resistant Vegetation Index |
| $(@{Cat=Vegetation; Name=GBNDVI; Desc=Green-Blue Normalized Difference Vegetation Index}.Name) | Green-Blue Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=GCC; Desc=Green Chromatic Coordinate}.Name) | Green Chromatic Coordinate |
| $(@{Cat=Vegetation; Name=GDVI; Desc=Generalized Difference Vegetation Index}.Name) | Generalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=GEMI; Desc=Global Environment Monitoring Index}.Name) | Global Environment Monitoring Index |
| $(@{Cat=Vegetation; Name=GLI; Desc=Green Leaf Index}.Name) | Green Leaf Index |
| $(@{Cat=Vegetation; Name=GM1; Desc=Gitelson and Merzlyak Index 1}.Name) | Gitelson and Merzlyak Index 1 |
| $(@{Cat=Vegetation; Name=GM2; Desc=Gitelson and Merzlyak Index 2}.Name) | Gitelson and Merzlyak Index 2 |
| $(@{Cat=Vegetation; Name=GNDVI; Desc=Green Normalized Difference Vegetation Index}.Name) | Green Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=GOSAVI; Desc=Green Optimized Soil Adjusted Vegetation Index}.Name) | Green Optimized Soil Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=GRARI; Desc=Atmospheric Resistant Green-Red Index}.Name) | Atmospheric Resistant Green-Red Index |
| $(@{Cat=Vegetation; Name=GreenDVI; Desc=Green Difference Vegetation Index}.Name) | Green Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=GRNDVI; Desc=Green-Red Normalized Difference Vegetation Index}.Name) | Green-Red Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=GRVI; Desc=Green Ratio Vegetation Index}.Name) | Green Ratio Vegetation Index |
| $(@{Cat=Vegetation; Name=GSAVI; Desc=Green Soil Adjusted Vegetation Index}.Name) | Green Soil Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=GVMI; Desc=Global Vegetation Moisture Index}.Name) | Global Vegetation Moisture Index |
| $(@{Cat=Vegetation; Name=IAVI; Desc=New Atmospherically Resistant Vegetation Index}.Name) | New Atmospherically Resistant Vegetation Index |
| $(@{Cat=Vegetation; Name=IKAW; Desc=Kawashima Index}.Name) | Kawashima Index |
| $(@{Cat=Vegetation; Name=IPVI; Desc=Infrared Percentage Vegetation Index}.Name) | Infrared Percentage Vegetation Index |
| $(@{Cat=Vegetation; Name=IRECI; Desc=Inverted Red-Edge Chlorophyll Index}.Name) | Inverted Red-Edge Chlorophyll Index |
| $(@{Cat=Vegetation; Name=IRGBVI; Desc=Improved-Red-Green-Blue Vegetation Index}.Name) | Improved-Red-Green-Blue Vegetation Index |
| $(@{Cat=Vegetation; Name=KDI; Desc=Kochia Detection Index}.Name) | Kochia Detection Index |
| $(@{Cat=Vegetation; Name=kEVI; Desc=Kernel Enhanced Vegetation Index}.Name) | Kernel Enhanced Vegetation Index |
| $(@{Cat=Vegetation; Name=kIPVI; Desc=Kernel Infrared Percentage Vegetation Index}.Name) | Kernel Infrared Percentage Vegetation Index |
| $(@{Cat=Vegetation; Name=kNDVI; Desc=Kernel Normalized Difference Vegetation Index}.Name) | Kernel Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=kRVI; Desc=Kernel Ratio Vegetation Index}.Name) | Kernel Ratio Vegetation Index |
| $(@{Cat=Vegetation; Name=kVARI; Desc=Kernel Visible Atmospherically Resistant Index}.Name) | Kernel Visible Atmospherically Resistant Index |
| $(@{Cat=Vegetation; Name=MCARI; Desc=Modified Chlorophyll Absorption in Reflectance Index}.Name) | Modified Chlorophyll Absorption in Reflectance Index |
| $(@{Cat=Vegetation; Name=MCARI1; Desc=Modified Chlorophyll Absorption in Reflectance Index 1}.Name) | Modified Chlorophyll Absorption in Reflectance Index 1 |
| $(@{Cat=Vegetation; Name=MCARI2; Desc=Modified Chlorophyll Absorption in Reflectance Index 2}.Name) | Modified Chlorophyll Absorption in Reflectance Index 2 |
| $(@{Cat=Vegetation; Name=MCARI705; Desc=Modified Chlorophyll Absorption in Reflectance Index (705 and 750 nm)}.Name) | Modified Chlorophyll Absorption in Reflectance Index (705 and 750 nm) |
| $(@{Cat=Vegetation; Name=MCARIOSAVI; Desc=MCARI/OSAVI Ratio}.Name) | MCARI/OSAVI Ratio |
| $(@{Cat=Vegetation; Name=MCARIOSAVI705; Desc=MCARI/OSAVI Ratio (705 and 750 nm)}.Name) | MCARI/OSAVI Ratio (705 and 750 nm) |
| $(@{Cat=Vegetation; Name=MGRVI; Desc=Modified Green Red Vegetation Index}.Name) | Modified Green Red Vegetation Index |
| $(@{Cat=Vegetation; Name=MI; Desc=Mangrove Index}.Name) | Mangrove Index |
| $(@{Cat=Vegetation; Name=mND705; Desc=Modified Normalized Difference (705, 750 and 445 nm)}.Name) | Modified Normalized Difference (705, 750 and 445 nm) |
| $(@{Cat=Vegetation; Name=MNDVI; Desc=Modified Normalized Difference Vegetation Index}.Name) | Modified Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=MNLI; Desc=Modified Non-Linear Vegetation Index}.Name) | Modified Non-Linear Vegetation Index |
| $(@{Cat=Vegetation; Name=MRBVI; Desc=Modified Red Blue Vegetation Index}.Name) | Modified Red Blue Vegetation Index |
| $(@{Cat=Vegetation; Name=MSAVI; Desc=Modified Soil-Adjusted Vegetation Index}.Name) | Modified Soil-Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=MSAVI2; Desc=Modified Soil-Adjusted Vegetation Index 2}.Name) | Modified Soil-Adjusted Vegetation Index 2 |
| $(@{Cat=Vegetation; Name=MSI; Desc=Moisture Stress Index}.Name) | Moisture Stress Index |
| $(@{Cat=Vegetation; Name=MSR; Desc=Modified Simple Ratio}.Name) | Modified Simple Ratio |
| $(@{Cat=Vegetation; Name=MSR705; Desc=Modified Simple Ratio (705 and 750 nm)}.Name) | Modified Simple Ratio (705 and 750 nm) |
| $(@{Cat=Vegetation; Name=mSR705; Desc=Modified Simple Ratio (705 and 445 nm)}.Name) | Modified Simple Ratio (705 and 445 nm) |
| $(@{Cat=Vegetation; Name=MTCI; Desc=MERIS Terrestrial Chlorophyll Index}.Name) | MERIS Terrestrial Chlorophyll Index |
| $(@{Cat=Vegetation; Name=MTVI1; Desc=Modified Triangular Vegetation Index 1}.Name) | Modified Triangular Vegetation Index 1 |
| $(@{Cat=Vegetation; Name=MTVI2; Desc=Modified Triangular Vegetation Index 2}.Name) | Modified Triangular Vegetation Index 2 |
| $(@{Cat=Vegetation; Name=MVI; Desc=Mangrove Vegetation Index}.Name) | Mangrove Vegetation Index |
| $(@{Cat=Vegetation; Name=ND705; Desc=Normalized Difference (705 and 750 nm)}.Name) | Normalized Difference (705 and 750 nm) |
| $(@{Cat=Vegetation; Name=NDDI; Desc=Normalized Difference Drought Index}.Name) | Normalized Difference Drought Index |
| $(@{Cat=Vegetation; Name=NDGI; Desc=Normalized Difference Greenness Index}.Name) | Normalized Difference Greenness Index |
| $(@{Cat=Vegetation; Name=NDII; Desc=Normalized Difference Infrared Index}.Name) | Normalized Difference Infrared Index |
| $(@{Cat=Vegetation; Name=NDMI; Desc=Normalized Difference Moisture Index}.Name) | Normalized Difference Moisture Index |
| $(@{Cat=Vegetation; Name=NDPI; Desc=Normalized Difference Phenology Index}.Name) | Normalized Difference Phenology Index |
| $(@{Cat=Vegetation; Name=NDREI; Desc=Normalized Difference Red Edge Index}.Name) | Normalized Difference Red Edge Index |
| $(@{Cat=Vegetation; Name=NDRS; Desc=Normalized Distance Red SWIR}.Name) | Normalized Distance Red SWIR |
| $(@{Cat=Vegetation; Name=NDTI4RE; Desc=4-band Red Edge Normalized Difference Tillage Index}.Name) | 4-band Red Edge Normalized Difference Tillage Index |
| $(@{Cat=Vegetation; Name=NDTillI; Desc=Normalized Difference Tillage Index}.Name) | Normalized Difference Tillage Index |
| $(@{Cat=Vegetation; Name=NDVI; Desc=Normalized Difference Vegetation Index}.Name) | Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=NDVI4RE; Desc=4-band Red Edge Normalized Difference Vegetation Index}.Name) | 4-band Red Edge Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=NDVI705; Desc=Normalized Difference Vegetation Index (705 and 750 nm)}.Name) | Normalized Difference Vegetation Index (705 and 750 nm) |
| $(@{Cat=Vegetation; Name=NDVISR; Desc=Normalized Difference Vegetation Index with Simple Ratio}.Name) | Normalized Difference Vegetation Index with Simple Ratio |
| $(@{Cat=Vegetation; Name=NDYI; Desc=Normalized Difference Yellowness Index}.Name) | Normalized Difference Yellowness Index |
| $(@{Cat=Vegetation; Name=NGRDI; Desc=Normalized Green Red Difference Index}.Name) | Normalized Green Red Difference Index |
| $(@{Cat=Vegetation; Name=NIRv; Desc=Near-Infrared Reflectance of Vegetation}.Name) | Near-Infrared Reflectance of Vegetation |
| $(@{Cat=Vegetation; Name=NIRvH2; Desc=Hyperspectral Near-Infrared Reflectance of Vegetation}.Name) | Hyperspectral Near-Infrared Reflectance of Vegetation |
| $(@{Cat=Vegetation; Name=NIRvP; Desc=Near-Infrared Reflectance of Vegetation and Incoming PAR}.Name) | Near-Infrared Reflectance of Vegetation and Incoming PAR |
| $(@{Cat=Vegetation; Name=NLI; Desc=Non-Linear Vegetation Index}.Name) | Non-Linear Vegetation Index |
| $(@{Cat=Vegetation; Name=NMDI; Desc=Normalized Multi-band Drought Index}.Name) | Normalized Multi-band Drought Index |
| $(@{Cat=Vegetation; Name=NormG; Desc=Normalized Green}.Name) | Normalized Green |
| $(@{Cat=Vegetation; Name=NormNIR; Desc=Normalized NIR}.Name) | Normalized NIR |
| $(@{Cat=Vegetation; Name=NormR; Desc=Normalized Red}.Name) | Normalized Red |
| $(@{Cat=Vegetation; Name=NPCI; Desc=Normalized Pigments Chlorophyll Ratio Index}.Name) | Normalized Pigments Chlorophyll Ratio Index |
| $(@{Cat=Vegetation; Name=NRFIg; Desc=Normalized Rapeseed Flowering Index Green}.Name) | Normalized Rapeseed Flowering Index Green |
| $(@{Cat=Vegetation; Name=NRFIr; Desc=Normalized Rapeseed Flowering Index Red}.Name) | Normalized Rapeseed Flowering Index Red |
| $(@{Cat=Vegetation; Name=OCVI; Desc=Optimized Chlorophyll Vegetation Index}.Name) | Optimized Chlorophyll Vegetation Index |
| $(@{Cat=Vegetation; Name=OSAVI; Desc=Optimized Soil-Adjusted Vegetation Index}.Name) | Optimized Soil-Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=RCC; Desc=Red Chromatic Coordinate}.Name) | Red Chromatic Coordinate |
| $(@{Cat=Vegetation; Name=RDVI; Desc=Renormalized Difference Vegetation Index}.Name) | Renormalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=REDSI; Desc=Red-Edge Disease Stress Index}.Name) | Red-Edge Disease Stress Index |
| $(@{Cat=Vegetation; Name=RENDVI; Desc=Red Edge Normalized Difference Vegetation Index}.Name) | Red Edge Normalized Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=RGBVI; Desc=Red Green Blue Vegetation Index}.Name) | Red Green Blue Vegetation Index |
| $(@{Cat=Vegetation; Name=RGRI; Desc=Red-Green Ratio Index}.Name) | Red-Green Ratio Index |
| $(@{Cat=Vegetation; Name=RI; Desc=Redness Index}.Name) | Redness Index |
| $(@{Cat=Vegetation; Name=RVI; Desc=Ratio Vegetation Index}.Name) | Ratio Vegetation Index |
| $(@{Cat=Vegetation; Name=RVI4RE; Desc=4-band Red Edge Ratio Vegetation Index}.Name) | 4-band Red Edge Ratio Vegetation Index |
| $(@{Cat=Vegetation; Name=S2REP; Desc=Sentinel-2 Red-Edge Position}.Name) | Sentinel-2 Red-Edge Position |
| $(@{Cat=Vegetation; Name=SARVI; Desc=Soil Adjusted and Atmospherically Resistant Vegetation Index}.Name) | Soil Adjusted and Atmospherically Resistant Vegetation Index |
| $(@{Cat=Vegetation; Name=SAVI; Desc=Soil-Adjusted Vegetation Index}.Name) | Soil-Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=SAVI2; Desc=Soil-Adjusted Vegetation Index 2}.Name) | Soil-Adjusted Vegetation Index 2 |
| $(@{Cat=Vegetation; Name=SAVI4RE; Desc=4-band Red Edge Soil Adjusted Vegetation Index}.Name) | 4-band Red Edge Soil Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=SAVISR; Desc=Soil-Adjusted Vegetation Index with Simple Ratio}.Name) | Soil-Adjusted Vegetation Index with Simple Ratio |
| $(@{Cat=Vegetation; Name=SeLI; Desc=Sentinel-2 LAI Green Index}.Name) | Sentinel-2 LAI Green Index |
| $(@{Cat=Vegetation; Name=SEVI; Desc=Shadow-Eliminated Vegetation Index}.Name) | Shadow-Eliminated Vegetation Index |
| $(@{Cat=Vegetation; Name=SI; Desc=Shadow Index}.Name) | Shadow Index |
| $(@{Cat=Vegetation; Name=SIPI; Desc=Structure Insensitive Pigment Index}.Name) | Structure Insensitive Pigment Index |
| $(@{Cat=Vegetation; Name=SLAVI; Desc=Specific Leaf Area Vegetation Index}.Name) | Specific Leaf Area Vegetation Index |
| $(@{Cat=Vegetation; Name=SNDTI; Desc=Soil-Adjusted Normalized Difference Tillage Index}.Name) | Soil-Adjusted Normalized Difference Tillage Index |
| $(@{Cat=Vegetation; Name=SNDTI4RE; Desc=4-band Red Edge Soil-Adjusted Normalized Difference Tillage Index}.Name) | 4-band Red Edge Soil-Adjusted Normalized Difference Tillage Index |
| $(@{Cat=Vegetation; Name=sNIRvLSWI; Desc=SWIR-enhanced Near-Infrared Reflectance of Vegetation for LSWI}.Name) | SWIR-enhanced Near-Infrared Reflectance of Vegetation for LSWI |
| $(@{Cat=Vegetation; Name=sNIRvNDPI; Desc=SWIR-enhanced Near-Infrared Reflectance of Vegetation for NDPI}.Name) | SWIR-enhanced Near-Infrared Reflectance of Vegetation for NDPI |
| $(@{Cat=Vegetation; Name=sNIRvNDVILSWIP; Desc=SWIR-enhanced Near-Infrared Reflectance of Vegetation for the NDVI-LSWI Product}.Name) | SWIR-enhanced Near-Infrared Reflectance of Vegetation for the NDVI-LSWI Product |
| $(@{Cat=Vegetation; Name=sNIRvNDVILSWIS; Desc=SWIR-enhanced Near-Infrared Reflectance of Vegetation for the NDVI-LSWI Sum}.Name) | SWIR-enhanced Near-Infrared Reflectance of Vegetation for the NDVI-LSWI Sum |
| $(@{Cat=Vegetation; Name=sNIRvSWIR; Desc=SWIR-enhanced Near-Infrared Reflectance of Vegetation}.Name) | SWIR-enhanced Near-Infrared Reflectance of Vegetation |
| $(@{Cat=Vegetation; Name=SR; Desc=Simple Ratio}.Name) | Simple Ratio |
| $(@{Cat=Vegetation; Name=SR2; Desc=Simple Ratio (800 and 550 nm)}.Name) | Simple Ratio (800 and 550 nm) |
| $(@{Cat=Vegetation; Name=SR555; Desc=Simple Ratio (555 and 750 nm)}.Name) | Simple Ratio (555 and 750 nm) |
| $(@{Cat=Vegetation; Name=SR705; Desc=Simple Ratio (705 and 750 nm)}.Name) | Simple Ratio (705 and 750 nm) |
| $(@{Cat=Vegetation; Name=SRVI; Desc=Symbolic Regression Vegetation Index}.Name) | Symbolic Regression Vegetation Index |
| $(@{Cat=Vegetation; Name=STI; Desc=Simple Tillage Index}.Name) | Simple Tillage Index |
| $(@{Cat=Vegetation; Name=STI4RE; Desc=4-band Red Edge Soil Tillage Index}.Name) | 4-band Red Edge Soil Tillage Index |
| $(@{Cat=Vegetation; Name=TCARI; Desc=Transformed Chlorophyll Absorption in Reflectance Index}.Name) | Transformed Chlorophyll Absorption in Reflectance Index |
| $(@{Cat=Vegetation; Name=TCARIOSAVI; Desc=TCARI/OSAVI Ratio}.Name) | TCARI/OSAVI Ratio |
| $(@{Cat=Vegetation; Name=TCARIOSAVI705; Desc=TCARI/OSAVI Ratio (705 and 750 nm)}.Name) | TCARI/OSAVI Ratio (705 and 750 nm) |
| $(@{Cat=Vegetation; Name=TCI; Desc=Triangular Chlorophyll Index}.Name) | Triangular Chlorophyll Index |
| $(@{Cat=Vegetation; Name=TDVI; Desc=Transformed Difference Vegetation Index}.Name) | Transformed Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=TGI; Desc=Triangular Greenness Index}.Name) | Triangular Greenness Index |
| $(@{Cat=Vegetation; Name=TMTCbrightness; Desc=Thematic Mapper Tasseled Cap Brightness Feature}.Name) | Thematic Mapper Tasseled Cap Brightness Feature |
| $(@{Cat=Vegetation; Name=TMTCfifth; Desc=Thematic Mapper Tasseled Cap Fifth Feature}.Name) | Thematic Mapper Tasseled Cap Fifth Feature |
| $(@{Cat=Vegetation; Name=TMTCfourth; Desc=Thematic Mapper Tasseled Cap Fourth Feature}.Name) | Thematic Mapper Tasseled Cap Fourth Feature |
| $(@{Cat=Vegetation; Name=TMTCgreenness; Desc=Thematic Mapper Tasseled Cap Greenness Feature}.Name) | Thematic Mapper Tasseled Cap Greenness Feature |
| $(@{Cat=Vegetation; Name=TMTCsixth; Desc=Thematic Mapper Tasseled Cap Sixth Feature}.Name) | Thematic Mapper Tasseled Cap Sixth Feature |
| $(@{Cat=Vegetation; Name=TMTCwetness; Desc=Thematic Mapper Tasseled Cap Wetness Feature}.Name) | Thematic Mapper Tasseled Cap Wetness Feature |
| $(@{Cat=Vegetation; Name=TriVI; Desc=Triangular Vegetation Index}.Name) | Triangular Vegetation Index |
| $(@{Cat=Vegetation; Name=TRRVI; Desc=Transformed Red Range Vegetation Index}.Name) | Transformed Red Range Vegetation Index |
| $(@{Cat=Vegetation; Name=TSAVI; Desc=Transformed Soil-Adjusted Vegetation Index}.Name) | Transformed Soil-Adjusted Vegetation Index |
| $(@{Cat=Vegetation; Name=TTVI; Desc=Transformed Triangular Vegetation Index}.Name) | Transformed Triangular Vegetation Index |
| $(@{Cat=Vegetation; Name=TVI; Desc=Transformed Vegetation Index}.Name) | Transformed Vegetation Index |
| $(@{Cat=Vegetation; Name=VARI; Desc=Visible Atmospherically Resistant Index}.Name) | Visible Atmospherically Resistant Index |
| $(@{Cat=Vegetation; Name=VARI700; Desc=Visible Atmospherically Resistant Index (700 nm)}.Name) | Visible Atmospherically Resistant Index (700 nm) |
| $(@{Cat=Vegetation; Name=VI700; Desc=Vegetation Index (700 nm)}.Name) | Vegetation Index (700 nm) |
| $(@{Cat=Vegetation; Name=VIG; Desc=Vegetation Index Green}.Name) | Vegetation Index Green |
| $(@{Cat=Vegetation; Name=WCI1; Desc=Wheat Canopy Index (Growth Stage 1)}.Name) | Wheat Canopy Index (Growth Stage 1) |
| $(@{Cat=Vegetation; Name=WCI2; Desc=Wheat Canopy Index (Growth Stage 2)}.Name) | Wheat Canopy Index (Growth Stage 2) |
| $(@{Cat=Vegetation; Name=WCI3; Desc=Wheat Canopy Index (Growth Stage 3)}.Name) | Wheat Canopy Index (Growth Stage 3) |
| $(@{Cat=Vegetation; Name=WDRVI; Desc=Wide Dynamic Range Vegetation Index}.Name) | Wide Dynamic Range Vegetation Index |
| $(@{Cat=Vegetation; Name=WDVI; Desc=Weighted Difference Vegetation Index}.Name) | Weighted Difference Vegetation Index |
| $(@{Cat=Vegetation; Name=CARI; Desc=Carotenoid Index}.Name) | Carotenoid Index |
| $(@{Cat=Vegetation; Name=CCRI; Desc=Carotenoid-Chlorophyll Ratio Index}.Name) | Carotenoid-Chlorophyll Ratio Index |
| $(@{Cat=Vegetation; Name=CRI550; Desc=Carotenoid Reflectance Index at 550 nm}.Name) | Carotenoid Reflectance Index at 550 nm |
| $(@{Cat=Vegetation; Name=CRI700; Desc=Carotenoid Reflectance Index at 700 nm}.Name) | Carotenoid Reflectance Index at 700 nm |
| $(@{Cat=Vegetation; Name=LCI; Desc=Leaf Chlorophyll Index}.Name) | Leaf Chlorophyll Index |
| $(@{Cat=Vegetation; Name=NDLI; Desc=Normalized Difference Lignin Index}.Name) | Normalized Difference Lignin Index |
| $(@{Cat=Vegetation; Name=NDNI; Desc=Normalized Difference Nitrogen Index}.Name) | Normalized Difference Nitrogen Index |
| $(@{Cat=Vegetation; Name=OPSNDa; Desc=Optimized Pigment Specific Normalized Difference for Chlorophyll a}.Name) | Optimized Pigment Specific Normalized Difference for Chlorophyll a |
| $(@{Cat=Vegetation; Name=OPSNDb; Desc=Optimized Pigment Specific Normalized Difference for Chlorophyll b}.Name) | Optimized Pigment Specific Normalized Difference for Chlorophyll b |
| $(@{Cat=Vegetation; Name=OPSNDc; Desc=Optimized Pigment Specific Normalized Difference for Carotenoids}.Name) | Optimized Pigment Specific Normalized Difference for Carotenoids |
| $(@{Cat=Vegetation; Name=OPSSRa; Desc=Optimized Pigment Specific Simple Ratio for Chlorophyll a}.Name) | Optimized Pigment Specific Simple Ratio for Chlorophyll a |
| $(@{Cat=Vegetation; Name=OPSSRb; Desc=Optimized Pigment Specific Simple Ratio for Chlorophyll b}.Name) | Optimized Pigment Specific Simple Ratio for Chlorophyll b |
| $(@{Cat=Vegetation; Name=OPSSRc; Desc=Optimized Pigment Specific Simple Ratio for Carotenoids}.Name) | Optimized Pigment Specific Simple Ratio for Carotenoids |
| $(@{Cat=Vegetation; Name=PRI550; Desc=Physiological Reflectance Index at 550 nm}.Name) | Physiological Reflectance Index at 550 nm |
| $(@{Cat=Vegetation; Name=PRI570; Desc=Physiological Reflectance Index at 570 nm}.Name) | Physiological Reflectance Index at 570 nm |
| $(@{Cat=Vegetation; Name=PRIm1; Desc=Modified Photochemical Reflectance Index 1}.Name) | Modified Photochemical Reflectance Index 1 |
| $(@{Cat=Vegetation; Name=PRIm4; Desc=Modified Photochemical Reflectance Index 4}.Name) | Modified Photochemical Reflectance Index 4 |
| $(@{Cat=Vegetation; Name=PSNDa; Desc=Pigment Specific Normalized Difference for Chlorophyll a}.Name) | Pigment Specific Normalized Difference for Chlorophyll a |
| $(@{Cat=Vegetation; Name=PSNDb; Desc=Pigment Specific Normalized Difference for Chlorophyll b}.Name) | Pigment Specific Normalized Difference for Chlorophyll b |
| $(@{Cat=Vegetation; Name=PSNDc; Desc=Pigment Specific Normalized Difference for Carotenoids}.Name) | Pigment Specific Normalized Difference for Carotenoids |
| $(@{Cat=Vegetation; Name=PSRI; Desc=Plant Senescence Reflectance Index}.Name) | Plant Senescence Reflectance Index |
| $(@{Cat=Vegetation; Name=PSSRa; Desc=Pigment Specific Simple Ratio for Chlorophyll a}.Name) | Pigment Specific Simple Ratio for Chlorophyll a |
| $(@{Cat=Vegetation; Name=PSSRb; Desc=Pigment Specific Simple Ratio for Chlorophyll b}.Name) | Pigment Specific Simple Ratio for Chlorophyll b |
| $(@{Cat=Vegetation; Name=PSSRc; Desc=Pigment Specific Simple Ratio for Carotenoids}.Name) | Pigment Specific Simple Ratio for Carotenoids |
| $(@{Cat=Vegetation; Name=RARSa; Desc=Ratio Analysis of Reflectance Spectra for Chlorophyll a}.Name) | Ratio Analysis of Reflectance Spectra for Chlorophyll a |
| $(@{Cat=Vegetation; Name=RARSb; Desc=Ratio Analysis of Reflectance Spectra for Chlorophyll b}.Name) | Ratio Analysis of Reflectance Spectra for Chlorophyll b |
| $(@{Cat=Vegetation; Name=RARSc; Desc=Ratio Analysis of Reflectance Spectra for Carotenoids}.Name) | Ratio Analysis of Reflectance Spectra for Carotenoids |
| $(@{Cat=Vegetation; Name=RVSI; Desc=Red-edge Vegetation Stress Index}.Name) | Red-edge Vegetation Stress Index |
| $(@{Cat=Vegetation; Name=SARBR1; Desc=Scatter-Adjusted Reflectance Band Ratio 1}.Name) | Scatter-Adjusted Reflectance Band Ratio 1 |
| $(@{Cat=Vegetation; Name=SARBR2; Desc=Scatter-Adjusted Reflectance Band Ratio 2}.Name) | Scatter-Adjusted Reflectance Band Ratio 2 |
| $(@{Cat=Vegetation; Name=SARBR3; Desc=Scatter-Adjusted Reflectance Band Ratio 3}.Name) | Scatter-Adjusted Reflectance Band Ratio 3 |
| $(@{Cat=Vegetation; Name=SARBR4; Desc=Scatter-Adjusted Reflectance Band Ratio 4}.Name) | Scatter-Adjusted Reflectance Band Ratio 4 |
| $(@{Cat=Vegetation; Name=SARBR5; Desc=Scatter-Adjusted Reflectance Band Ratio 5}.Name) | Scatter-Adjusted Reflectance Band Ratio 5 |
| $(@{Cat=Vegetation; Name=URBR1; Desc=Untransformed Reflectance Band Ratio 1}.Name) | Untransformed Reflectance Band Ratio 1 |
| $(@{Cat=Vegetation; Name=URBR2; Desc=Untransformed Reflectance Band Ratio 2}.Name) | Untransformed Reflectance Band Ratio 2 |
| $(@{Cat=Vegetation; Name=URBR3; Desc=Untransformed Reflectance Band Ratio 3}.Name) | Untransformed Reflectance Band Ratio 3 |
| $(@{Cat=Vegetation; Name=URBR4; Desc=Untransformed Reflectance Band Ratio 4}.Name) | Untransformed Reflectance Band Ratio 4 |
| $(@{Cat=Vegetation; Name=URBR5; Desc=Untransformed Reflectance Band Ratio 5}.Name) | Untransformed Reflectance Band Ratio 5 |
| $(@{Cat=Vegetation; Name=DPDD; Desc=Dual-Pol Diagonal Distance}.Name) | Dual-Pol Diagonal Distance |
| $(@{Cat=Vegetation; Name=DpRVIHH; Desc=Dual-Polarized Radar Vegetation Index HH}.Name) | Dual-Polarized Radar Vegetation Index HH |
| $(@{Cat=Vegetation; Name=DpRVIVV; Desc=Dual-Polarized Radar Vegetation Index VV}.Name) | Dual-Polarized Radar Vegetation Index VV |
| $(@{Cat=Vegetation; Name=QpRVI; Desc=Quad-Polarized Radar Vegetation Index}.Name) | Quad-Polarized Radar Vegetation Index |
| $(@{Cat=Vegetation; Name=RFDI; Desc=Radar Forest Degradation Index}.Name) | Radar Forest Degradation Index |
| $(@{Cat=Vegetation; Name=VDDPI; Desc=Vertical Dual De-Polarization Index}.Name) | Vertical Dual De-Polarization Index |
| $(@{Cat=Vegetation; Name=VHVVD; Desc=VH-VV Difference}.Name) | VH-VV Difference |
| $(@{Cat=Vegetation; Name=VHVVP; Desc=VH-VV Product}.Name) | VH-VV Product |
| $(@{Cat=Vegetation; Name=VHVVR; Desc=VH-VV Ratio}.Name) | VH-VV Ratio |
| $(@{Cat=Vegetation; Name=VVVHD; Desc=VV-VH Difference}.Name) | VV-VH Difference |
| $(@{Cat=Vegetation; Name=VVVHR; Desc=VV-VH Ratio}.Name) | VV-VH Ratio |
| $(@{Cat=Vegetation; Name=VVVHS; Desc=VV-VH Sum}.Name) | VV-VH Sum |

### Water（34 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Water; Name=ANDWI; Desc=Augmented Normalized Difference Water Index}.Name) | Augmented Normalized Difference Water Index |
| $(@{Cat=Water; Name=AWEInsh; Desc=Automated Water Extraction Index}.Name) | Automated Water Extraction Index |
| $(@{Cat=Water; Name=AWEIsh; Desc=Automated Water Extraction Index with Shadows Elimination}.Name) | Automated Water Extraction Index with Shadows Elimination |
| $(@{Cat=Water; Name=CWI; Desc=Coastal Water Index}.Name) | Coastal Water Index |
| $(@{Cat=Water; Name=DDWI; Desc=Direct Difference Water Index}.Name) | Direct Difference Water Index |
| $(@{Cat=Water; Name=FAI; Desc=Floating Algae Index}.Name) | Floating Algae Index |
| $(@{Cat=Water; Name=FDI; Desc=Floating Debris Index}.Name) | Floating Debris Index |
| $(@{Cat=Water; Name=FWEI; Desc=Flood/Water Extraction Index}.Name) | Flood/Water Extraction Index |
| $(@{Cat=Water; Name=LSWI; Desc=Land Surface Water Index}.Name) | Land Surface Water Index |
| $(@{Cat=Water; Name=MBWI; Desc=Multi-Band Water Index}.Name) | Multi-Band Water Index |
| $(@{Cat=Water; Name=MLSWI26; Desc=Modified Land Surface Water Index (MODIS Bands 2 and 6)}.Name) | Modified Land Surface Water Index (MODIS Bands 2 and 6) |
| $(@{Cat=Water; Name=MLSWI27; Desc=Modified Land Surface Water Index (MODIS Bands 2 and 7)}.Name) | Modified Land Surface Water Index (MODIS Bands 2 and 7) |
| $(@{Cat=Water; Name=MNDWI; Desc=Modified Normalized Difference Water Index}.Name) | Modified Normalized Difference Water Index |
| $(@{Cat=Water; Name=MuWIR; Desc=Revised Multi-Spectral Water Index}.Name) | Revised Multi-Spectral Water Index |
| $(@{Cat=Water; Name=NDCI; Desc=Normalized Difference Chlorophyll Index}.Name) | Normalized Difference Chlorophyll Index |
| $(@{Cat=Water; Name=NDPonI; Desc=Normalized Difference Pond Index}.Name) | Normalized Difference Pond Index |
| $(@{Cat=Water; Name=NDTI; Desc=Normalized Difference Turbidity Index}.Name) | Normalized Difference Turbidity Index |
| $(@{Cat=Water; Name=NDVIMNDWI; Desc=NDVI-MNDWI Model}.Name) | NDVI-MNDWI Model |
| $(@{Cat=Water; Name=NDWI; Desc=Normalized Difference Water Index}.Name) | Normalized Difference Water Index |
| $(@{Cat=Water; Name=NDWIns; Desc=Normalized Difference Water Index with no Snow Cover and Glaciers}.Name) | Normalized Difference Water Index with no Snow Cover and Glaciers |
| $(@{Cat=Water; Name=NWI; Desc=New Water Index}.Name) | New Water Index |
| $(@{Cat=Water; Name=OSI; Desc=Oil Spill Index}.Name) | Oil Spill Index |
| $(@{Cat=Water; Name=PI; Desc=Plastic Index}.Name) | Plastic Index |
| $(@{Cat=Water; Name=RNDVI; Desc=Reversed Normalized Difference Vegetation Index}.Name) | Reversed Normalized Difference Vegetation Index |
| $(@{Cat=Water; Name=RWI; Desc=Rescaled Water Index}.Name) | Rescaled Water Index |
| $(@{Cat=Water; Name=S2WI; Desc=Sentinel-2 Water Index}.Name) | Sentinel-2 Water Index |
| $(@{Cat=Water; Name=SCoWI; Desc=Subtractive Coastal Water Index}.Name) | Subtractive Coastal Water Index |
| $(@{Cat=Water; Name=SRWI; Desc=Symbolic Regression Water Index}.Name) | Symbolic Regression Water Index |
| $(@{Cat=Water; Name=SWM; Desc=Sentinel Water Mask}.Name) | Sentinel Water Mask |
| $(@{Cat=Water; Name=TWI; Desc=Triangle Water Index}.Name) | Triangle Water Index |
| $(@{Cat=Water; Name=WI1; Desc=Water Index 1}.Name) | Water Index 1 |
| $(@{Cat=Water; Name=WI2; Desc=Water Index 2}.Name) | Water Index 2 |
| $(@{Cat=Water; Name=WI2015; Desc=Water Index 2015}.Name) | Water Index 2015 |
| $(@{Cat=Water; Name=WRI; Desc=Water Ratio Index}.Name) | Water Ratio Index |

### Urban（20 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Urban; Name=BLFEI; Desc=Built-Up Land Features Extraction Index}.Name) | Built-Up Land Features Extraction Index |
| $(@{Cat=Urban; Name=BRBA; Desc=Band Ratio for Built-up Area}.Name) | Band Ratio for Built-up Area |
| $(@{Cat=Urban; Name=IBI; Desc=Index-Based Built-Up Index}.Name) | Index-Based Built-Up Index |
| $(@{Cat=Urban; Name=NBAI; Desc=Normalized Built-up Area Index}.Name) | Normalized Built-up Area Index |
| $(@{Cat=Urban; Name=NDBI; Desc=Normalized Difference Built-Up Index}.Name) | Normalized Difference Built-Up Index |
| $(@{Cat=Urban; Name=NHFD; Desc=Non-Homogeneous Feature Difference}.Name) | Non-Homogeneous Feature Difference |
| $(@{Cat=Urban; Name=PISI; Desc=Perpendicular Impervious Surface Index}.Name) | Perpendicular Impervious Surface Index |
| $(@{Cat=Urban; Name=SUI; Desc=Sealed Urban Index}.Name) | Sealed Urban Index |
| $(@{Cat=Urban; Name=UI; Desc=Urban Index}.Name) | Urban Index |
| $(@{Cat=Urban; Name=VgNIRBI; Desc=Visible Green-Based Built-Up Index}.Name) | Visible Green-Based Built-Up Index |
| $(@{Cat=Urban; Name=VIBI; Desc=Vegetation Index Built-up Index}.Name) | Vegetation Index Built-up Index |
| $(@{Cat=Urban; Name=VrNIRBI; Desc=Visible Red-Based Built-Up Index}.Name) | Visible Red-Based Built-Up Index |
| $(@{Cat=Urban; Name=DBI; Desc=Dry Built-Up Index}.Name) | Dry Built-Up Index |
| $(@{Cat=Urban; Name=EBBI; Desc=Enhanced Built-Up and Bareness Index}.Name) | Enhanced Built-Up and Bareness Index |
| $(@{Cat=Urban; Name=NBUI; Desc=New Built-Up Index}.Name) | New Built-Up Index |
| $(@{Cat=Urban; Name=NDISIb; Desc=Normalized Difference Impervious Surface Index Blue}.Name) | Normalized Difference Impervious Surface Index Blue |
| $(@{Cat=Urban; Name=NDISIg; Desc=Normalized Difference Impervious Surface Index Green}.Name) | Normalized Difference Impervious Surface Index Green |
| $(@{Cat=Urban; Name=NDISImndwi; Desc=Normalized Difference Impervious Surface Index with MNDWI}.Name) | Normalized Difference Impervious Surface Index with MNDWI |
| $(@{Cat=Urban; Name=NDISIndwi; Desc=Normalized Difference Impervious Surface Index with NDWI}.Name) | Normalized Difference Impervious Surface Index with NDWI |
| $(@{Cat=Urban; Name=NDISIr; Desc=Normalized Difference Impervious Surface Index Red}.Name) | Normalized Difference Impervious Surface Index Red |

### Soil（17 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Soil; Name=BaI; Desc=Bareness Index}.Name) | Bareness Index |
| $(@{Cat=Soil; Name=BI; Desc=Bare Soil Index}.Name) | Bare Soil Index |
| $(@{Cat=Soil; Name=BITM; Desc=Landsat TM-based Brightness Index}.Name) | Landsat TM-based Brightness Index |
| $(@{Cat=Soil; Name=BIXS; Desc=SPOT HRV XS-based Brightness Index}.Name) | SPOT HRV XS-based Brightness Index |
| $(@{Cat=Soil; Name=DBSI; Desc=Dry Bareness Index}.Name) | Dry Bareness Index |
| $(@{Cat=Soil; Name=EMBI; Desc=Enhanced Modified Bare Soil Index}.Name) | Enhanced Modified Bare Soil Index |
| $(@{Cat=Soil; Name=MBI; Desc=Modified Bare Soil Index}.Name) | Modified Bare Soil Index |
| $(@{Cat=Soil; Name=NDSIWV; Desc=WorldView Normalized Difference Soil Index}.Name) | WorldView Normalized Difference Soil Index |
| $(@{Cat=Soil; Name=NDSoI; Desc=Normalized Difference Soil Index}.Name) | Normalized Difference Soil Index |
| $(@{Cat=Soil; Name=NSDS; Desc=Normalized Shortwave Infrared Difference Soil-Moisture}.Name) | Normalized Shortwave Infrared Difference Soil-Moisture |
| $(@{Cat=Soil; Name=NSDSI1; Desc=Normalized Shortwave-Infrared Difference Bare Soil Moisture Index 1}.Name) | Normalized Shortwave-Infrared Difference Bare Soil Moisture Index 1 |
| $(@{Cat=Soil; Name=NSDSI2; Desc=Normalized Shortwave-Infrared Difference Bare Soil Moisture Index 2}.Name) | Normalized Shortwave-Infrared Difference Bare Soil Moisture Index 2 |
| $(@{Cat=Soil; Name=NSDSI3; Desc=Normalized Shortwave-Infrared Difference Bare Soil Moisture Index 3}.Name) | Normalized Shortwave-Infrared Difference Bare Soil Moisture Index 3 |
| $(@{Cat=Soil; Name=RI4XS; Desc=SPOT HRV XS-based Redness Index 4}.Name) | SPOT HRV XS-based Redness Index 4 |
| $(@{Cat=Soil; Name=NBLI; Desc=Normalized Difference Bare Land Index}.Name) | Normalized Difference Bare Land Index |
| $(@{Cat=Soil; Name=NBLIOLI; Desc=Normalized Difference Bare Land Index for Landsat-OLI}.Name) | Normalized Difference Bare Land Index for Landsat-OLI |
| $(@{Cat=Soil; Name=NDBaI; Desc=Normalized Difference Bareness Index}.Name) | Normalized Difference Bareness Index |

### Burn（20 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Burn; Name=BAI; Desc=Burned Area Index}.Name) | Burned Area Index |
| $(@{Cat=Burn; Name=BAIM; Desc=Burned Area Index adapted to MODIS}.Name) | Burned Area Index adapted to MODIS |
| $(@{Cat=Burn; Name=BAIS2; Desc=Burned Area Index for Sentinel 2}.Name) | Burned Area Index for Sentinel 2 |
| $(@{Cat=Burn; Name=CSI; Desc=Char Soil Index}.Name) | Char Soil Index |
| $(@{Cat=Burn; Name=IBAIM; Desc=Improved Burned Area Index adapted to MODIS}.Name) | Improved Burned Area Index adapted to MODIS |
| $(@{Cat=Burn; Name=MIRBI; Desc=Mid-Infrared Burn Index}.Name) | Mid-Infrared Burn Index |
| $(@{Cat=Burn; Name=NBR; Desc=Normalized Burn Ratio}.Name) | Normalized Burn Ratio |
| $(@{Cat=Burn; Name=NBR2; Desc=Normalized Burn Ratio 2}.Name) | Normalized Burn Ratio 2 |
| $(@{Cat=Burn; Name=NBRplus; Desc=Normalized Burn Ratio Plus}.Name) | Normalized Burn Ratio Plus |
| $(@{Cat=Burn; Name=NBRSWIR; Desc=Normalized Burn Ratio SWIR}.Name) | Normalized Burn Ratio SWIR |
| $(@{Cat=Burn; Name=NDSWIR; Desc=Normalized Difference SWIR}.Name) | Normalized Difference SWIR |
| $(@{Cat=Burn; Name=CSIT; Desc=Char Soil Index Thermal}.Name) | Char Soil Index Thermal |
| $(@{Cat=Burn; Name=NBRT1; Desc=Normalized Burn Ratio Thermal 1}.Name) | Normalized Burn Ratio Thermal 1 |
| $(@{Cat=Burn; Name=NBRT2; Desc=Normalized Burn Ratio Thermal 2}.Name) | Normalized Burn Ratio Thermal 2 |
| $(@{Cat=Burn; Name=NBRT3; Desc=Normalized Burn Ratio Thermal 3}.Name) | Normalized Burn Ratio Thermal 3 |
| $(@{Cat=Burn; Name=NDVIT; Desc=Normalized Difference Vegetation Index Thermal}.Name) | Normalized Difference Vegetation Index Thermal |
| $(@{Cat=Burn; Name=NSTv1; Desc=NIR-SWIR-Temperature Version 1}.Name) | NIR-SWIR-Temperature Version 1 |
| $(@{Cat=Burn; Name=NSTv2; Desc=NIR-SWIR-Temperature Version 2}.Name) | NIR-SWIR-Temperature Version 2 |
| $(@{Cat=Burn; Name=SAVIT; Desc=Soil-Adjusted Vegetation Index Thermal}.Name) | Soil-Adjusted Vegetation Index Thermal |
| $(@{Cat=Burn; Name=VI6T; Desc=VI6T Index}.Name) | VI6T Index |

### Snow（10 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Snow; Name=NBSIMS; Desc=Non-Binary Snow Index for Multi-Component Surfaces}.Name) | Non-Binary Snow Index for Multi-Component Surfaces |
| $(@{Cat=Snow; Name=NDGlaI; Desc=Normalized Difference Glacier Index}.Name) | Normalized Difference Glacier Index |
| $(@{Cat=Snow; Name=NDSaII; Desc=Normalized Difference Snow and Ice Index}.Name) | Normalized Difference Snow and Ice Index |
| $(@{Cat=Snow; Name=NDSI; Desc=Normalized Difference Snow Index}.Name) | Normalized Difference Snow Index |
| $(@{Cat=Snow; Name=NDSII; Desc=Normalized Difference Snow Ice Index}.Name) | Normalized Difference Snow Ice Index |
| $(@{Cat=Snow; Name=NDSIITM; Desc=Normalized Difference Snow/Ice Index for Landsat TM}.Name) | Normalized Difference Snow/Ice Index for Landsat TM |
| $(@{Cat=Snow; Name=NDSInw; Desc=Normalized Difference Snow Index with no Water}.Name) | Normalized Difference Snow Index with no Water |
| $(@{Cat=Snow; Name=S3; Desc=S3 Snow Index}.Name) | S3 Snow Index |
| $(@{Cat=Snow; Name=SWI; Desc=Snow Water Index}.Name) | Snow Water Index |
| $(@{Cat=Snow; Name=NDISI; Desc=Normalized Difference Ice-Snow Index}.Name) | Normalized Difference Ice-Snow Index |

### Clouds（7 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Clouds; Name=CI1SWIR; Desc=Cloud Index Form 1 with SWIR 1}.Name) | Cloud Index Form 1 with SWIR 1 |
| $(@{Cat=Clouds; Name=CI1woSWIR; Desc=Cloud Index Form 1 without SWIR bands}.Name) | Cloud Index Form 1 without SWIR bands |
| $(@{Cat=Clouds; Name=CI2SWIR; Desc=Cloud Index Form 2 with SWIR bands}.Name) | Cloud Index Form 2 with SWIR bands |
| $(@{Cat=Clouds; Name=CI2woSWIR; Desc=Cloud Index Form 2 without SWIR bands}.Name) | Cloud Index Form 2 without SWIR bands |
| $(@{Cat=Clouds; Name=CLOSDI; Desc=Cloud Shadow Detection Index}.Name) | Cloud Shadow Detection Index |
| $(@{Cat=Clouds; Name=CSISWIR; Desc=Cloud Shadow Index with SWIR 1}.Name) | Cloud Shadow Index with SWIR 1 |
| $(@{Cat=Clouds; Name=CSIwoSWIR; Desc=Cloud Shadow Index without SWIR bands}.Name) | Cloud Shadow Index without SWIR bands |

### Geology（1 个）

| 指数 | 全称 |
|---|---|
| $(@{Cat=Geology; Name=NDPolI; Desc=Normalized Difference Polarization Index}.Name) | Normalized Difference Polarization Index |

