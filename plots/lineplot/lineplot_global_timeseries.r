# Get plot theme
source("./plots/theme/line_plot_theme.r")

#options(date.origin = "1980-01-01")
# /----------------------------------------------------------#
#/    Get sum data

sum_df <- read.csv("../output/results/upscaled_sum.csv", stringsAsFactors = FALSE)

# Get date list
parseddates <- readRDS('../output/results/parsed_dates.rds')


# Filter & prep
sum_df_temp <- sum_df %>% 
  spread(valtype, sum_flux) %>%
  group_by(time) %>%
  summarise_all(max, na.rm=TRUE) %>%
  ungroup()

sum_df_temp <- sum_df_temp %>%
  
      mutate(time = ymd(time)) %>%
  
      mutate(time = time + years(20)) %>%

      filter(time <= parseddatessubset[t])

# /----------------------------------------------------------#
#/   Make lineplot of stacked month

l <- ggplot(data=sum_df_temp) +

	geom_line(   aes(x=time, y=med), color='red', size=0.18) + 
	geom_ribbon( aes(x=time, ymin=min, ymax=max), fill='red', alpha=0.2) +

	# plot the last value as point
	geom_point(aes(	x= unlist(max(sum_df_temp$time)), 
					y= c(sum_df_temp[which.max(sum_df_temp$time), 'med'])$med ), 
					shape=21, color='red', fill='black', size=0.6) +

	xlab("")  + ylab("Wetland CH4 emissions (Tg)") +

	# axes limit
	scale_x_date(date_breaks = "2 year", date_labels = "%Y", 
				limits=c(ymd("2000-01-01"), 
						 ymd("2017-12-31")),
				expand=c(0,0)) +  

	scale_y_continuous(limits=c(5, 25), breaks=c(5, 10, 15, 20, 25)) + 

	line_plot_theme +
	theme(	legend.position = "right",
			plot.margin = unit( c(-2, 2, -2, 0) , "mm"))
