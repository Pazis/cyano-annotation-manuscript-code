# =============================================================================
# HYPOTHETICAL-PROTEIN FRACTION BY TOOL AND CONTIGUITY - VIOLIN + SWARM (Fig. 4A)
# =============================================================================

required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "ggbeeswarm")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(readxl); library(ggplot2); library(dplyr)
  library(tidyr);  library(ggbeeswarm)
})

# --- USER CONFIGURATION ------------------------------------------------------
SUMMARY_FILE <- "data/processed/annotation_summaries.xlsx"
GOOD_FILE  <- "S7 High Contiguity"  # sheets of SUMMARY_FILE
BAD_FILE   <- "S6 Low Contiguity"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig03_described_cds_percentage"

# Columns are read by name, so added or reordered columns cannot shift the data
COL_INITIAL_HYP  <- "Initial_Hypotheticals"   # Bakta
COL_ENHANCED_HYP <- "Enhanced_Hypotheticals"  # Cyan-ote
COL_PROKKA_HYP   <- "Prokka_Hypotheticals"    # Prokka
COL_CDS_COUNT    <- "CDS_count"               # denominator (CDS space)

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# --- COLOUR PALETTE ----------------------------------------------------------
TOOL_COLORS <- c("Prokka"   = "#0072B2",
                 "Bakta"    = "#999999",
                 "Cyan-ote" = "#D55E00")

# --- 1. LOAD DATA & CALCULATE HYPOTHETICAL-PROTEIN FRACTION ------------------
to_num <- function(x) suppressWarnings(as.numeric(gsub("[%,]", "", trimws(as.character(x)))))

load_data <- function(path, quality_label) {
  message(sprintf("Loading [%s]: %s", quality_label, path))
  df <- read_excel(SUMMARY_FILE, sheet = path)

  needed <- c(COL_INITIAL_HYP, COL_ENHANCED_HYP, COL_PROKKA_HYP, COL_CDS_COUNT)
  missing_cols <- setdiff(needed, names(df))
  if (length(missing_cols) > 0)
    stop(path, " is missing column(s): ", paste(missing_cols, collapse = ", "))

  genes <- to_num(df[[COL_CDS_COUNT]])
  genes[genes == 0] <- NA

  tibble(
    Quality    = quality_label,
    Prokka     = to_num(df[[COL_PROKKA_HYP]])   / genes * 100,
    Bakta      = to_num(df[[COL_INITIAL_HYP]])  / genes * 100,
    `Cyan-ote` = to_num(df[[COL_ENHANCED_HYP]]) / genes * 100
  )
}

df_all <- bind_rows(load_data(GOOD_FILE, "High Contiguity"),
                    load_data(BAD_FILE,  "Low Contiguity")) %>%
  mutate(Quality = factor(Quality, levels = c("High Contiguity", "Low Contiguity")))

long_undesc <- df_all %>%
  pivot_longer(c(Prokka, Bakta, `Cyan-ote`), names_to = "Tool", values_to = "Undesc_CDS_PCT") %>%
  mutate(Tool = factor(Tool, levels = c("Prokka", "Bakta", "Cyan-ote"))) %>%
  filter(!is.na(Undesc_CDS_PCT))

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

# --- 3. COMBINED VIOLIN + SWARM PLOT -------------------------------------------
fig1 <- ggplot(long_undesc, aes(x = Tool, y = Undesc_CDS_PCT, fill = Tool)) +
  geom_violin(trim = TRUE, alpha = 0.6, width = 0.7,
              colour = "black", draw_quantiles = 0.5) +
  geom_beeswarm(size = 0.5 * GEOM_SCALE, alpha = 0.5, colour = "#555252",
                cex = 0.6, corral = "gutter", corral.width = 0.7) +
  facet_wrap(~Quality, ncol = 2) +
  scale_fill_manual(values = TOOL_COLORS) +
  labs(x = NULL, y = "Hypothetical proteins (% of CDS)") +
  theme_genome() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 20, hjust = 1))

ggsave(file.path(OUTPUT_DIR, "fig03.png"),
       fig1, width = 12, height = 7, dpi = 300)
message("Saved Figure 3.")