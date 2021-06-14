methods=c("mean", "sum")
percentages=c(0,1,5,10)
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
      
      #read-in output DoubletFinder on original dataset run 1
      output_original <- read.table(file = "./original/DoubletFinder/run_1/doublets_DF.csv", sep = ",", skip = 1, header = F)
      
      #read-in output DoubletFinder of synthetic dataset
      output_DF <- read.table(file = paste0("./synthetic_",
                                            method,
                                            "/",
                                            percentage,
                                            "percent/",
                                            percentage,
                                            "_",
                                            replicate,
                                            "/DoubletFinder/doublets_DF.csv"),
                              sep = ",",
                              skip = 1,
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
      df[counter, "sum"] <- sum(output_original[,2] %in% output_DF[,2])
      
      ##column 4 "ratio"
      rows_original <- as.numeric(dim(output_original)[1])
      df[counter, "ratio"] <- sum(output_original[,2] %in% output_DF[,2])/rows_original
      
      #save dataframe as csv file
      write.csv(df, "DF_original_VS_predicted.csv") 
    }
  }
}

