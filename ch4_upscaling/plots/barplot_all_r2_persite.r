library(here)
library(dplyr)
library(tidyr)
library(ggplot2)


r2 <- read.csv("../data/r2/site_r2_all.csv", stringsAsFactors = F) %>%
      # remove columns
      select(-SiteID2, -SiteID3, -SiteID4) %>%
      filter(SiteID != "") %>%
      filter(!is.na(GM190430_bysite_R2) | !is.na(GM190430_bysite_R2)) %>%
      arrange(SK_gapfillingR2)

order_siteid <- as.factor(unique(r2$SiteID)) 

r2l <-r2 %>%
      gather(key="type", value="value", SK_gapfillingR2:MG_wtd.variability.score) %>%
      filter(SiteID != "") %>%
      filter(! type %in% c("MG_variability.score", "MG_wtd.variability.score"))
      

r2l$SiteID <- factor(r2l$SiteID, levels = factor(order_siteid))
r2l <- r2l %>%
       mutate(type=ifelse(type=="SK_gapfillingR2",        "Gapfilling R^2", type),
              type=ifelse(type=="GM190430_bysite_R2",     "Pred. R^2 w/ tower met", type),
              type=ifelse(type=="GM190530_MET_bysite_R2", "Pred. R^2 w/ gridded met", type))

     
# /----------------------------------------------------------------------------#
#/  Make bar graph

source("./plots/theme/line_plot_theme_bigger_text.r")

library(gridExtra)

# /----------------------------------------------------------------------------#
#/  Make bar graph

r2dist <- ggplot(r2l) + 
  geom_histogram(aes(x=value, fill=type), color="white", stat = "bin", binwidth = 0.025) +
  facet_wrap(.~ type, ncol=1) +
  
  scale_x_continuous(limits= c(-0.1, 1.0)) +
  scale_y_continuous(expand= c(0, 0)) +
  #coord_flip() +
  xlab("R^2") + ylab("Number of towers") +
  line_plot_theme +
  theme(legend.position = "none")



# /----------------------------------------------------------------------------#
#/  Make bar graph
r2pertower<- 
  ggplot(r2l) + 
  geom_bar(aes(x=SiteID, y=value, fill=type), 
           width=0.7, stat="identity", position="dodge") +
  
  scale_y_continuous(limits= c(-0.1, 1.0)) +
  coord_flip() +
  xlab("") + ylab("R^2") +
  line_plot_theme +
  theme(legend.position = c(0.5, 0.05))
  

# /----------------------------------------------------------------------------#
#/
library(cowplot)
g <- plot_grid(r2dist, r2pertower, align = "v", nrow = 2, rel_heights = c(0.3, 0.7))

# save under filename
ggsave("../output/figures/barplot_r2_comparison_persite.png", g,
       width=90, height=220, dpi=800, units="mm", type = "cairo-png")
dev.off()



# r2dist     <- ggplotGrob(r2dist)
# r2pertower <- ggplotGrob(r2pertower)
# grid::grid.newpage()
# grid::grid.draw(rbind(r2dist, r2pertower))
#g <- grid.arrange(r2dist, pertower, ncol=1)

# library(grid)
# grid.newpage()
# 
# grid.draw(
#   rbind(
#     ggplotGrob(r2dist),
#     ggplotGrob(r2pertower), 
#     size = "first"))