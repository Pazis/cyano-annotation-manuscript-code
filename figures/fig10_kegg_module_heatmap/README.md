# Figure 10 — KEGG module status per genome

**Panels:** single heatmap; rows are genomes faceted by taxonomic group, columns are the 8 panel modules with a Bakta and a Cyan-ote column each.

**Inputs:** `data/raw/kegg_analyses/supp_genome_module.csv`
**Script:** `kegg_module_heatmap.r`, run from the repo root
**Output:** `fig10.pdf` (+ `fig10.png`)

## Legend draft

Completeness of eight cyanobacteria-relevant KEGG modules in the Bakta baseline and the integrated Cyan-ote annotation of 40 genomes, grouped by taxonomic order. Status follows the KEGG Mapper convention: complete, 1 or 2 blocks missing, or incomplete (more than 2 blocks missing). Nitrogen fixation (M00175) becomes complete in all Nostocales and in the known unicellular diazotrophs (e.g. *Crocosphaera*, UCYN-A), but not in coccoid Synechococcales. As expected from its reduced genome, UCYN-A lacks a complete photosystem II and Calvin cycle. M00611 combines M00161, M00163 and M00165.
