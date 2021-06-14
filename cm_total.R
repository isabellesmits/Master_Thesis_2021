methods=c("mean", "sum")
percentages=c(0,1,5,10)
replicates=c(1,2,3,4,5,6,7,8,9,10)
count=0


###################################################
#total predicted doublets

#calculate the total percentage of predicted doublets in the synthetic datasets
##make an empty dataframe with four columns:
##group is group name of the dataset
##sample is sample name of the dataset
##sum is the amount of matches between the predicted and synthetic doublets
##ratio is the amount of matches divided by the total amount of synthetic doublets
df <- data.frame(group=character(), sample=character(), sum=integer(), ratio=numeric(), stringsAsFactors = F)

for (method in methods) {
  for (percentage in percentages){
    for (replicate in replicates){
      
      #set working directory
      setwd("/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5")
      
      if(file.size(paste0("./synthetic_",
                          method,
                          "/",
                          percentage,
                          "percent/",
                          percentage,
                          "_",
                          replicate,
                          "/counts_method/predicted_doublets.csv")) > 0){
        #read-in output cm on dataset containing synthetic doublets
        output_cm <- read.table(file = paste0("./synthetic_",
                                              method,
                                              "/",
                                              percentage,
                                              "percent/",
                                              percentage,
                                              "_",
                                              replicate,
                                              "/counts_method/predicted_doublets.csv"),
                                skip = 1,
                                sep = ",")
        
        ##fill in the columns of the dataframe
        count = count + 1
        
        ###column 1 'group'
        df[count, "group"] <- as.character(paste0(method,
                                                  "_",
                                                  percentage))
        
        ###column 2 'sample'
        df[count, "sample"] <- as.character(paste0(method,
                                                   "_",
                                                   percentage,
                                                   "_",
                                                   replicate))
        
        ###column 3 'sum'
        df[count, "sum"] <- as.numeric(dim(output_cm)[1])
        
        ###column 4 'ratio'
        ####divide the number in 'sum' by total of cells in the dataset to get the ratio
        if (percentage == 0){
          total = 5000
        } else if (percentage == 1){
          total = 4950
        } else if (percentage == 5){
          total = 4750
        } else if (percentage == 10){
          total = 4500
        }
        
        df[count,"ratio"] <- as.numeric(dim(output_cm)[1])/total
      } else{
        count = count + 1
        df[count,"group"] <- as.character(paste0(method,
                                                 "_",
                                                 percentage))
        df[count, "sample"] <- as.character(paste0(method,
                                                   "_",
                                                   percentage,
                                                   "_",
                                                   replicate))
        df[count, "sum"] <- 0
        df[count, "ratio"] <- 0
      }
      
      ##save results as csv file
      write.csv(df, "cm_total.csv")
      
    }
  }
}

