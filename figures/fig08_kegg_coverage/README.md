# Figure 8 — Incremental metabolic KO coverage

**Panels:**
- A: All proteins
- B: Bakta-hypothetical proteins only

**Inputs:** `data/raw/kegg_analyses/coverage_per_genome.csv`, `table1_global.csv`, `genomes.csv`
**Script:** `kegg_coverage.r`, run from the repo root (`TIER` defaults to T2; Fig S1 reuses it for T1)
**Output:** `fig08.pdf` (+ `fig08.png`)

## Legend draft

Proportion of proteins with at least one KEGG Metabolism KO (map00010–map01099, global/overview maps excluded) in the Bakta baseline and the integrated Cyan-ote annotation, for 40 cyanobacterial genomes. Each coloured line joins the median of one taxonomic group; the black line joins the overall medians. (A) All predicted proteins. (B) Proteins Bakta labelled "hypothetical protein". The median gain (n = 40) is shown in each panel. All KO gains come from eggNOG-mapper; InterProScan assigns no KOs.
