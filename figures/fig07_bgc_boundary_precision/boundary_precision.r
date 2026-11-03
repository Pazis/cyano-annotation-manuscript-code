# =============================================================================
# BGC BOUNDARY DEFINITION PRECISION - DOT PLOT WITH LINES (Fig. 5B)
# =============================================================================

required_packages <- c("readxl", "ggplot2", "dplyr")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(readxl); library(ggplot2); library(dplyr)
})

# --- USER CONFIGURATION ------------------------------------------------------
FILE_PATH  <- "data/processed/BGC_analyses_tables.xlsx"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig07_bgc_boundary_precision"

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
ref_line <- data.frame(slope = 1, intercept = 0, Line = "Perfect match")

p3 <- ggplot(df, aes(x = `% AntiSMASH Covered`, y = `% GECCO Covered`)) +
  geom_abline(data = ref_line,
              aes(slope = slope, intercept = intercept, linetype = Line),
              colour = "black", linewidth = 0.9 * GEOM_SCALE, key_glyph = "path", inherit.aes = FALSE) +
  geom_point(size = 2.5 * GEOM_SCALE, alpha = 0.8, colour = "#e74c3c") +
  scale_linetype_manual(values = c("Perfect match" = "dashed")) +
  scale_x_continuous(breaks = seq(0, 100, 25)) +
  scale_y_continuous(breaks = seq(0, 100, 25)) +
  coord_cartesian(xlim = c(0, 102), ylim = c(0, 102), expand = FALSE, clip = "off") +
  labs(x = "antiSMASH region covered (%)",
       y = "GECCO cluster covered (%)") +
  guides(linetype = guide_legend(title = NULL)) +
  theme_genome() +
  theme(legend.position         = "inside",
        legend.position.inside  = c(0.97, 0.03),
        legend.justification    = c(1, 0),
        legend.background       = element_rect(fill = "white", colour = "grey60"),
        legend.key.width        = unit(1.2, "cm"),
        legend.text             = element_text(size = 9 * FS),
        legend.margin           = margin(3, 6, 3, 6))

ggsave(file.path(OUTPUT_DIR, "fig07.png"),
       p3, width = 8, height = 6, dpi = 300)
message("Saved fig07.png")