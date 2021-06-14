args = commandArgs(TRUE)
method = args[1]
percentage = args[2]
replicate = args[3]

#script for automating the counts method 

##########################################################
#count method

#set working directory
setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5/synthetic_",
             method,
             "/",
             percentage,
             "percent/",
             percentage,
             "_",
             replicate,
             "/"))

library(dplyr)
library(Seurat)
library(patchwork)

#load the dataset
object.data <- Read10X(data.dir = "./matrix")

#initialize the Seurat object with the raw data
object <- CreateSeuratObject(counts = object.data, project = "leish", min.cells = 3, min.features = 200)

#make a dataframe containing the colnames and nFeature_RNA values of the Seurat object
##make a variable called barcodes containing the colnames of the Seurat object
barcodes <- colnames(object)

##make a variable called nFeature_RNA containing the nFeature_RNA values of the Seurat object
nFeature_RNA <- object@meta.data$nFeature_RNA

##make a dataframe containing these variables
test.data <- data.frame(barcodes, nFeature_RNA)

#order the rows in the dataframe by nFeature_RNA value
test.data <- test.data[order(nFeature_RNA),]

#extract the dimension of the dataframe since you want only a
#percentage of cells to be extracted from the dataframe
dimension <- as.numeric(dim(test.data)[1])

##take a subset of this dataframe. You want 0 of cells with highest count. 
percentage_extract <- 0 + as.numeric(percentage)
subset <- (percentage_extract*dimension)/100

##round this number
subset <- round(subset)

#for the counts method, cells with the highest count are considered to be doublets
#in this example we consider the 0percent + percentage cells with the highest count as doublets
#extract these cells and store them in a variable called predicted_doublets
predicted_doublets <- tail(test.data, n = subset)

if(subset == 0){
  write.table(predicted_doublets,  "./counts_method/predicted_doublets.csv", sep = ",", col.names = F)
}else{
  write.csv(predicted_doublets, "./counts_method/predicted_doublets.csv")
}

