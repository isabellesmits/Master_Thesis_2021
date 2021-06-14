methods=c("mean", "sum")
percentages=c(0,1,5,10)
replicates=seq(1,10,1)
counter = 0

#make empty dataframe with two variables
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
      
      #read-in output DD on dataset containing no synthetic doublets
      output_DD_original <- read.table(file = "./original/DoubletDecon/run_1/Final_doublets_groups_original.txt", skip = 1, sep = "\t", header = F)
      
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
      df[counter, "sum"] <- sum(output_DD[,1] %in% output_DD_original[,1])
      
      ##column 4 "ratio"
      rows_original <- as.numeric(dim(output_DD_original)[1])
      df[counter, "ratio"] <- sum(output_DD[,1] %in% output_DD_original[,1])/rows_original
      
      
      #save dataframe as csv file
      write.csv(df, "DD_original_VS_predicted.csv")
      
    }
  }
}

