args = commandArgs(TRUE)
dataset = args[1]
replicate = args[2]

#install DoubletFinder
##remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')

#load DoubletFinder
library(DoubletFinder)

setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
             dataset,
             "/original/"))


library(dplyr)
library(Seurat)
library(patchwork)

output.data <- Read10X(data.dir = "./matrix")


output <- CreateSeuratObject(output.data)
output <- NormalizeData(output)
output <- FindVariableFeatures(output, selection.method = "vst", nfeatures = 2000)
output <- ScaleData(output)
output <- RunPCA(output)
output <- RunUMAP(output, dims = 1:10)

#pK identification (no ground-truth)
sweep.res.list_output <- paramSweep_v3(output, PCs = 1:10, sct = FALSE)
sweep.stats_output <- summarizeSweep(sweep.res.list_output, GT = FALSE)
bcvmn_output <- find.pK(sweep.stats_output)

#homotypic doublet proportion estimate
annotations <- output@meta.data$ClusteringResults
homotypic.prop <- modelHomotypic(annotations)
nExp.poi <- round(0.0634*nrow(output@meta.data))
nExp.poi.adj <- round(nExp.poi*(1-homotypic.prop))

#run DoubletFinder with varying classification stringencies
output <- doubletFinder_v3(output, PCs = 1:10, pN = 0.25, pK = 0.09, nExp = nExp.poi, reuse.pANN = FALSE, sct = FALSE)

#how does the output of DoubletFinder look like?
##output[[]]

#try to retrieve only the column containing doublet info
##output@meta.data[,5]


#save column containing doublet info in dataframe
output_DoubletFinder <- data.frame(output@meta.data[,5])

#add column barcodes to this dataframe
#this column contains the barcodes of the cells
output_DoubletFinder$barcodes <- rownames(output@meta.data)

#filter only barcodes whereoff DF.classifications is 'doublet'
#there are 5000 observations in dataframe output_DoubletFinder, so 5000 rows
#make object with length 5000
rows <- c(1:5000)
count <- 0

#create empty dataframe doublets 
##barcodes of doublets will be saved in this dataframe
doublets <- data.frame(barcodes=character())

for (row in rows) {
  if (output_DoubletFinder[row, 1] == "Doublet"){
    count <- count + 1
    doublets[count, "barcodes"] <- output_DoubletFinder[row, "barcodes"]
    setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
                 dataset,
                 "/original/DoubletFinder/run_",
                 replicate,
                 "/"))
    write.csv(doublets, "doublets_DF.csv")
  }
}



##output_backup <- output_DoubletFinder


