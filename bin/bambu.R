#!/usr/bin/env Rscript

# --- Load necessary libraries ---

library(ggplot2)
library(Rsamtools)
library(bambu)
library(readr)
library(BiocParallel)
library(rtracklayer)
library(optparse)

# --- Parse command-line arguments ---
option_list <- list(
  make_option(c("-g", "--genome"), type = "character", default = NULL,
              help = "Path to the genome FASTA file", metavar = "character"),
  make_option(c("-a", "--annotation"), type = "character", default = NULL,
              help = "Path to the GTF annotation file", metavar = "character"),
  make_option(c("-b", "--bamfiles"), type = "character", default = NULL,
              help = "Path to a file containing a list of BAM files, one per line", metavar = "character"),
  make_option(c("-s", "--sampleinfo"), type = "character", default = NULL,
              help = "Path to the sample information Excel file", metavar = "character"),
  make_option(c("-n", "--ncores"), type = "numeric", default = 1,
              help = "Number of cores to use for parallel processing", metavar = "numeric"),
  make_option(c("-o", "--outdir"), type = "character", default = "output",
              help = "Output directory", metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

print(opt)

# Check if required arguments are provided
if (is.null(opt$genome) ||
    is.null(opt$annotation) || is.null(opt$bamfiles) || is.null(opt$sampleinfo)) {
  print_help(opt_parser)
  stop("Missing required arguments.")
}

# --- Define file paths ---
genomeSequence <- opt$genome
gtf.file <- opt$annotation
bamFiles <- readLines(opt$bamfiles)  # Read BAM file paths from the input file
sample_info_file <- opt$sampleinfo
output_dir <- opt$outdir
ncores <- opt$ncores  # Use the specified number of cores

# Create output directory if it doesn't exist
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# --- Prepare annotations ---
annotation <- tryCatch({
  prepareAnnotations(gtf.file)
}, error = function(e) {
  stop(paste("Error preparing annotations:", e$message))
})

# --- Load BAM files ---
totalData <- tryCatch({
  BamFileList(bamFiles)
}, error = function(e) {
  stop(paste("Error loading BAM files:", e$message))
})

# --- Run bambu ---
se.multiSample <- tryCatch({
  bambu(ncore = ncores,  # Use the specified number of cores
        reads = totalData,
        annotations = annotation,
        genome = genomeSequence,
        trackReads = TRUE,
        opt.discovery = list(min.txScore.singleExon = 0))
}, error = function(e) {
  stop(paste("Error running bambu:", e$message))
})

# --- Add sample metadata ---
sample_info <- tryCatch({
  read.table(sample_info_file, sep="\t")
}, error = function(e) {
  stop(paste("Error reading sample information file:", e$message))
})

colData(se.multiSample)$cellLine <- as.factor(sample_info[1])
colData(se.multiSample)$groupVar <- sample_info[1]

# --- Transcript-level analysis ---

# Convert to gene expression
seGene.multiSample <- transcriptToGeneExpression(se.multiSample)

# Add sample metadata to gene-level object
colData(seGene.multiSample)$cellLine <- as.factor(sample_info$cellLine)
colData(seGene.multiSample)$groupVar <- sample_info$cellLine

# --- Extract and save expression data ---

# Save the different expression matrices
expr_matrices <- list(
  Gcounts = assays(seGene.multiSample)$counts,
  Tcounts = assays(se.multiSample)$counts,
  Tcounts_CPM = assays(se.multiSample)$CPM,
  Tcounts_UC = assays(se.multiSample)$uniqueCounts,
  Tcounts_FLC = assays(se.multiSample)$fullLengthCounts
)

# Use lapply to iterate and save each matrix with its corresponding name
lapply(names(expr_matrices), function(x) {
  write.csv(expr_matrices[[x]], file = file.path(output_dir, paste0("bambu_", x, "_exp.csv")))
})

# --- Save SummarizedExperiment objects ---
saveRDS(se.multiSample, file = file.path(output_dir, "se_multiSample.rds"))
saveRDS(seGene.multiSample, file = file.path(output_dir, "seGene_multiSample.rds"))

# --- Save Bambu's official outputs ---
writeBambuOutput(se.multiSample, output_dir, prefix = "BambuOutput_")

# --- Save the new transcripts
transcript_annotations <- rtracklayer::import("BambuOutput_extended_annotations.gtf")

newtx_gtf <- transcript_annotations[grep("^BambuTx", transcript_annotations$transcript_id)]
rtracklayer::export(newtx_gtf, "bambu_novel_transcripts.gtf")

# --- Create and save plots ---

# Create a list of plots
plots <- list(
  heatmap_transcript = plotBambu(se.multiSample, type = "heatmap"),
  pca_transcript = plotBambu(se.multiSample, type = "pca"),
  heatmap_gene = plotBambu(seGene.multiSample, type = "heatmap")
)

# Use lapply to iterate and save each plot with its corresponding name
lapply(names(plots), function(x) {
  # Determine file extension based on plot type
  file_ext <- if (grepl("heatmap", x)) "png" else "pdf"

  # Save the plot
  file_path <- file.path(output_dir, paste0(x, ".", file_ext))

  # Use the appropriate device based on file extension
  if (file_ext == "png") {
    png(file_path, width = 10, height = 8, units = "in", res = 600)  # Adjust dimensions and resolution as needed
  } else {
    pdf(file_path, width = 10, height = 8)  # Adjust dimensions as needed
  }

  print(plots[[x]])  # Print the plot to the device
  dev.off()
})
