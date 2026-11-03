# Figure 11 — Annotation gain inside antiSMASH clusters

**Panels:**
- A: Hypothetical proteins as % of cluster CDS per genome, Bakta vs Cyan-ote (violin)
- B: KEGG, GO, COG and EC Dbxref entries per cluster CDS per genome, Bakta vs Cyan-ote (boxes)

**Inputs:** `data/raw/bgc_analyses/per_genome.csv`, `dbxref_by_db.csv` (from `python bgc_analyses/run_bgc_eval.py all`)
**Script:** `bgc_annotation_gain.r`, run from the repo root
**Output:** `fig11.pdf` (+ `fig11.png`)

## Legend draft

Annotation of genes inside antiSMASH-defined biosynthetic gene clusters (protoclusters) in the Bakta baseline and the integrated Cyan-ote annotation, for the N good-quality cyanobacterial genomes with at least one cluster. A CDS belongs to a cluster when it lies entirely within the cluster's coordinates. Each point is one genome. (A) Bakta "hypothetical protein" CDS as a percentage of cluster CDS. Violins show the distribution across genomes, with a line at the median. A protein counts as recovered when Cyan-ote names it with any product other than "hypothetical protein" or "consensus disorder prediction". (B) Dbxref entries per cluster CDS for KEGG (KOs), GO, COG (COG IDs; COG category letters excluded) and EC. Boxes show the median and IQR, and each panel has its own y-axis. The label above each panel is the change in total entries across all genomes.
