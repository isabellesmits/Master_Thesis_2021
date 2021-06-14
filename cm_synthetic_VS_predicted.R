methods=c("mean", "sum")
percentages=c(1,5,10)
replicates=c(1,2,3,4,5,6,7,8,9,10)
count=0

#####################################################
#synthetic VS predicted

#compare the predicted_doublets with the synthetic doublets
##make an empty dataframe with four columns:
##group is group name of the dataset
##sample is sample name of the dataset
##sum is the amount of matches between the predicted and synthetic doublets
##ratio is the amount of matches divided by the total amount of synthetic doublets
df <- data.frame(group=character(), sample=character(), sum=integer(), ratio=numeric(), stringsAsFactors = F)

for (method in methods) {
  for (percentage in percentages) {
    for (replicate in replicates) {
      
      ##set working directory
      setwd("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5")
      
      ##read-in output of synthetic dataset
      output_cm <- read.table(file = paste0("./synthetic_",
                                            method,
                                            "/",
                                            percentage,
                                            "percent/",
                                            percentage,
                                            "_",
                                            replicate,
                                            "/counts_method/predicted_doublets.csv"),
                              sep = ",",
                              skip = 1)
      
      ##read-in barcodes of synthetic doublets
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
      
      ##fill in the columns of the dataframe
      count = count + 1
      
      ###column 1 'group'
      df[count,"group"] <- as.character(paste0(method,
                                               "_",
                                               percentage))
      
      ###column 2 'sample'
      df[count, "sample"] <- as.character(paste0(method,
                                                 "_",
                                                 percentage,
                                                 "_",
                                                 replicate))
      
      ###column 3 'sum'
      df[count, "sum"] <- sum(output_cm[,2] %in% barcodes_synthetic_doublets[,1])
      
      ###column 4 'ratio'
      ####determine the dimension of barcodes_synthetic_doublets, we need the number of rows
      rows_barcodes_synthetic_doublets  <- as.numeric(dim(barcodes_synthetic_doublets)[1])
      
      ####divide the number in 'sum' by rows_original to get the ratio
      df[count,"ratio"] <- sum(output_cm[,2] %in% barcodes_synthetic_doublets[,1])/rows_barcodes_synthetic_doublets
      
      ##save results as csv file
      write.csv(df, "cm_synthetic_VS_predicted.csv")
      
      
    }
  }
}
