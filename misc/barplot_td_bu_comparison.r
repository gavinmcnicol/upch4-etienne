ct_interannual_df <- read.csv("../output/results/carbontracker_interannual.csv")

ct_interannual_df$source <- "top down"

# ct_interannual_df <- ct_interannual_df %>%
#   group_by(zone, biomes_regrouped) %>%
#   summarize(min_percent_oftotflux = min(percent_oftotflux),
#             mean_percent_oftotflux = mean(percent_oftotflux),
#             max_percent_oftotflux = max(percent_oftotflux))



###
bu_interannual_df <- read.csv("../output/results/bu_interannual_df.csv")

bu_interannual_df$source <- "bottom up"

# bu_interannual_df <- bu_interannual_df %>%
#   group_by(zone, biomes_regrouped) %>%
#   summarize(min_percent_oftotflux = min(percent_oftotflux),
#             mean_percent_oftotflux = mean(percent_oftotflux),
#             max_percent_oftotflux = max(percent_oftotflux))


#==============================================================================#
# Join the data togerther                           ============================
#==============================================================================#

zone_df <- bind_rows(ct_interannual_df, bu_interannual_df)

#zone_df <- inner_join(bu_interannual_df, ct_interannual_df, by="zone")

zone_df <- zone_df %>%
  group_by(zone, biomes_regrouped, source) %>%
  summarize(min_annualflux = min(sum),
            mean_annualflux = mean(sum),
            max_annualflux = max(sum))

  # summarize(min_percent_oftotflux = min(percent_oftotflux),
  #           mean_percent_oftotflux = mean(percent_oftotflux),
  #           max_percent_oftotflux = max(percent_oftotflux))


# names(zone_df) <- c("biome_nb", "sum_ch4flux", "biome_label", "percent_totflux", 
#                     "nb_towers", "percent_tottowers") 


write.csv(zone_df, "../output/results/biome_tower_ctracker_representativeness.csv")





#==============================================================================#
###     Bar plot                              ----------------------------------
#==============================================================================#


# prep data into long form
# zone_df_forplot <-  zone_df %>%
#   
#   gather(type, value, c(mean_percent_oftotflux, percent_towers)) %>%
#   
#   mutate(min_percent_oftotflux = ifelse(type=="mean_percent_oftotflux",min_percent_oftotflux,NA),
#          max_percent_oftotflux = ifelse(type=="mean_percent_oftotflux",max_percent_oftotflux,NA)) %>%
#   
#   mutate(type = factor(type),
#          biomes_regrouped = factor(biomes_regrouped))
# 

#zone_df_forplot$type %in% c("min_percent_oftotflux","max_percent_oftotflux")


zone_df$biomes_regrouped <- factor(zone_df$biomes_regrouped, 
                                           levels = c("Tropical/Subtropical", 
                                                      "Boreal/Taiga", 
                                                      "Temperate", 
                                                      "Tundra")) 

#zone_df_forplot$biome_label[order(zone_df_forplot$value)])



ggplot(zone_df,
       aes(x=biomes_regrouped, 
           y=mean_annualflux, 
           ymin=min_annualflux, 
           ymax=max_annualflux, 
           group=source, 
           fill=source))+
  
  # bars
  geom_bar(stat="identity", position = 'dodge') +
  
  # errorbars
  geom_errorbar(stat="identity", 
                position = position_dodge2(0, padding = 1),
                width=0.88,
                size=0.5) +
  
  scale_y_continuous("Total emission (Tg CH4 year-1)", 
                     sec.axis = sec_axis(~., name = ""),
                     expand=c(0,0)) +
  
  scale_fill_brewer(type="qual", palette = 3) +
  
  xlab("") + 
  theme_classic() + 
  theme(legend.position = c(0.8, 0.8),
        legend.title = element_blank())



# save figure to file
ggsave('../output/figures/barplot_td_bu_interannual_comp.png',  
       width=137, height=90, dpi=300, units="mm", type = "cairo-png")
dev.off()

