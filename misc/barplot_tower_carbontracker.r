ct_interannual_df <- read.csv("../output/results/carbontracker_interannual.csv")

ct_interannual_df <- ct_interannual_df %>%
  group_by(zone, biomes_regrouped) %>%
  summarize(min_percent_oftotflux = min(percent_oftotflux),
            mean_percent_oftotflux = mean(percent_oftotflux),
            max_percent_oftotflux = max(percent_oftotflux))


tower_count <- read.csv("../output/results/tower_count_perbiome.csv")
tower_count <- tower_count %>% select(-X)




#==============================================================================#
# Join the data togerther                           ============================
#==============================================================================#

zone_df <- inner_join(ct_interannual_df, tower_count, by="zone")

# names(zone_df) <- c("biome_nb", "sum_ch4flux", "biome_label", "percent_totflux", 
#                     "nb_towers", "percent_tottowers") 


write.csv(zone_df, "../output/results/biome_tower_ctracker_representativeness.csv")





#==============================================================================#
###     Bar plot                              ----------------------------------
#==============================================================================#
library(ggplot2)
library(tidyr)

# prep data into long form
zone_df_forplot <-  zone_df %>%
  select(-nbtowers) %>%
  #select(biome_label, percent_totflux, percent_tottowers) %>%
  gather(type, value, c(mean_percent_oftotflux, percent_towers)) %>%
 
  mutate(min_percent_oftotflux = ifelse(type=="mean_percent_oftotflux",min_percent_oftotflux,NA),
         max_percent_oftotflux = ifelse(type=="mean_percent_oftotflux",max_percent_oftotflux,NA)) %>%
  
  mutate(type = factor(type),
         biomes_regrouped = factor(biomes_regrouped))


#zone_df_forplot$type %in% c("min_percent_oftotflux","max_percent_oftotflux")


zone_df_forplot$biomes_regrouped <- factor(zone_df_forplot$biomes_regrouped, 
                                      levels = c("Tropical/Subtropical", 
                                                 "Boreal/Taiga", 
                                                 "Temperate", 
                                                 "Tundra")) 

#zone_df_forplot$biome_label[order(zone_df_forplot$value)])



ggplot(zone_df_forplot,
       aes(x=biomes_regrouped, 
           y=value, 
           ymin=min_percent_oftotflux, 
           ymax=max_percent_oftotflux, 
           group=type, 
           fill=type))+
  
  # bars
  geom_bar(stat="identity", position = 'dodge') +
  
  # errorbars
  geom_errorbar(stat="identity", 
                position = position_dodge2(0, padding = 1),
                width=0.88,
                size=0.5) +
  
  scale_y_continuous("Percentage flux", sec.axis = sec_axis(~., name = "Percentage towers"),
                     expand=c(0,0)) +
  
  xlab("") + 
  theme_classic() + 
  theme(legend.position = c(0.8, 0.8),
        legend.title = element_blank())




# save figure to file
ggsave('../output/figures/barplot_biome_tower_ctinterannual_rep.png',  
       width=137, height=90, dpi=300, units="mm", type = "cairo-png")
dev.off()

