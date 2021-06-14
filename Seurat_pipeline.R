#try out Seurat pipeline on diploid Leishmania dataset
#set working directory
setwd("C:/Users/smits/Documents/2e Ma BMW 2020-2021/Master_thesis/Leishmania/artificial_diploid/Seurat_pipeline/dataset_10")

library(dplyr)
library(Seurat)
library(patchwork)

#load the dataset
leish.data <- Read10X(data.dir = "../../pilot_synthetic_clusters_default/dataset_10/")

#initialize the Seurat object with the raw data
leish <- CreateSeuratObject(counts = leish.data, project = "leish", min.cells = 3, min.features = 200)
leish

#standard pre-processing workflow
##QC and selectin cells for further analysis
leish[["percent.mt"]] <- PercentageFeatureSet(leish, pattern = "^MT-")

##visualize QC metrics as a violin plot
VlnPlot(leish, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)

##all cells exhibit the same value for percent.mt
##therefore this parameter is excluded for filtering in this analysis

##FeatureScatter
plot1 <- FeatureScatter(leish, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")
plot1

##subset
leish <- subset(leish, subset = nFeature_RNA > 200 & nFeature_RNA < 2500)

##error: cannot find cells provided
##due to the fact that none of the cells exhibit a value of <2500 for nFeature_RNA
##ignore this step

#normilizing the data
leish <- NormalizeData(leish, normalization.method = "LogNormalize", scale.factor = 10000)

#identification of highly variable features
leish <- FindVariableFeatures(leish, selection.method = "vst", nfeatures = 2000)

##identify the 10 most highly variable genes
top10 <- head(VariableFeatures(leish), 10)


##plot variable features with and without labels
plot1 <- VariableFeaturePlot(leish)
plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)
plot1 + plot2

#scaling the data
all.genes <- rownames(leish)
leish <- ScaleData(leish, features = all.genes)

#perform linear dimensional reduction
leish <- RunPCA(leish, features = VariableFeatures(object = leish))

##examine and visualize PCA results in a few different ways
print(leish[["pca"]], dims = 1:5, nfeatures = 5)

VizDimLoadings(leish, dims = 1:2, reduction = "pca")

DimPlot(leish, reduction = "pca")

DimHeatmap(leish, dims = 1, cells = 500, balanced = TRUE)

DimHeatmap(leish, dims = 1:15, cells = 500, balanced = TRUE)

#determine the dimensionality of the dataset
leish <- JackStraw(leish, num.replicate = 100)
leish <- ScoreJackStraw(leish, dims = 1:20)

JackStrawPlot(leish, dims = 1:15)

ElbowPlot(leish)

#cluster the cells
##set dims to 10 since elbowplot shows elbow around 10
leish <- FindNeighbors(leish, dims = 1:10)
leish <- FindClusters(leish, resolution = 0.5)

##look at cluster IDs of the first 5 cells
head(Idents(leish), 5)

#run non-linear dimensional reduction (UMAP/tSNE)
leish <- RunUMAP(leish, dims = 1:10)

DimPlot(leish, reduction = "umap")

saveRDS(leish, file = "leish_umap_10.rds")

