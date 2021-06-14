#set working directory
setwd("C:/users/smits/Documents/2e Ma BMW 2020-2021/Master_thesis/merging_boxplots/5_tools_together/")

#read-in csv file
df <- read.csv(file = "./synthetic_VS_predicted_all.csv", sep = ",")

#only plot results of the aneuploid Leishmania dataset
final_dataframe <- as.data.frame(df[c(which(df$dataset == "Leishmania_aneuploid")),])

final_dataframe$group <- as.factor(final_dataframe$group)
final_dataframe$group <- factor(final_dataframe$group, levels = levels(final_dataframe$group)[c(1,3,2,4,6,5)])


library(ggplot2)

plot <- ggplot(final_dataframe, aes(x= group, y= ratio, color = tool)) +
  geom_boxplot(aes(x = group, y=ratio)) +
  geom_jitter(position = position_jitterdodge(jitter.width = 0.1), size = 0.2) +
  theme_bw() +
  coord_cartesian(ylim = c(0.00, 1.00)) +
  ggtitle("Sensitivity Leishmania (aneuploid) dataset")

plot

ggsave(filename = "Leishmania_aneuploid_Sensitivity.png", 
       plot, 
       device = "png")
