# Figure 2 — Gain in functional annotations in *E. coli*, by sequencing technology

Percentage increase of Cyan-ote over Bakta in GO, COG, KEGG and EC entries, summed over the Illumina and the PacBio *E. coli* assemblies.

**Inputs:** `data/processed/Ecoli_Illumina_Summary.csv`, `Ecoli_PacBio_Summary.csv` (`Initial_*_entries`, `Enhanced_*_entries`)
**Script:** `ecoli_database_entries.r.r`
**Output:** `fig02.png`

## Legend draft

Percentage increase in GO, COG, KEGG and EC cross-references from the Bakta baseline to the integrated Cyan-ote annotation in *E. coli*. Entries are summed over the 30 Illumina (blue) and the 30 PacBio (orange) assemblies before the increase is calculated. Gains were similar for both sequencing technologies: GO 16.6% / 17.3%, COG 35.4% / 38.9%, KEGG 107.2% / 105.6% and EC 9.0% / 8.0% (Illumina / PacBio).
