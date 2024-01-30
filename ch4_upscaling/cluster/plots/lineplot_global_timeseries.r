# Get plot theme
source("./plots/theme/line_plot_theme.r")


# /----------------------------------------------------------#
#/    Get sum data

sum_df <- read.csv("../output/results/upscaled_sum.csv", stringsAsFactors = FALSE)

# Filter & prep
sum_df_temp <- sum_df %>% 
		  #filter(valtype == "med") %>%
		  mutate(time = as.Date(time, "%Y-%m-%d")) %>%
		  # subset to the date of the loop
		  filter( time <= parseddates[t])

# /----------------------------------------------------------#
#/   Make lineplot of stacked month

l <- ggplot(data=sum_df_temp) +

		geom_line( aes(x=time, y=med), color='red'. size=0.18) + 
		geom_ribbon( aes(x=time, ymin=min, ymax=), fill='red', alpha=0.2)+

		# plot the last value as point
		geom_point(aes(	x=max(as.Date(sum_df_temp$month, "%Y-%m-%d")), 
						y=sum_df_temp[which.max(as.Date(sum_df_temp$month)), 'sum_flux']), 
						shape=21, color='red', fill='black', size=0.6) +

		xlab("")  + ylab("Wetland CH4 emissions (Tg)") +

		# axes limit
		scale_x_date(date_breaks = "2 year", date_labels = "%Y", 
					limits=c(as.Date("2000-01-01", "%Y-%m-%d"), 
							 as.Date("2017-12-31", "%Y-%m-%d")),
					expand=c(0,0)) +  

		scale_y_continuous(limits=c(0, 25), breaks=c(0, 5, 10,15,20, 25)) + 

		line_plot_theme +
		theme(	legend.position = "right",
				plot.margin = unit( c(-2, 0, -2, 0) , "mm"))

