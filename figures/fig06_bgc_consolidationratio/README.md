# Figure 6 — BGC locus consolidation ratio

Distribution of the per-genome ratio of antiSMASH region count to GECCO cluster count (histogram, density, mean), for genomes where both tools find BGCs and at least one region and one cluster overlap.

**Inputs:** `data/processed/BGC_analyses_tables.xlsx`, sheet `S8 BGC consolidation` (written by `bgc_analyses/bgc_consolidation.py` from the Reannota_New GFF3s)
**Script:** `bgc_consolidation.r`
**Output:** `fig06.png`

## Legend draft

Distribution of the BGC consolidation ratio (antiSMASH region count ÷ GECCO cluster count per genome) for the 149 cyanobacterial genomes where both tools detected BGCs and at least one antiSMASH region and one GECCO cluster overlapped. Bars are a density-scaled histogram (10 bins), the black curve is a kernel density estimate, and the red dashed line marks the mean ratio (1.63). A ratio above 1 means that antiSMASH reports more clusters than GECCO in the same genome. Among clusters detected by both tools the ratio is close to 1 (pooled 0.96; Table S8), so the excess reflects antiSMASH regions without a GECCO counterpart rather than antiSMASH splitting loci that GECCO reports as one.
