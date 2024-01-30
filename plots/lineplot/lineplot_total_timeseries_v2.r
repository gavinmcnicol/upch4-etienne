# This script make lineplots of ML totals and GCP totals. 
#   - compiled sums from 

# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = n_timesteps) #nlayers(stack))  # 216


sum_TgCH4_month <- 
         read.csv( "../output/results/sums/v04/boot_sum_TgCH4month_m1.csv") %>%
         group_by(m, t) %>%
         summarise( sum_TgCH4month_mean = mean(sum_TgCH4month, na.rm=T),
                    sum_TgCH4month_min  = min(sum_TgCH4month, na.rm=T),
                    sum_TgCH4month_max  = max(sum_TgCH4month, na.rm=T),
                    sum_TgCH4month_sd   = sd(sum_TgCH4month, na.rm=T)) %>%
         mutate(date = as.Date(date_ls[t])) %>%
         mutate(year = year(date))



sum_TgCH4_year <- 
         read.csv( "../output/results/sums/v04/boot_sum_TgCH4month_m1.csv") %>%
         mutate(date = as.Date(date_ls[t])) %>%
         mutate(year = year(date))
         group_by(m, t) %>%
         summarise( sum_TgCH4month_mean = mean(sum_TgCH4month, na.rm=T),
                    sum_TgCH4month_min  = min(sum_TgCH4month, na.rm=T),
                    sum_TgCH4month_max  = max(sum_TgCH4month, na.rm=T),
                    sum_TgCH4month_sd   = sd(sum_TgCH4month, na.rm=T)) %>%


# /-----------------------------------------------------------------#
#/   Read in GCP emission sums                            ----------
gcp_monthly <- read.csv("../output/results/gcp_ch4_model_sum_2000_2017_indiv.csv") %>%
              mutate(date = as.Date(date, format="%Y-%m-%d")) %>%
              mutate(year = year(date)) %>%
              mutate(model = str_split(gcp_monthly$model, "_", simplify=TRUE)[,1])

gcp_annual <- gcp_monthly %>% 
              dplyr::select(-date) %>%
              group_by(model, year) %>%
              summarise(flux = sum(flux))


# /----------------------------------------------------------------#
#/   Make monthly lineplot                              ---------

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