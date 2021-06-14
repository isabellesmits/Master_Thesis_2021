datasets = c(1:10)
count = 0

#make dataframe to store results
df <- data.frame(dataset=integer(), total_1=integer(), total_2=integer(), overlap=integer(), stringsAsFactors = F)

for (dataset in datasets) {
  #set working directory
  setwd(paste0("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_",
               dataset,
               "/original/counts_method"))
  if(file.size("./run_1/predicted_doublets.csv") > 0){
    output_original_1 <- read.table(file = "./run_1/predicted_doublets.csv", sep = ",", skip = 1, header = F)
    if(file.size("./run_2/predicted_doublets.csv") > 0){
      output_original_2 <- read.table(file = "./run_2/predicted_doublets.csv", sep = ",", skip = 1, header = F)
      count = count + 1
      df[count,1] <- dataset
      df[count,2] <- dim(output_original_1)[1]
      df[count,3] <- dim(output_original_2)[1]
      df[count,4] <- sum(output_original_1[,2] %in% output_original_2[,2])
    }else{
      count = count + 1
      df[count,1] <- dataset
      df[count,2] <- dim(output_original_1)[1]
      df[count,3] <- 0
      df[count,4] <- 0
    }
  } else {
    count = count + 1
    df[count,1] <- dataset
    df[count,2] <- 0
    df[count,3] <- 0
    df[count,4] <- 0
  }
 
}

#save dataframe as csv file
write.csv(df, "cm_original_2.csv")