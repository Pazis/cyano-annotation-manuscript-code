# =============================================================================
# KEGG MODULE STATUS HEATMAP - BAKTA vs CYAN-OTE, PER GENOME, GROUPED BY ORDER (Fig. 7)
# =============================================================================

required_packages <- c("ggplot2", "dplyr", "tidyr", "readxl")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(tidyr); library(readxl)
})

# --- USER CONFIGURATION ------------------------------------------------------
DATA_FILE  <- "data/processed/KEGG_analyses_tables.xlsx"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig10_kegg_module_heatmap"

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# --- COLOUR PALETTE ----------------------------------------------------------
STATUS_COLORS <- c("complete"         = "#08519C",
                   "1 block missing"  = "#6BAED6",
                   "2 blocks missing" = "#C6DBEF",
                   "incomplete"       = "#F0F0F0")
GROUP_ORDER <- c("Synechococcales - coccoid", "Synechococcales - filamentous",
                 "Chroococcales - Microcystis", "Chroococcales - other", "Nostocales")
# Short names so they fit under the narrow columns; the caption gives the full module names
MODULE_LABELS <- c("M00161" = "PSII\nM00161",                "M00163" = "PSI\nM00163",
                   "M00165" = "Calvin\ncycle\nM00165",       "M00004" = "Pentose\nphos.\nM00004",
                   "M00854" = "Glycogen\nsynth.\nM00854",    "M00175" = "N₂\nfixation\nM00175",
                   "M00531" = "Nitrate\nassim.\nM00531",     "M00611" = "Oxygenic\nPS\nM00611")

# --- 1. LOAD DATA --------------------------------------------------------------
modules <- read_excel(DATA_FILE, sheet = "S18 Module Status") %>%
  mutate(review = requires_review == "True" | requires_review == TRUE)

long <- modules %>%
  pivot_longer(c(baseline_status, integrated_status), names_to = "state", values_to = "status") %>%
  mutate(Tool     = factor(ifelse(state == "baseline_status", "Bakta", "Cyan-ote"), levels = c("Bakta", "Cyan-ote")),
         status   = factor(status, levels = names(STATUS_COLORS)),
         module   = factor(module, levels = names(MODULE_LABELS)),
         group    = factor(group, levels = GROUP_ORDER),
         organism = factor(organism, levels = rev(sort(unique(organism)))))

flags <- long %>% filter(review, Tool == "Cyan-ote")

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

# --- 3. HEATMAP ------------------------------------------------------------------
fig <- ggplot(long, aes(x = Tool, y = organism, fill = status)) +
  geom_tile(colour = "white", linewidth = 0.4) +
  facet_grid(group ~ module, scales = "free_y", space = "free_y", switch = "x",
             labeller = labeller(module = MODULE_LABELS, group = label_wrap_gen(14))) +
  scale_fill_manual(values = STATUS_COLORS, drop = FALSE, name = "Module status") +
  guides(fill = guide_legend(override.aes = list(shape = NA, colour = "grey60"))) +
  scale_x_discrete(position = "top") +
  labs(x = NULL, y = NULL) +
  theme_genome() +
  theme(panel.grid = element_blank(),
        panel.spacing.x = unit(3, "pt"), panel.spacing.y = unit(4, "pt"),
        axis.text.x  = element_text(angle = 90, hjust = 0, vjust = 0.5),
        axis.text.y  = element_text(face = "italic"),
        axis.ticks   = element_blank(),
        strip.text.x = element_text(face = "plain"),
        strip.text.y = element_text(angle = 0),
        strip.placement = "outside",
        legend.position = "bottom")

ggsave(file.path(OUTPUT_DIR, "fig10.png"), fig, width = 12, height = 11, dpi = 300)
ggsave(file.path(OUTPUT_DIR, "fig10.pdf"), fig, width = 12, height = 11, device = cairo_pdf)
message("Saved fig10.")
