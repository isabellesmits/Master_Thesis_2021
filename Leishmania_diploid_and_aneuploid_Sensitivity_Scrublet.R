#set working directory
setwd("C:/users/smits/Documents/2e Ma BMW 2020-2021/Master_thesis/merging_boxplots/5_tools_together/")

#read-in csv file
df <- read.csv(file = "./synthetic_VS_predicted_all.csv", sep = ",")

#only plot results of the diploid and aneuploid Leishmania dataset
resulting_dataframe <- as.data.frame(df[c(which(df$tool == "Scrublet")),])
final_dataframe <- as.data.frame(resulting_dataframe[c(which(resulting_dataframe$dataset == "Leishmania_diploid" | resulting_dataframe$dataset == "Leishmania_aneuploid")),])

final_dataframe$group <- as.factor(final_dataframe$group)
final_dataframe$group <- factor(final_dataframe$group, levels = levels(final_dataframe$group)[c(1,3,2,4,6,5)])


library(ggplot2)

plot <- ggplot(final_dataframe, aes(x= group, y= ratio, color = dataset)) +
  geom_boxplot(aes(x = group, y=ratio)) +
  geom_jitter(position = position_jitterdodge(jitter.width = 0.1), size = 0.2) +
  theme_bw() +
  coord_cartesian(ylim = c(0.75, 1.00)) +
  ggtitle("Sensitivity Leishmania (diploid) and Leishmania (aneuploid) dataset")

plot

ggsave(filename = "Leishmania_diploid_and_aneuploid_Sensitivity_Scrublet.png", 
       plot, 
       device = "png")
