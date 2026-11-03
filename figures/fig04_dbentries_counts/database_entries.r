# =============================================================================
# FUNCTIONAL ANNOTATION (DBXREF) COUNTS - PER DB, PER TOOL, PER CONTIGUITY (Fig. 4B)
# =============================================================================

required_packages <- c("readxl", "ggplot2", "dplyr", "purrr", "scales")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(readxl); library(ggplot2); library(dplyr)
  library(purrr);  library(scales)
})

# --- USER CONFIGURATION ------------------------------------------------------
SUMMARY_FILE <- "data/processed/annotation_summaries.xlsx"
GOOD_FILE  <- "S7 High Contiguity"  # sheets of SUMMARY_FILE
BAD_FILE   <- "S6 Low Contiguity"
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig04_dbentries_counts/"

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

# --- 3. FIGURE 4: FUNCTIONAL ANNOTATION COUNTS, ONE PANEL PER DATABASE (2x2) ---
metrics  <- c("GO_entries", "COG_entries", "KEGG_entries", "EC_entries")
prefixes <- c("Prokka"   = "Prokka",
              "Bakta"    = "Initial",
              "Cyan-ote" = "Enhanced")

counts_long <- map_dfr(metrics, function(m) {
  map_dfr(names(prefixes), function(tool_label) {
    col <- paste0(prefixes[[tool_label]], "_", m)
    if (!col %in% names(df_all)) {
      message("  Column not found, skipping: ", col)
      return(NULL)
    }
    df_all %>%
      group_by(Quality) %>%
      summarise(Count = sum(suppressWarnings(as.numeric(.data[[col]])), na.rm = TRUE),
                .groups = "drop") %>%
      mutate(Metric = gsub("_entries", "", m), Tool = tool_label)
  })
}) %>%
  mutate(Tool   = factor(Tool, levels = names(TOOL_COLORS)),
         Metric = factor(Metric, levels = gsub("_entries", "", metrics)))

fig04 <- ggplot(counts_long, aes(x = Quality, y = Count, fill = Tool)) +
  geom_col(position = position_dodge(0.75), width = 0.65,
           colour = "white", linewidth = 0.3) +
  facet_wrap(~Metric, scales = "free_y", ncol = 2) +
  scale_fill_manual(values = TOOL_COLORS) +
  scale_x_discrete(labels = c("High Contiguity" = "High", "Low Contiguity" = "Low")) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.05))) +
  labs(x = "Assembly contiguity", y = "Total cross-references", fill = "Tool") +
  theme_genome() +
  theme(legend.position = "bottom")

for (ext in c("png", "pdf"))
  ggsave(file.path(OUTPUT_DIR, paste0("fig04.", ext)),
         fig04, width = 11, height = 9, dpi = 300)
message("Saved Figure 4.")
