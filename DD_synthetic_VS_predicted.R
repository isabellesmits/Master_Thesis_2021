methods=c("mean", "sum")
percentages=c(1,5,10)
replicates=seq(1,10,1)
counter = 0

#make empty dataframe with four variables
#sample and sum: sample is sample name ; 
#sum is the amount of matches between synthetic and predicted doubelts
df <- data.frame(group=character(), sample=character(), sum=integer(), ratio=numeric(), stringsAsFactors=FALSE)


for (method in methods) {
  for (percentage in percentages){
    for (replicate in replicates){
      #set working directory
      setwd("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5")
      
      #read-in output DD on dataset containing synthetic doublets
      output_DD <- read.table(file = paste0("./synthetic_",
                                            method,
                                            "/",
                                            percentage,
                                            "percent/",
                                            percentage,
                                            "_",
                                            replicate,
                                            "/DoubletDecon/Final_doublets_groups_original.txt"),
                              skip = 1,
                              sep = "\t",
                              header = F)
      
      #read-in barcodes of synthetic doublets
      barcodes_synthetic_doublets <- read.table(file = paste0("./synthetic_",
                                                              method,
                                                              "/",
                                                              percentage,
                                                              "percent/",
                                                              percentage,
                                                              "_",
                                                              replicate,
                                                              "/matrix_unzipped/barcodes_doublets.tsv"),
                                                sep = "\t",
                                                header = F)
      
      #find matches in synthetic barcodes and barcodes of doublets called by DD 
      #first add a column to output_DD that contains the barcodes but with '-' instead of '.'
      output_DD[,4] <- gsub("\\.", "-", output_DD[,1])
      
      #find matches and save them in dataframe df
      counter = counter + 1
      
      ##column 1 "group"
      df[counter, "group"] <- as.character(paste0(method,
                                                  "_",
                                                  percentage))
      
      ##column 2 "sample"
      df[counter, "sample"] <- as.character(paste0(method,
                                            "_",
                                            percentage,
                                            "_",
                                            replicate))
      ##column 3 "sum"
      df[counter, "sum"] <- sum(barcodes_synthetic_doublets[,1] %in% output_DD[,4])
      
      ##column 4 "ratio"
      amount_synthetic_doublets <- as.numeric(dim(barcodes_synthetic_doublets)[1])
      df[counter, "ratio"] <- sum(barcodes_synthetic_doublets[,1] %in% output_DD[,4])/amount_synthetic_doublets
      
      #save dataframe as csv file
      write.csv(df, "DD_synthetic_VS_predicted.csv")
      
      
    }
  }
}


