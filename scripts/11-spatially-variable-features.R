# Spatially variable features of Control heart

# Make results directories if they do not exist
output_dirs <- c("results",
                 "results/spatially-variable-features")

for (i in output_dirs) {
  if (!dir.exists(i)) {
    dir.create(i)
    print(paste0("made ", i, " directory"))
  } else {
    print(paste0(i, " directory already exists."))
  }
}

# Load libraries, functions and objects
library(Seurat)
library(ggplot2)
library(patchwork)
library(scales)
source("scripts/SpatialFeaturePlotScaled.R")
load("results/objects/obj_annotated.Rdata")

# subset Control heart, re-run SCT to normalize, scale, center data 
Idents(obj) <- "genotype"
obj_control <- subset(obj, idents = "Control")
obj_control <- SCTransform(obj_control, assay = "Spatial")

# find svf in 24 IR control heart
obj_control <- FindSpatiallyVariableFeatures(obj_control,
  assay = "SCT",
  selection.method = "markvariogram",
  features = VariableFeatures(obj_control),
  image = "Control",
  verbose = T,
  nfeatures = 20
)
top_20_svf <- head(
  SpatiallyVariableFeatures(
    obj_control,
    selection.method = "markvariogram"
  ),
  20
)
write.csv(top_20_svf,
  file = "results/spatially-variable-features/top_20_svf.csv",
  row.names = F
)

# SpatialFeaturePlots, plotted with original integrated object
for (i in top_20_svf) {
  pdf(
    file = paste0(
      "results/spatially-variable-features/SpatialFeaturePlot_",
      i,
      ".pdf"
    ),
    height = 6,
    width = 12.75,
    useDingbats = F
  )
  SpatialFeaturePlotScaled(obj,
    group = "genotype",
    group.1 = "Control",
    group.2 = "KO",
    feature_of_interest = i,
    from.meta.data = FALSE,
    group.1.title = "Control",
    group.2.title = "KO",
    legend.title = i
  )
  dev.off()
}
