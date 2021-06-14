#set working directory
setwd("C:/users/smits/Documents/2e Ma BMW 2020-2021/Master_thesis/merging_boxplots/5_tools_together/")

datasets=c("Leishmania_diploid", "Leishmania_aneuploid")
tools=c("DD", "DF", "Scrublet", "Solo", "cm")
parameters=c("specificity")


for (parameter in parameters) {
  counter = 0
  names_dataframe <- paste0("df_", c(1:10))
  for (tool in tools) {
    for (dataset in datasets) {
      
      if(file.exists(paste0("../../",
                            dataset,
                            "/",
                            tool,
                            "_",
                            parameter,
                            ".csv")) == TRUE){
        
        df <- read.csv(file = paste0("../../",
                                     dataset,
                                     "/",
                                     tool,
                                     "_",
                                     parameter,
                                     ".csv"),
                       sep = ",")
        
        
        
        df[,5] <- gsub(",", ".", df[,5])
        df$specificity <- as.numeric(df$specificity)
        df$group <- as.factor(df$group)
        df$group <- factor(df$group, levels = levels(df$group)[c(1,3,2,4,6,5)])
        
        df$tool <- as.character(tool)
        df$dataset <- as.character(dataset)
      } else{
        df[,1] <- NA
        df[,2] <- NA
        df[,3] <- NA
        df[,4] <- NA
        df[,5] <- NA
        df[,6] <- NA
        df[,7] <- NA
      }
      
      ##rename df
      counter = counter + 1
      assign(names_dataframe[counter], data.frame(df))
      
    }
  }
  binding_dataframe <- do.call("rbind", list(df_1, df_2, df_3, df_4, df_5, df_6, df_7, df_8, df_9, df_10))
  assign(paste0(parameter, "_all"), data.frame(binding_dataframe))
}

write.csv(specificity_all, "./specificity_all.csv")

