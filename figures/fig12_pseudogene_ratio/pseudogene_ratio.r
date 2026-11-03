# =============================================================================
# PSEUDOGENE BURDEN - PSEUDOGENE CANDIDATES AS % OF CDS, PER TOOL (Fig. 4D)
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
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig12_pseudogene_ratio/"

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

# --- 1. LOAD DATA --------------------------------------------------------------
load_data <- function(path, quality_label) {
  message(sprintf("Loading [%s]: %s", quality_label, path))
  df <- read_excel(SUMMARY_FILE, sheet = path)
  df$Quality <- quality_label
  df
}

df_all <- bind_rows(load_data(GOOD_FILE, "High Contiguity"),
                    load_data(BAD_FILE,  "Low Contiguity")) %>%
  mutate(Quality = factor(Quality, levels = c("High Contiguity", "Low Contiguity")))

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

# --- 3. FIGURE 12: PSEUDOGENE RATIO -------------------------------------------
# Total genes = CDS_count, the same denominator fig03 uses for undescribed CDS %.
pseudo_ratio <- function(pseudo) {
  if_else(!is.na(df_all$CDS_count) & df_all$CDS_count > 0,
          replace_na(pseudo, 0) / df_all$CDS_count * 100, NA_real_)
}

pseudo_long <- df_all %>%
  transmute(File, Quality,
            Prokka     = pseudo_ratio(Prokka_Pseudogene_candidates),
            Bakta      = pseudo_ratio(Initial_Pseudogene_candidates),
            `Cyan-ote` = pseudo_ratio(Enhanced_Pseudogene_candidates)) %>%
  pivot_longer(c(Prokka, Bakta, `Cyan-ote`),
               names_to = "Tool", values_to = "Pseudo_Ratio_PCT") %>%
  mutate(Tool = factor(Tool, levels = names(TOOL_COLORS)),
         Pseudo_Ratio_PCT = replace_na(Pseudo_Ratio_PCT, 0))

fig12 <- ggplot(pseudo_long, aes(x = Tool, y = Pseudo_Ratio_PCT, fill = Tool)) +
  geom_boxplot(alpha = 0.8, width = 0.5, outlier.shape = 21, outlier.size = 1.5 * GEOM_SCALE) +
  facet_wrap(~Quality, ncol = 2) +
  scale_fill_manual(values = TOOL_COLORS) +
  scale_y_continuous(labels = function(x) paste0(x, "%"),
                     expand = expansion(mult = c(0.02, 0.12))) +
  labs(x = NULL, y = "Pseudogene candidates (% of CDS)", fill = "Tool") +
  theme_genome() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1),
        legend.position = "bottom")

for (ext in c("png", "pdf"))
  ggsave(file.path(OUTPUT_DIR, paste0("fig12.", ext)),
         fig12, width = 11, height = 7, dpi = 300)
message("Saved Figure 12.")
