library(ggplot2, help, pos = 2, lib.loc = NULL)
library(dplyr)


d = read.csv("OutputData.csv")
ggplot(d %>% filter(age==max(age)))+
    geom_point(aes(x=position_x,y=position_y,col=being_id))
