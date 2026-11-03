# =============================================================================
# BGC ANNOTATION GAIN - HYPOTHETICAL REDUCTION AND DBXREF GAINS INSIDE ANTISMASH CLUSTERS
# =============================================================================

required_packages <- c("ggplot2", "dplyr", "tidyr", "patchwork", "ggbeeswarm")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(tidyr); library(patchwork); library(ggbeeswarm)
})

# --- USER CONFIGURATION ------------------------------------------------------
if (!exists("DATA_DIR"))   DATA_DIR   <- "data/raw/bgc_analyses"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig11_bgc_annotation_gain"
FIG_NAME <- "fig11"

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# --- COLOUR PALETTE ----------------------------------------------------------
TOOL_COLORS <- c("Bakta"    = "#999999",
                 "Cyan-ote" = "#D55E00")
DBS <- c("KEGG", "GO", "COG", "EC")

# --- 1. LOAD DATA --------------------------------------------------------------
per_genome <- read.csv(file.path(DATA_DIR, "per_genome.csv"), check.names = FALSE) %>%
  filter(n_cds > 0)  # genomes without antiSMASH clusters

hyp <- per_genome %>%
  transmute(genome,
            Bakta      = 100 * n_hypothetical / n_cds,
            `Cyan-ote` = 100 * (n_hypothetical - n_recovered) / n_cds) %>%
  pivot_longer(-genome, names_to = "Tool", values_to = "pct") %>%
  mutate(Tool = factor(Tool, levels = names(TOOL_COLORS)))

dbx <- read.csv(file.path(DATA_DIR, "dbxref_by_db.csv"), check.names = FALSE) %>%
  inner_join(select(per_genome, genome, n_cds), by = "genome") %>%
  complete(nesting(genome, n_cds), db = DBS, fill = list(bakta = 0, enhanced = 0)) %>%
  pivot_longer(c(bakta, enhanced), names_to = "state", values_to = "n") %>%
  mutate(Tool = factor(ifelse(state == "bakta", "Bakta", "Cyan-ote"), levels = names(TOOL_COLORS)),
         db   = factor(db, levels = DBS),
         per_cds = n / n_cds)

db_labels <- dbx %>%
  group_by(db, Tool) %>% summarise(n = sum(n), .groups = "drop") %>%
  pivot_wider(names_from = Tool, values_from = n) %>%
  mutate(label = ifelse(Bakta > 0, sprintf("%+.0f%%", 100 * (`Cyan-ote` - Bakta) / Bakta), "new"))

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

# Per-genome points behind a box per tool
tool_boxes <- function(p) {
  p +
    geom_point(aes(colour = Tool), size = 1.2 * GEOM_SCALE, alpha = 0.6) +
    geom_boxplot(aes(fill = Tool), width = 0.35, alpha = 0.6, outlier.shape = NA, colour = "black") +
    scale_colour_manual(values = TOOL_COLORS, guide = "none") +
    scale_fill_manual(values = TOOL_COLORS, guide = "none") +  # x-axis names the tool
    theme_genome() +
    theme(axis.text.x = element_text(face = "bold"))
}

# --- 3. PANELS -------------------------------------------------------------------
# Violin + swarm, as in the other hypothetical-CDS figures (fig01, fig03)
p_hyp <- ggplot(hyp, aes(x = Tool, y = pct, fill = Tool)) +
  geom_violin(trim = TRUE, alpha = 0.6, width = 0.7,
              colour = "black", draw_quantiles = 0.5) +
  geom_beeswarm(size = 0.5 * GEOM_SCALE, alpha = 0.5, colour = "#555252",
                cex = 0.6, corral = "gutter", corral.width = 0.7) +
  scale_fill_manual(values = TOOL_COLORS, guide = "none") +
  labs(x = NULL, y = "Hypothetical proteins (% of cluster CDS)") +
  theme_genome() +
  theme(axis.text.x = element_text(face = "bold"))

p_dbx <- tool_boxes(ggplot(dbx, aes(x = Tool, y = per_cds))) +
  geom_text(data = db_labels, aes(x = 1.5, y = Inf, label = label),
            vjust = 1.4, size = 3.4 * FS, colour = "grey20", inherit.aes = FALSE) +
  facet_wrap(~ db, nrow = 1, scales = "free_y") +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.18))) +
  labs(x = NULL, y = "Cross-references per cluster CDS")

fig <- (p_hyp + p_dbx + plot_layout(widths = c(1, 3))) +
  plot_annotation(tag_levels = "A")

ggsave(file.path(OUTPUT_DIR, paste0(FIG_NAME, ".png")), fig, width = 12, height = 5.5, dpi = 300)
ggsave(file.path(OUTPUT_DIR, paste0(FIG_NAME, ".pdf")), fig, width = 12, height = 5.5, device = cairo_pdf)
message(sprintf("Saved %s.", FIG_NAME))
