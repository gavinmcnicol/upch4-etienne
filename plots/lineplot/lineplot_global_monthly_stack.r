# Get plot theme
source("./plots/theme/line_plot_theme.r")


# /----------------------------------------------------------#
#/    Get sum data

# read data
sum_df <- read.csv("../output/results/upscaled_sum.csv", stringsAsFactors = FALSE)

# Filter & prep
# sum_df_temp <- sum_df %>% 
# 		  # filter(valtype == "med") %>%

# 		  mutate(time = as.Date(time, "%Y-%m-%d")),
# 		  # convert to separate monthly & yearly values
# 		  mutate(month= month(time, "%m")) %>%
# 		  mutate(year = as.Date(time, "%Y")) %>%
# 		  # spread min,med,max to diff column
# 		  spread(valtype, sum_flux) %>%
# 		  # subset to the date of the GIF loop, to label last point. 
# 		  filter(time <= parseddates[t])



# Filter & prep
sum_df_temp <- sum_df %>% 
  
  mutate(time = as.Date(time, "%Y-%m-%d"),
         month= month(time),
         year = year(time)) %>%
  
  spread(valtype, sum_flux) %>%

  group_by(time) %>%
  summarise_all(max, na.rm=TRUE) %>%
  ungroup() %>%
  # subset to the date of the GIF loop, to label last point. 
  filter(time <= parseddates[t])


# /----------------------------------------------------------#
#/   Make lineplot

l<- ggplot(data=sum_df_temp) +

  geom_ribbon(aes(x=month, ymin=min, ymax=max, fill=year), alpha=0.2) +
  
  geom_line( aes(x=month, y=med, color=year), size=0.3) +
  geom_point(aes(x=month, y=med, color=year), shape=21, fill='white', size=0.01, stroke=0.05) +
  
  
  # Last point
  geom_point(aes(x=max(sum_df_temp$time), 
                 y=c(sum_df_temp[which.max(sum_df_temp$time), 'med'])$med), 
             shape=21, color='red', fill='black', size=0.6) +
  
  xlab("")  + ylab("Wetland CH4 emissions (Tg)") +
  
  # axes limit
  scale_x_continuous(breaks = seq(1,12), 
                     limits = c(1, 12),
                     labels = c("J","F","M","A","M","J","J","A","S","O","N","D"),
                     expand = c(0,0)) +

  scale_y_continuous(limits=c(0, 25), breaks=seq(0,25,5)) + 
  
  #guides(fill=FALSE, colour=FALSE) +

  line_plot_theme +
  theme( legend.position = "right",# c(0.9, 0.6), # "none",
         plot.margin = unit( c(-2, 0, -2, 0) , "mm"))
