# =============================================================================
# CONTIGS vs HYPOTHETICAL-PROTEIN FRACTION - ALL GENOMES COMBINED (Fig. 4C)
# =============================================================================

required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(readxl); library(ggplot2); library(dplyr); library(tidyr)
})

# --- USER CONFIGURATION ------------------------------------------------------
SUMMARY_FILE <- "data/processed/annotation_summaries.xlsx"
GOOD_FILE  <- "S7 High Contiguity"  # sheets of SUMMARY_FILE
BAD_FILE   <- "S6 Low Contiguity"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig05_hypotheticals_vs_continuity"

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

# --- 1. LOAD DATA & CALCULATE HYPOTHETICAL-PROTEIN FRACTION ---------------------
to_num <- function(x) suppressWarnings(as.numeric(gsub("[%,]", "", trimws(as.character(x)))))

load_data <- function(path) {
  message(sprintf("Loading: %s", path))
  df <- read_excel(SUMMARY_FILE, sheet = path)

  needed <- c("Contigs", "CDS_count",
              "Prokka_Hypotheticals", "Initial_Hypotheticals", "Enhanced_Hypotheticals")
  missing_cols <- setdiff(needed, names(df))
  if (length(missing_cols) > 0)
    stop("Missing column(s) in ", basename(path), ": ", paste(missing_cols, collapse = ", "),
         "\n(Run countcontigs.py on this CSV first to add the Contigs column.)")

  genes <- to_num(df$CDS_count)
  genes[genes == 0] <- NA

  tibble(
    Contigs    = to_num(df$Contigs),
    Prokka     = to_num(df$Prokka_Hypotheticals)   / genes * 100,
    Bakta      = to_num(df$Initial_Hypotheticals)  / genes * 100,
    `Cyan-ote` = to_num(df$Enhanced_Hypotheticals) / genes * 100
  )
}

# Good and Bad are simply pooled - no quality label is kept
df_all <- bind_rows(load_data(GOOD_FILE), load_data(BAD_FILE)) %>%
  filter(!is.na(Contigs), Contigs > 0)

message(sprintf("Combined dataset: %d genomes with contig data", nrow(df_all)))

long_contigs <- df_all %>%
  pivot_longer(c(Prokka, Bakta, `Cyan-ote`), names_to = "Tool", values_to = "Undesc_CDS_PCT") %>%
  mutate(Tool = factor(Tool, levels = names(TOOL_COLORS))) %>%
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

# --- 3. FIGURE 3: CONTIGS vs UNDESCRIBED CDS ------------------------------------
fig3 <- ggplot(long_contigs, aes(x = Contigs, y = Undesc_CDS_PCT, colour = Tool)) +
  geom_point(size = 2 * GEOM_SCALE, alpha = 0.75) +
  geom_smooth(method = "loess", formula = y ~ x, se = TRUE,
              alpha = 0.12, linewidth = 1.1 * GEOM_SCALE, linetype = "dashed") +
  scale_colour_manual(values = TOOL_COLORS) +
  labs(x = "Number of contigs", y = "Hypothetical proteins (% of CDS)",
       colour = "Tool") +
  theme_genome() +
  theme(legend.position = "right")

ggsave(file.path(OUTPUT_DIR, "fig05.png"),
       fig3, width = 12, height = 6.5, dpi = 300)
message("Saved Figure 3.")