# This script make lineplots of ML totals and GCP totals. 
#   - compiled sums from 

oud_df   <- data.frame()
oud_m_df <- data.frame()

# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = n_timesteps) #nlayers(stack))  # 216


# /------------------------------------------------
#/ Loop through 8 ML ensembles
for (m in c(start_members:n_members)){

	print(m)

	### READ INPUTS
	nc_filename <- paste0('../output/results/grids/v03/upch4_v03_m', m, '_TgCH4month_Aw.nc')

	mean_ch4 <- stack(nc_filename, varname='mean_ch4')
	sd_ch4   <- stack(nc_filename, varname='sd_ch4')
	var_ch4  <- stack(nc_filename, varname='var_ch4')

	# Calculate sum
	mean_ch4_sum <- data.frame(cellStats(mean_ch4, stat='sum', na.rm=TRUE))
	sd_ch4_sum   <- data.frame(cellStats(sd_ch4,   stat='sum', na.rm=TRUE))
	var_ch4_sum  <- data.frame(cellStats(var_ch4,  stat='sum', na.rm=TRUE))

	names(mean_ch4_sum) <- 'sum_mean_tgmonth'
	names(sd_ch4_sum)   <- 'sum_sd_tgmonth'
	names(var_ch4_sum)  <- 'sum_var_tgmonth'

	# Bind the columns together
	oud_m_df <- bind_cols(mean_ch4_sum, sd_ch4_sum) %>%
				bind_cols(., var_ch4_sum)

	# Add columns for data and member#
	oud_m_df$date   <- date_ls
	oud_m_df$member <- m

	# Bind rows to df including other 
	oud_df <- bind_rows(oud_df, oud_m_df)

	glimpse(oud_df)

	}

write.csv(oud_df, '../output/results/sums/final_model_tgmonth_sum.csv')




# /----------------------------------------------------------#
#/   Make monthly lineplot

source('./plots/theme/line_plot_theme.r')

m <- ggplot(data=oud_df) +

  geom_line(   aes(x=date, y=sum_mean_tgmonth), color='red', size=0.35) +
  geom_ribbon( aes(x=date, ymin=sum_mean_tgmonth-sum_sd_tgmonth, ymax=sum_mean_tgmonth+sum_sd_tgmonth), 
  	fill='red', alpha=0.35) +
  

  xlab("")  + ylab(expression(Wetland~emissions~(Tg~CH[4]~month^{-1}))) +

  # scale_y_continuous(limits= c(0, 40), expand=c(0,0)) +
  # axes limit
  scale_x_date(date_breaks = "1 year", date_labels = "%Y",
               limits=c(ymd("2001-01-01"), ymd("2015-12-31")),
               expand=c(0,0)) +
  
  facet_wrap(~member, ncol=2) +
  # scale_y_continuous(limits=c(140, 220), breaks=seq(140, 220, 20)) + 
  line_plot_theme +
  theme(legend.position = "none",
        plot.margin = unit( c(8, 8, 8, 8) , "mm"))


# Save to file
ggsave("../output/figures/total_TgCH4month_perensemble_facet.png", m,
       width=180, height=200, dpi=400, units='mm', type= "cairo-png")
dev.off()








# /----------------------------------------------------------#
#/   Make monthly lineplot all on same panel

m <- ggplot(data=oud_df) +
  
  # geom_line(data=gcp_monthly, aes(x=date, y=flux, color=model), size=0.2) +

  geom_line(   aes(x=date, y=sum_mean_tgmonth, color=as.factor(member)), size=0.35) +
  # geom_ribbon( aes(x=date, ymin=sum_mean_tgmonth-sum_sd_tgmonth, ymax=sum_mean_tgmonth+sum_sd_tgmonth), 
  # 	fill='red', alpha=0.35) +
  

  xlab("")  + ylab(expression(Wetland~emissions~(Tg~CH[4]~month^{-1}))) +

  # axes limit
  scale_x_date(date_breaks = "1 year", date_labels = "%Y",
               limits=c(ymd("2001-01-01"), ymd("2015-12-31")),
               expand=c(0,0)) +
  
  # facet_wrap(~member, ncol=2) +
  # scale_y_continuous(limits=c(140, 220), breaks=seq(140, 220, 20)) + 
  line_plot_theme +
  theme(legend.position = "none",
        plot.margin = unit( c(8, 8, 8, 8) , "mm"))


# Save to file
ggsave("../output/figures/total_TgCH4month_perensemble.png", m,
       width=180, height=110, dpi=400, units='mm', type= "cairo-png")
dev.off()