# Figure 1 — Undescribed coding space in *E. coli*, by sequencing technology

Violin + swarm plot of the undescribed coding space (%) for Bakta and Cyan-ote, on *E. coli* assemblies from Illumina and from PacBio reads (30 each).

**Inputs:** `data/processed/Ecoli_Illumina_Summary.csv`, `Ecoli_PacBio_Summary.csv` (columns `Initial_Hypotheticals`, `Enhanced_Hypotheticals`, `CDS_count`; undescribed CDS % = hypotheticals / CDS count × 100)
**Script:** `hypotheticals_cds_illumina_pacbio.r`
**Output:** `fig01.png`

## Legend draft

Undescribed coding space in the Bakta baseline and the integrated Cyan-ote annotation of 60 *Escherichia coli* genomes, 30 assembled from Illumina reads and 30 from PacBio reads. Each point is one genome. The violins show the distribution, and the horizontal line in each violin is the median. Median undescribed coding space fell from 0.80% to 0.72% for the Illumina assemblies and from 0.60% to 0.57% for the PacBio assemblies. 
