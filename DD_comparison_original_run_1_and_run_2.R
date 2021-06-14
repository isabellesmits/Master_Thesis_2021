datasets = c(1:10)
count = 0

#make dataframe to store results
df <- data.frame(dataset=integer(), total_1=integer(), total_2=integer(), overlap=integer(), stringsAsFactors = F)

for (dataset in datasets) {
  #setwd
  setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
               dataset,
               "/original/DoubletDecon"))
  
  #read-in output file containin doublets called in the first run
  doublets_run_1 <- read.table(file = "./run_1/Final_doublets_groups_original.txt", skip = 1, sep = "\t", header = F)
  
  #read-in output file containing doublets called in the second run
  doublets_run_2 <- read.table(file = "./run_2/Final_doublets_groups_original.txt", skip = 1, sep = "\t", header = F)
  
  #find matches in barcodes of doublets called in these two tests and save them in a dataframe
  count = count + 1
  df[count,1] <- dataset
  df[count,2] <- dim(doublets_run_1)[1]
  df[count,3] <- dim(doublets_run_2)[1]
  df[count,4] <- sum(doublets_run_1[,1] %in% doublets_run_2[,1])
  
  #save dataframe as csv file
  write.csv(df, "DD_original.csv")
  
}

