# =============================================================================
# PERCENTAGE INCREASE IN FUNCTIONAL ANNOTATIONS BY SEQUENCING TECHNOLOGY (Fig. 3B)
# =============================================================================

required_packages <- c("readxl", "ggplot2", "dplyr", "purrr")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(readxl); library(ggplot2); library(dplyr); library(purrr)
})

# --- USER CONFIGURATION ------------------------------------------------------
SUMMARY_FILE <- "data/processed/annotation_summaries.xlsx"
INPUT_FILES <- list(  # sheets of SUMMARY_FILE
  Illumina = "S4 Ecoli Ilummina",
  PacBio   = "S5 Ecoli PacBio"
)
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig02_ecoli_dbentries_prc_increase"

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# Technology colours (seaborn "muted" blue and orange, as in the Python version)
TECH_COLORS <- c("Illumina" = "#4878D0",
                 "PacBio"   = "#EE854A")

metrics <- c("GO_entries", "COG_entries", "KEGG_entries", "EC_entries")

# --- 1. LOAD DATA & CALCULATE % INCREASE -----------------------------------------
to_num <- function(x) suppressWarnings(as.numeric(gsub("[%,]", "", trimws(as.character(x)))))

calc_increase <- function(path, tech) {
  df <- read_excel(SUMMARY_FILE, sheet = path)

  map_dfr(metrics, function(m) {
    col_init <- paste0("Initial_",  m)
    col_enh  <- paste0("Enhanced_", m)
    if (!all(c(col_init, col_enh) %in% names(df))) {
      message("  Column not found, skipping: ", m)
      return(NULL)
    }
    total_init <- sum(to_num(df[[col_init]]), na.rm = TRUE)
    total_enh  <- sum(to_num(df[[col_enh]]),  na.rm = TRUE)

    tibble(Technology = tech,
           Database   = sub("_entries", "", m),
           Percent_Increase = if (total_init > 0) (total_enh - total_init) / total_init * 100 else 0)
  })
}

df_inc <- bind_rows(lapply(names(INPUT_FILES), function(t) calc_increase(INPUT_FILES[[t]], t)))
if (nrow(df_inc) == 0) stop("No data loaded. Check your file paths and column names.")

df_inc <- df_inc %>%
  mutate(Technology = factor(Technology, levels = names(TECH_COLORS)),
         Database   = factor(Database, levels = sub("_entries", "", metrics)))

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

# --- 3. FIGURE 4: % INCREASE PER DATABASE ----------------------------------------
fig4 <- ggplot(df_inc, aes(x = Database, y = Percent_Increase, fill = Technology)) +
  geom_col(position = position_dodge(0.75), width = 0.65,
           colour = "white", linewidth = 0.3) +
  geom_text(aes(label = sprintf("%.1f%%", Percent_Increase),
                vjust = ifelse(Percent_Increase >= 0, -0.5, 1.5)),
            position = position_dodge(0.75), size = 3.2 * FS, fontface = "bold") +
  scale_fill_manual(values = TECH_COLORS) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
  labs(x = "Database", y = "Increase in cross-references (%)",
       fill = "Sequencing platform") +
  theme_genome() +
  theme(legend.position = "bottom")

ggsave(file.path(OUTPUT_DIR, "fig02.png"),
       fig4, width = 10, height = 6, dpi = 300)
message("Saved fig02.png")