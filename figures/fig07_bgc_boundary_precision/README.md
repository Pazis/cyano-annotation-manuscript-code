# Figure 7 — BGC boundary precision

Per genome, the % of the antiSMASH locus covered by GECCO against the % of the GECCO locus covered by antiSMASH, with the 1:1 line. Same genome filter as Figure 6.

**Inputs:** `data/processed/BGC_analyses_tables.xlsx`, sheet `S8 BGC consolidation` (written by `bgc_analyses/bgc_consolidation.py` from the Reannota_New GFF3s)
**Script:** `boundary_precision.r`
**Output:** `fig07.png`

## Legend draft

Agreement between antiSMASH and GECCO cluster boundaries in the 149 genomes shown in Figure 6. Each point is one genome. The x-axis is the percentage of antiSMASH region length covered by GECCO clusters, and the y-axis is the percentage of GECCO cluster length covered by antiSMASH regions. The dashed line marks equal coverage in both directions. All genomes lie above that line (median 91.5% of GECCO cluster length covered, against 35.5% of antiSMASH region length), so GECCO clusters fall mostly inside antiSMASH regions, while antiSMASH regions extend beyond them.
