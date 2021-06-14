methods=c("mean", "sum")
percentages=c(1,5,10)
replicates=seq(1,10,1)
counter=0

#make empty dataframe with four variables
#sample and sum: sample is sample name ; 
#sum is the amount of matches between synthetic and predicted doubelts
df <- data.frame(group=character(), sample=character(), sum=integer(), specificity=numeric(), stringsAsFactors=FALSE)


for (method in methods) {
  for (percentage in percentages){
    for (replicate in replicates){
      #set working directory
      setwd("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5")
      
      #read-in output Scrublet on dataset containing synthetic doublets
      output_Scrublet <- read.table(file = paste0("./synthetic_",
                                            method,
                                            "/",
                                            percentage,
                                            "percent/",
                                            percentage,
                                            "_",
                                            replicate,
                                            "/Scrublet/predicted.csv"),
                              sep = ",",
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
      df[counter, "sum"] <- as.numeric(dim(output_Scrublet)[1]) - sum(barcodes_synthetic_doublets[,1] %in% output_Scrublet[,2])
      
      ##column 4 "specificity"
      if (percentage == 1){
        total = 4950
      } else if (percentage == 5){
        total = 4750
      } else if (percentage == 10){
        total = 4500
      } 
      
      false_negatives <- as.numeric(dim(barcodes_synthetic_doublets)[1]) - sum(barcodes_synthetic_doublets[,1] %in% output_Scrublet[,2])
      true_negatives <- total - as.numeric(dim(output_Scrublet)[1]) - false_negatives
      false_positives <- as.numeric(dim(output_Scrublet)[1]) - sum(barcodes_synthetic_doublets[,1] %in% output_Scrublet[,2])
      
      df[counter, "specificity"] <- true_negatives/(true_negatives + false_positives)
      
      #save dataframe as csv file
      write.csv(df, "Scrublet_specificity.csv")
      
      
    }
  }
}


