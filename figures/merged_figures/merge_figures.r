# =============================================================================
# MERGED FIGURES - builds the manuscript's multi-panel figures (SAM submission)
#   Figure_3 : fig01 + fig02                (E. coli hypotheticals, dbxref % increase)
#   Figure_4 : fig03 + fig04 + fig05 + fig12 (hypotheticals, dbxref counts,
#                                             contigs vs hypotheticals, pseudogenes)
#   Figure_5 : fig06 + fig07 + fig11        (BGC consolidation, boundaries, annotation gain)
#   Figure_6 : fig08 + fig09                (KEGG coverage, KO sources per genome)
#   Figure_7 : fig10                        (KEGG module heatmap, full page)
# =============================================================================
# Sources each figure script so the panels stay vector and in sync with them.
# Run from the repo root: Rscript figures/merged_figures/merge_figures.r
#
# Text size: SAM prints figures at most 190 mm wide. A figure built on a wider
# canvas is scaled down, and its text shrinks with it. base_for() picks the base
# font for each canvas so that axis text (0.8 x base in theme_bw) still prints at
# >= MIN_PT after scaling. Points and lines are left as tuned in each script,
# except where GEOM_SCALE is set.

suppressPackageStartupMessages({ library(ggplot2); library(patchwork) })

# --- USER CONFIGURATION ------------------------------------------------------
OUTPUT_DIR     <- "figures/merged_figures"
DPI            <- 600
PRINT_WIDTH_IN <- 190 / 25.4   # SAM full page width
MIN_PT         <- 7            # smallest printed text size for axis labels

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# Base font for a canvas of width_in inches (never below 9 pt)
base_for <- function(width_in) max(9, ceiling(10 * (MIN_PT / 0.8) * width_in / PRINT_WIDTH_IN) / 10)

# Run a figure script in its own environment; its own ggsave goes to a temp dir
load_fig <- function(script, base_size, geom_scale = 1) {
  e <- new.env()
  e$OUTPUT_DIR <- tempdir()
  e$BASE_SIZE  <- base_size
  e$GEOM_SCALE <- geom_scale
  sys.source(file.path("figures", script), envir = e)
  e
}

# Bold panel letters; set per plot because patchwork's `&` fails with this ggplot2 version
tagged <- function(p, base) p + theme(plot.tag = element_text(face = "bold", size = 1.25 * base))

save_fig <- function(fig, name, width, height, base, tags = TRUE) {
  if (tags) fig <- fig + plot_annotation(tag_levels = "A")
  ggsave(file.path(OUTPUT_DIR, paste0(name, ".png")), fig, width = width, height = height, dpi = DPI)
  ggsave(file.path(OUTPUT_DIR, paste0(name, ".pdf")), fig, width = width, height = height, device = cairo_pdf)
  message(sprintf("Saved %s (%.1f x %.1f in, base font %.1f pt, printed at %.0f%%).",
                  name, width, height, base, 100 * min(1, PRINT_WIDTH_IN / width)))
}

# --- FIGURE 3: E. coli -------------------------------------------------------------
W <- 13; H <- 5.5; B <- base_for(W)
p01 <- tagged(load_fig("fig01_ecoli_hypothetical_cds_percentage/hypotheticals_cds_illumina_pacbio.r", B)$fig, B)
p02 <- tagged(load_fig("fig02_ecoli_dbentries_prc_increase/ecoli_database_entries.r.r", B)$fig4, B)
save_fig(p01 + p02, "Figure_3", W, H, B)

# --- FIGURE 4: cyanobacterial cohort ---------------------------------------------
W <- 16; H <- 12; B <- base_for(W)
p03 <- tagged(load_fig("fig03_described_cds_percentage/described_cds_percentage.r", B)$fig1, B)
p04 <- tagged(load_fig("fig04_dbentries_counts/database_entries.r", B)$fig04, B)
p05 <- tagged(load_fig("fig05_hypotheticals_vs_continuity/hypotheticals_vs_continuity.r", B)$fig3, B)
p12 <- tagged(load_fig("fig12_pseudogene_ratio/pseudogene_ratio.r", B)$fig12, B)
# Only fig04's legend, collected into a centred row under the grid
no_legend <- theme(legend.position = "none")
save_fig((p03 + no_legend | p04 + guides(fill = guide_legend(direction = "horizontal"))) /
           (p05 + no_legend | p12 + no_legend) /
           guide_area() + plot_layout(guides = "collect", heights = c(1, 1, 0.06)),
         "Figure_4", W, H, B)

# --- FIGURE 5: BGCs --------------------------------------------------------------
W <- 12; H <- 9.5; B <- base_for(W)
p06 <- tagged(load_fig("fig06_bgc_consolidationratio/bgc_consolidation.r", B)$p2, B)
p07 <- tagged(load_fig("fig07_bgc_boundary_precision/boundary_precision.r", B)$p3, B)
f11 <- load_fig("fig11_bgc_annotation_gain/bgc_annotation_gain.r", B)
p11 <- tagged(f11$p_hyp, B) + tagged(f11$p_dbx, B) + plot_layout(widths = c(1, 3))
save_fig((p06 + p07) / p11 + plot_layout(heights = c(1, 1.1)), "Figure_5", W, H, B)

# --- FIGURE 6: KEGG coverage + KO sources (built at printed size) ------------------
W <- PRINT_WIDTH_IN; H <- 8.8; B <- base_for(W)
f08 <- load_fig("fig08_kegg_coverage/kegg_coverage.r", B, geom_scale = 0.6)
p08 <- tagged(f08$fig, B)
# fig08's two facets numbered 1 and 2 (the caption refers to them)
p08_numbered <- p08 +
  geom_text(data = data.frame(set = factor(levels(f08$long$set), levels = levels(f08$long$set)), label = c("1", "2")),
            aes(x = -Inf, y = Inf, label = label), hjust = -0.6, vjust = 1.4,
            size = B / .pt, fontface = "bold", inherit.aes = FALSE)
p09 <- tagged(load_fig("fig09_kegg_source_modules/kegg_source_modules.r", B)$fig, B)
# free(): stop the coverage panel aligning its axes with fig09's long genome labels
save_fig(free(p08_numbered) / p09 + plot_layout(heights = c(1, 2.2)), "Figure_6", W, H, B)

# --- FIGURE 7: KEGG module heatmap (full page, printed size) -----------------------
W <- PRINT_WIDTH_IN; H <- 9.4; B <- base_for(W)
p10 <- load_fig("fig10_kegg_module_heatmap/kegg_module_heatmap.r", B)$fig
save_fig(p10, "Figure_7", W, H, B, tags = FALSE)
