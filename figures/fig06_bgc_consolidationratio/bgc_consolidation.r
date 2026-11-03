# =============================================================================
# BGC LOCUS FRAGMENTATION - CONSOLIDATION RATIO DISTRIBUTION (Fig. 5A)
# =============================================================================

required_packages <- c("readxl", "ggplot2", "dplyr")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(readxl); library(ggplot2); library(dplyr)
})

# --- USER CONFIGURATION ------------------------------------------------------
FILE_PATH  <- "data/processed/BGC_analyses_tables.xlsx"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig06_bgc_consolidationratio"

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# --- 1. LOAD & FILTER DATA ---------------------------------------------------
df <- read_excel(FILE_PATH, sheet = "S8 BGC consolidation") %>%
  filter(`Locus Tag` != "AVERAGE") %>%
  filter(`AntiSMASH Count` > 0 & `GECCO Count` > 0 & `Overlapping Clusters` > 0)

message(sprintf("Genomes with BGCs in both tools: %d", nrow(df)))

# --- 2. THEME ----------------------------------------------------------------
theme_genome <- function() {
  theme_bw(base_size = BASE_SIZE) +
    theme(plot.title    = element_text(face = "bold", hjust = 0.5, size = 13),
          plot.subtitle = element_text(hjust = 0.5, colour = "grey40", size = 10),
          axis.title    = element_text(face = "bold"),
          legend.title  = element_text(face = "bold"),
          strip.text    = element_text(face = "bold"),
          panel.grid.minor = element_blank())
}

# --- 3. PLOT -------------------------------------------------------------------
mean_ratio <- mean(df$`Consolidation Ratio`, na.rm = TRUE)

p2 <- ggplot(df, aes(x = `Consolidation Ratio`)) +
  geom_histogram(aes(y = after_stat(density)), bins = 10,
                 fill = "#9b59b6", colour = "black", alpha = 0.7) +
  geom_density(colour = "black", linewidth = 1 * GEOM_SCALE) +
  geom_vline(aes(xintercept = mean_ratio, colour = "Mean"),
             linetype = "dashed", linewidth = 1 * GEOM_SCALE, key_glyph = "path") +
  scale_colour_manual(name = NULL, values = c("Mean" = "red"),
                      labels = sprintf("Mean: %.2f", mean_ratio)) +
  labs(x = "antiSMASH regions per GECCO cluster", y = "Density") +
  theme_genome() +
  theme(legend.position         = "inside",
        legend.position.inside  = c(0.97, 0.5),
        legend.justification    = c(1, 0.5),
        legend.background       = element_rect(fill = "white", colour = "grey60"),
        legend.key.width        = unit(1.2, "cm"),
        legend.text             = element_text(size = 9 * FS),
        legend.margin           = margin(3, 6, 3, 6))

ggsave(file.path(OUTPUT_DIR, "fig06.png"),
       p2, width = 8, height = 6, dpi = 300)
message("Saved fig06.png")