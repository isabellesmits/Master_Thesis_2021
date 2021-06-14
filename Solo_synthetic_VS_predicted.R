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
      
      #set counter
      counter = counter + 1
      
      #read-in output if a file was created, otherwise set columns to 'NA'
      if(length(list.files(paste0("./synthetic_",
                                  method,
                                  "/",
                                  percentage,
                                  "percent/",
                                  percentage,
                                  "_",
                                  replicate,
                                  "/Solo"))) == 0){
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
        df[counter, "sum"] <- NA
        
        ##column 4 "ratio"
        df[counter, "ratio"] <- NA
      } else {
        #read-in output
        output <- read.table(file = paste0("./synthetic_",
                                           method,
                                           "/",
                                           percentage,
                                           "percent/",
                                           percentage,
                                           "_",
                                           replicate,
                                           "/Solo/is_doublet.csv"),
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
        
        #read-in barcodes of synthetic dataset matrix
        barcodes <- read.table(file = paste0("./synthetic_",
                                             method,
                                             "/",
                                             percentage,
                                             "percent/",
                                             percentage,
                                             "_",
                                             replicate,
                                             "/matrix_unzipped/barcodes.tsv"),
                               sep = "\t",
                               header = F)
        
        #add barcodes to output
        output <- data.frame(barcodes, output)
        
        #remove rows of which the value is 0 in outputl
        output_filtered = as.data.frame(output[-c(which(output[,2] == 0)),])
        
        #find matches and save them in dataframe df or set sum to zero if no doublets are called
        if(dim(output_filtered)[1] == 0){
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
          df[counter, "sum"] <- dim(output_filtered)[1]
          
          ##column 4 "ratio"
          df[counter, "ratio"] <- dim(output_filtered)[1]
        } else {
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
          df[counter, "sum"] <- sum(output_filtered[,1] %in% barcodes_synthetic_doublets[,1])
          
          ##column 4 "ratio"
          amount_synthetic_doublets <- as.numeric(dim(barcodes_synthetic_doublets)[1])
          df[counter, "ratio"] <- sum(output_filtered[,1] %in% barcodes_synthetic_doublets[,1])/amount_synthetic_doublets
        }
        
      }
      
     
      
      #save dataframe as csv file
      write.csv(df, "Solo_synthetic_VS_predicted.csv")
      
    }
  }
}
