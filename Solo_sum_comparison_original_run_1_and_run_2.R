datasets = c(1,2,3,5,6,7,8,10)
count = 0

#make dataframe to store results
df <- data.frame(dataset=integer(), total_1=integer(), total_2=integer(), overlap=integer(), stringsAsFactors = F)

for (dataset in datasets) {
  #set working directory
  setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
               dataset,
               "/original/Solo_sum"))
  
  #read-in output_1
  output_1 <- read.table(file = "./run_1/is_doublet.csv",
                         sep = ",",
                         header = F)
  
  
  #read-in output_2
  output_2 <- read.table(file = "./run_2/is_doublet.csv",
                         sep = ",",
                         header = F)
  
  #read-in barcodes of original matrix
  barcodes <- read.table(file = "../matrix_unzipped/barcodes.tsv",
                         sep = "\t",
                         header = F)
  
  #add barcodes to output_1 and output_2
  output_1 <- data.frame(barcodes, output_1)
  output_2 <- data.frame(barcodes, output_2)
  
  #remove rows of which the value is 0 in output_1 and output_2
  output_1_filtered = as.data.frame(output_1[-c(which(output_1[,2] == 0)),])
  output_2_filtered = as.data.frame(output_2[-c(which(output_2[,2] == 0)),])
  
  #find matches between output_1 and output_2
  count = count + 1
  df[count,1] <- dataset
  df[count,2] <- dim(output_1_filtered)[1]
  df[count,3] <- dim(output_2_filtered)[1]
  df[count,4] <- sum(output_1_filtered[,1] %in% output_2_filtered[,1])
  
}

#save dataframe as csv file
write.csv(df, "Solo_sum_original.csv")