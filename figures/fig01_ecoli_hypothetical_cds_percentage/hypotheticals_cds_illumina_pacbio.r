# =============================================================================
# HYPOTHETICAL-PROTEIN FRACTION - BAKTA vs CYAN-OTE BY SEQUENCING TECHNOLOGY (Fig. 3A)
# =============================================================================

required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", "ggbeeswarm")
to_install <- setdiff(required_packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(readxl); library(ggplot2); library(dplyr); library(tidyr); library(ggbeeswarm)
})

# --- USER CONFIGURATION ------------------------------------------------------
SUMMARY_FILE <- "data/processed/annotation_summaries.xlsx"
INPUT_FILES <- list(  # sheets of SUMMARY_FILE
  Illumina = "S4 Ecoli Ilummina",
  PacBio   = "S5 Ecoli PacBio"
)
if (!exists("OUTPUT_DIR")) OUTPUT_DIR <- "figures/fig01_ecoli_hypothetical_cds_percentage"

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Text and geometry scaling. merged_figures/merge_figures.r sets these per figure;
# the defaults reproduce the standalone look.
if (!exists("BASE_SIZE"))  BASE_SIZE  <- 12
if (!exists("GEOM_SCALE")) GEOM_SCALE <- 1
FS <- BASE_SIZE / 12  # scales hard-coded text sizes with the base font

# --- COLOUR PALETTE ----------------------------------------------------------
CONDITION_COLORS <- c("Bakta"    = "#999999",
                      "Cyan-ote" = "#D55E00")

# --- 1. LOAD DATA --------------------------------------------------------------
to_num <- function(x) suppressWarnings(as.numeric(gsub("[%,]", "", trimws(as.character(x)))))

# Hypothetical-protein fraction (%) = hypothetical proteins / CDS count x 100 (CDS space, as in fig03)
load_data <- function(path, tech) {
  df <- read_excel(SUMMARY_FILE, sheet = path)
  needed <- c("Initial_Hypotheticals", "Enhanced_Hypotheticals", "CDS_count")
  missing <- setdiff(needed, names(df))
  if (length(missing) > 0) stop(path, " is missing column(s): ", paste(missing, collapse = ", "))

  cds <- to_num(df$CDS_count)
  cds[cds == 0] <- NA
  tibble(Technology = tech,
         Bakta      = to_num(df$Initial_Hypotheticals)  / cds * 100,
         `Cyan-ote` = to_num(df$Enhanced_Hypotheticals) / cds * 100)
}

df_all <- bind_rows(lapply(names(INPUT_FILES), function(t) load_data(INPUT_FILES[[t]], t)))
if (nrow(df_all) == 0) stop("No data loaded. Check your file paths.")

df_long <- df_all %>%
  pivot_longer(c(Bakta, `Cyan-ote`), names_to = "Condition", values_to = "PCT") %>%
  mutate(Technology = factor(Technology, levels = names(INPUT_FILES)),
         Condition  = factor(Condition,  levels = names(CONDITION_COLORS))) %>%
  filter(!is.na(PCT))

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

# --- 3. VIOLIN + SWARM PLOT ------------------------------------------------------
DODGE <- 0.8

fig <- ggplot(df_long, aes(x = Technology, y = PCT, fill = Condition)) +
  geom_violin(trim = TRUE, alpha = 0.6, width = 0.75, colour = "black", draw_quantiles = 0.5, 
              position = position_dodge(DODGE)) +
  geom_beeswarm(aes(group = Condition), dodge.width = DODGE,
                size = 0.8 * GEOM_SCALE, alpha = 0.5, colour = "#555252",
                cex = 0.6, corral = "gutter", corral.width = 0.3) +
  scale_fill_manual(values = CONDITION_COLORS) +
  labs(x = NULL, y = "Hypothetical proteins (% of CDS)", fill = "Tool") +
  theme_genome() +
  theme(legend.position = "bottom")

ggsave(file.path(OUTPUT_DIR, "fig01.png"),
       fig, width = 10, height = 6, dpi = 300)
message("Saved fig01.png")