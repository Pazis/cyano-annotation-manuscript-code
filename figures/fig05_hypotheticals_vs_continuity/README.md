# Figure 5 — Undescribed CDS vs assembly fragmentation

Undescribed CDS (%) against number of contigs for Prokka, Bakta and Cyan-ote, all 373 cyanobacterial genomes pooled, with loess trends.

**Inputs:** `data/processed/GOODQ_PBC_Summary.csv`, `BADQ_PBC_Summary.csv` (`Contigs`, `Gene_count`, `*_Hypotheticals`)
**Script:** `hypotheticals_vs_continuity.r`
**Output:** `fig05.png`

## Legend draft

Undescribed CDS (%) against assembly fragmentation (number of contigs) for Prokka (blue), Bakta (grey) and Cyan-ote (orange). The high- and low-continuity sets are pooled (373 genomes, 1 to 3,261 contigs). Each point is one genome–tool pair. Dashed lines are loess fits, and the shaded bands are their 95% confidence intervals. Undescribed CDS (%) is defined as in Figure 3.
