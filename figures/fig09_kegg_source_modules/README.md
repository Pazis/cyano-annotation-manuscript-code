# Figure 9 — Source contribution

Protein–KO pairs per genome, by source.

**Inputs:** `data/raw/kegg_analyses/protein_ko.csv`, `genomes.csv`
**Script:** `kegg_source_modules.r`, run from the repo root
**Output:** `fig09.pdf` (+ `fig09.png`)

## Legend draft

Protein–KO associations in the integrated annotation of each genome, grouped by taxonomic order. Grey: assigned by Bakta (baseline). Dark orange: added by eggNOG-mapper, with InterProScan confirmation (the eggNOG Pfam domains map to an InterPro entry that InterProScan also detected on the protein). Light orange: added by eggNOG-mapper without that confirmation. InterProScan assigns no KOs itself.
