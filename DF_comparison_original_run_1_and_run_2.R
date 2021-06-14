datasets = c(1:10)
count = 0

#make dataframe to store results
df <- data.frame(dataset=integer(), total_1=integer(), total_2=integer(), overlap=integer(), stringsAsFactors = F)

for (dataset in datasets) {
  #set working directory
  setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
               dataset,
               "/original/DoubletFinder"))
  
  #read-in output DF on original dataset run 1
  output_original_1 <- read.table(file = "./run_1/doublets_DF.csv", sep = ",", skip = 1, header = F)
  
  #read-in output DF on original dataset run 2
  output_original_2 <- read.table(file = "./run_2/doublets_DF.csv", sep = ",", skip = 1, header = F)
  
  #find matches in barcodes of doublets called with DF in the original dataset run 1 VS run 2
  count = count + 1
  df[count,1] <- dataset
  df[count,2] <- dim(output_original_1)[1]
  df[count,3] <- dim(output_original_2)[1]
  df[count,4] <- sum(output_original_1[,2] %in% output_original_2[,2])
}

#save dataframe as csv file
write.csv(df, "DF_original.csv")