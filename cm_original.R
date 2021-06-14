args = commandArgs(TRUE)
dataset = args[1]
replicate = args[2]

#script for automating the counts method 


##########################################################
#count method

#set working directory
setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
             dataset,
             "/original/"))
      
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
      
      ##take a subset of this dataframe. You want 0% of cells with highest count. 
      ###because this percentage is the estimated doublet rate for 5000 cells according to 
      ###the 10X website
      percentage_extract <- 0
      subset <- (percentage_extract*dimension)/100
      
      ##round this number
      subset <- round(subset)
      
      #for the counts method, cells with the highest count are considered to be doublets
      #in this example we consider the 0percent cells with the highest count as doublets
      #extract these cells and store them in a variable called predicted_doublets
      predicted_doublets <- tail(test.data, n = subset)
      
      #save results as csv file
      write.csv(predicted_doublets, paste0("./counts_method/run_",
                                           replicate,
                                           "/predicted_doublets.csv"))
      