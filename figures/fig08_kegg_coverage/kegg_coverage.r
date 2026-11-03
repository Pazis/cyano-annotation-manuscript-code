# =============================================================================
# KEGG METABOLIC KO COVERAGE - BAKTA vs CYAN-OTE, MEDIAN PER GROUP
# (Fig 8 = T2 tier; figures/supplementary/figS01_kegg_coverage_T1 reuses this script for T1)
# =============================================================================

required_packages <- c("ggplot2", "dplyr", "tidyr", "readxl")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(tidyr); library(readxl)
})

# --- USER CONFIGURATION ------------------------------------------------------
DATA_FILE <- "data/processed/KEGG_analyses_tables.xlsx"
if (!exists("TIER"))       TIER       <- "T2"   # T2 = KEGG Metabolism KOs, T1 = 8-module panel KOs
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig08_kegg_coverage"
if (!exists("FIG_NAME"))   FIG_NAME   <- "fig08"

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# --- COLOUR PALETTE ----------------------------------------------------------
TOOL_COLORS <- c("Bakta"    = "#999999",
                 "Cyan-ote" = "#D55E00")
GROUP_COLORS <- c("Synechococcales - coccoid"     = "#56B4E9",
                  "Synechococcales - filamentous" = "#0072B2",
                  "Chroococcales - Microcystis"   = "#117733",
                  "Chroococcales - other"         = "#44AA99",
                  "Nostocales"                    = "#CC79A7")
SET_LABELS <- c("all" = "All proteins", "hypothetical" = "Bakta-hypothetical proteins")

# --- 1. LOAD DATA --------------------------------------------------------------
# Genome groups come from the module-status sheet (one group per genome)
genomes  <- read_excel(DATA_FILE, sheet = "S18 Module Status") %>% distinct(genome, group)
coverage <- read_excel(DATA_FILE, sheet = "S17 Coverage per genome") %>%
  filter(tier == TIER) %>%
  left_join(genomes, by = "genome")
# Median per-genome gain for the facet labels (same values as tables/kegg_table1.csv)
stats <- coverage %>% group_by(set) %>% summarise(median = median(gain_pp), .groups = "drop")

long <- coverage %>%
  pivot_longer(c(pct_baseline, pct_integrated), names_to = "state", values_to = "pct") %>%
  mutate(Tool  = factor(ifelse(state == "pct_baseline", "Bakta", "Cyan-ote"), levels = names(TOOL_COLORS)),
         set   = factor(SET_LABELS[set], levels = SET_LABELS),
         group = factor(group, levels = names(GROUP_COLORS)))

medians <- long %>% group_by(set, Tool) %>% summarise(pct = median(pct), .groups = "drop")
group_medians <- long %>% group_by(set, Tool, group) %>% summarise(pct = median(pct), .groups = "drop")

labels <- stats %>%
  mutate(set = factor(SET_LABELS[set], levels = SET_LABELS),
         label = sprintf("median gain %+.2f pp", median))

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

# --- 3. FIGURE: PAIRED SLOPE PLOT -----------------------------------------------
fig <- ggplot(long, aes(x = Tool, y = pct)) +
  geom_line(data = group_medians, aes(group = group, colour = group), linewidth = 0.9 * GEOM_SCALE) +
  geom_point(data = group_medians, aes(colour = group), size = 2.2 * GEOM_SCALE) +
  geom_line(data = medians, aes(group = 1), colour = "black", linewidth = 1.4 * GEOM_SCALE) +
  geom_point(data = medians, aes(fill = Tool), shape = 21, size = 4 * GEOM_SCALE, colour = "black", stroke = 0.8 * GEOM_SCALE) +
  geom_text(data = labels, aes(x = 1.5, y = Inf, label = label),
            vjust = 1.3, size = 3.4 * FS, colour = "grey20", inherit.aes = FALSE) +
  facet_wrap(~ set, scales = "free_y") +
  scale_colour_manual(values = GROUP_COLORS, name = "Group") +
  scale_fill_manual(values = TOOL_COLORS, name = "Median") +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.25)), position = "right") +
  labs(x = NULL, y = "Proteins with ≥1 qualifying KO (%)") +
  theme_genome() +
  theme(legend.position = "left")

ggsave(file.path(OUTPUT_DIR, paste0(FIG_NAME, ".png")), fig, width = 10, height = 5.5, dpi = 300)
ggsave(file.path(OUTPUT_DIR, paste0(FIG_NAME, ".pdf")), fig, width = 10, height = 5.5, device = cairo_pdf)
message(sprintf("Saved %s (%s).", FIG_NAME, TIER))
