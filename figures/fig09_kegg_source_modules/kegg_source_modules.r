# =============================================================================
# KEGG SOURCE CONTRIBUTION PER GENOME (Fig. 6B)
# =============================================================================

required_packages <- c("ggplot2", "dplyr", "tidyr")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(tidyr)
})

# --- USER CONFIGURATION ------------------------------------------------------
DATA_DIR   <- "data/raw/kegg_analyses"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig09_kegg_source_modules"

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# --- COLOUR PALETTE ----------------------------------------------------------
SOURCE_COLORS <- c("Bakta"                                  = "#999999",
                   "eggNOG-mapper, InterProScan-confirmed" = "#D55E00",
                   "eggNOG-mapper only"                     = "#F2B48C")
GROUP_ORDER <- c("Synechococcales - coccoid", "Synechococcales - filamentous",
                 "Chroococcales - Microcystis", "Chroococcales - other", "Nostocales")

# --- 1. LOAD DATA --------------------------------------------------------------
genomes <- read.csv(file.path(DATA_DIR, "genomes.csv"), check.names = FALSE) %>%
  mutate(group = factor(group, levels = GROUP_ORDER))

pairs <- read.csv(file.path(DATA_DIR, "protein_ko.csv"), check.names = FALSE) %>%
  mutate(source = case_when(provenance == "Bakta" ~ "Bakta",
                            ips_confirmed == "True" | ips_confirmed == TRUE ~ "eggNOG-mapper, InterProScan-confirmed",
                            TRUE ~ "eggNOG-mapper only")) %>%
  count(genome, source) %>%
  left_join(select(genomes, accession, organism, group), by = c("genome" = "accession")) %>%
  group_by(genome) %>% mutate(total = sum(n)) %>% ungroup() %>%
  mutate(source   = factor(source, levels = rev(names(SOURCE_COLORS))),
         organism = reorder(organism, total))

# --- 2. THEME ------------------------------------------------------------------
theme_genome <- function() {
  theme_bw(base_size = BASE_SIZE) +
    theme(plot.title    = element_text(face = "bold", hjust = 0.5, size = 13),
          plot.subtitle = element_text(hjust = 0.5, colour = "grey40", size = 10),
          axis.title    = element_text(face = "bold"),
          legend.title  = element_text(face = "bold"),
          strip.text    = element_text(face = "bold"),
          panel.grid.minor = element_blank())
}

# --- 3. PROTEIN-KO PAIRS PER GENOME BY SOURCE ----------------------------------
fig <- ggplot(pairs, aes(x = n, y = organism, fill = source)) +
  geom_col(width = 0.8) +
  facet_grid(group ~ ., scales = "free_y", space = "free_y",
             labeller = labeller(group = label_wrap_gen(14))) +
  scale_fill_manual(values = SOURCE_COLORS, breaks = names(SOURCE_COLORS), name = "KO source") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.03))) +
  labs(x = "Protein–KO pairs", y = NULL) +
  theme_genome() +
  theme(axis.text.y = element_text(face = "italic"),
        strip.text.y = element_text(angle = 0),
        legend.position = "bottom", legend.direction = "vertical")

ggsave(file.path(OUTPUT_DIR, "fig09.png"), fig, width = 7, height = 10, dpi = 300)
ggsave(file.path(OUTPUT_DIR, "fig09.pdf"), fig, width = 7, height = 10, device = cairo_pdf)
message("Saved fig09.")
