args = commandArgs(TRUE)
dataset = args[1]
replicate = args[2]

#Step 2: formatting input files for use with DoubletDecon
#2.1: run Seurat unsupervised clustering pipeline


setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_", dataset, "/original/"))


library(dplyr)
library(Seurat)
library(patchwork)

#load the dataset
#make sure that this folder (= 'matrix') contains zipped files
original.data <- Read10X(data.dir = paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_", dataset, "/original/matrix"))

#initialize the Seurat object with the raw (non-normalized) data
original <- CreateSeuratObject(counts = original.data, project = "leishmania", min.cells = 3, min.features = 200 )

#standard pre-proceessing workflow
#QC and selecting cells for further analysis
#for example filter cells that have unique feature counts over 2500 or less than 200
##original <- subset(original, subset = nFeature_RNA > 200 & nFeature_RNA < 2500)
##this line is skipped for this dataset since no cells have a value lower than 2500 for nFeature_RNA


#Normalizing the data
original <- NormalizeData(original, normalization.method = "LogNormalize", scale.factor = 10000)

#Identification of highly variable features (feature selection)
original <- FindVariableFeatures(original, selection.method = "vst", nfeatures = 2000)

#scaling the data
all.genes <- rownames(original)
original <- ScaleData(original, features = all.genes)

#perform linear dimensional reduction
original <- RunPCA(original, features = VariableFeatures(object = original))

#cluster the cells
##dims 10 because elbowplot shows 'elbow' around this value
original <- FindNeighbors(original, dims = 1:10)
original <- FindClusters(original, resolution = 0.5)

#2.2: Convert Seurat file into ICGS-like format
library(DoubletDecon)
newFiles_original = Improved_Seurat_Pre_Process(original, num_genes = 50, write_files = T) 

#check output of this function
newFiles_original$newExpressionFile
newFiles_original$newGroupsFile
newFiles_original$newFullExpressionFile

#step 5: Running DoubletDecon
Main_Doublet_Decon(rawDataFile = newFiles_original$newExpressionFile,
                   groupsFile = newFiles_original$newGroupsFile,
                   "original",
                   location = paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
                                     dataset,
                                     "/original/DoubletDecon/run_",
                                     replicate,
                                     "/"),
                   fullDataFile = newFiles_original$newFullExpressionFile,
                   removeCC = F,
                   species = "ldo",
                   rhop=1,
                   write=T,
                   PMF=T,
                   useFull = F,
                   heatmap = T,
                   centroids = T,
                   num_doubs = 100,
                   only50=T,
                   min_uniq=4,
                   nCores=-1)








