# Figure 3 — Undescribed CDS by tool and assembly continuity

Violin + swarm plot of undescribed CDS (%) for Prokka, Bakta and Cyan-ote, faceted into high- (164 genomes) and low-continuity (209) cyanobacterial assemblies. Undescribed CDS % = hypothetical proteins ÷ gene count × 100.

**Inputs:** `data/processed/GOODQ_PBC_Summary.csv`, `BADQ_PBC_Summary.csv`
**Script:** `described_cds_percentage.r`
**Output:** `fig03.png`

## Legend draft

Undescribed CDS in Prokka, Bakta and Cyan-ote annotations of 373 cyanobacterial genomes, split into high-continuity (n = 164) and low-continuity (n = 209) assemblies. Undescribed CDS (%) is the number of CDS annotated as hypothetical proteins divided by the total gene count, × 100. Each point is one genome. The violins show the distribution, and the horizontal line in each violin is the median. Median values were 52.1%, 11.4% and 9.4% in high-continuity assemblies and 54.7%, 20.5% and 10.7% in low-continuity assemblies (Prokka, Bakta, Cyan-ote).
