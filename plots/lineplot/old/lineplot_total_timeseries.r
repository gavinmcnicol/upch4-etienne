# Get plot theme
source("./plots/theme/line_plot_theme.r")
library(stringr)

# /----------------------------------------------------------------------#
#/   Read in GCP emission sums                                  ----------
gcp_monthly <- read.csv("../output/results/gcp_ch4_model_sum_2000_2017_indiv.csv") %>%
              mutate(date = as.Date(date, format="%Y-%m-%d")) %>%
              mutate(year = year(date)) %>%
              mutate(model = str_split(gcp_monthly$model, "_", simplify=TRUE)[,1])

gcp_annual <- gcp_monthly %>% 
              dplyr::select(-date) %>%
              group_by(model, year) %>%
              summarise(flux = sum(flux))


# /----------------------------------------------------------------------#
#/   Get sum of RF upscaling                                    ----------

# Make date list of monthly time steps
date_ls <- seq(as.Date("2001-01-01"), as.Date("2018-12-01"), by="months")



monthly_df <- read.csv( "../output/results/sums/v04/boot_sum_TgCH4month_m1.csv") %>%
              mutate(date = date_ls) %>%
              # mutate(date = as.Date(date, format="%Y-%m-%d")) %>%
              mutate(year = year(date))

annual_df <-  monthly_df %>% 
			        dplyr::select(-date) %>%
              group_by(year) %>%
              summarise_all(sum, na.rm=TRUE)




# /----------------------------------------------------------------------#
#/   Make monthly lineplot                                      ----------

m <- ggplot(data=monthly_df) +
  

  geom_line(data=gcp_monthly, aes(x=date, y=flux, color=model), size=0.2) +
  geom_line(   aes(x=date, y=mean), color='black', size=0.35) +
  geom_ribbon( aes(x=date, ymin=min, ymax=max), fill='grey80', alpha=0.15) +

  xlab("")  + ylab("Wetland CH4 emissions (Tg month-1)") +
  
  scale_y_continuous(limits= c(0, 40), expand=c(0,0)) +

  # axes limit
  scale_x_date(date_breaks = "1 year", date_labels = "%Y",
               limits=c(ymd("2001-01-01"), ymd("2017-12-31")),
               expand=c(0,0)) +
  
  # scale_y_continuous(limits=c(140, 220), breaks=seq(140, 220, 20)) + 
  line_plot_theme +
  theme(legend.position = "right",
        plot.margin = unit( c(3, 0, -2, 3) , "mm"))

# Save
ggsave("../output/figures/total_flux_monthly_wgcp.png", m,
       width=180, height=60, dpi=400, units='mm', type= "cairo-png")
dev.off()



# /----------------------------------------------------------#
#/   Make Annual lineplot
a <- ggplot(data=annual_df) +
  

  geom_line(data=gcp_annual, aes(x=year, y=flux, color=model), size=0.15) +

  geom_line(aes(x=year, y=mean), color='black', size=0.35) +
  # geom_point(aes(x=year, y=mean), color='blue', size=0.3) +
  geom_ribbon( aes(x=year, ymin=min, ymax=max), fill='grey80', alpha=0.25) +



  xlab("")  + ylab("Wetland CH4 emissions (Tg year-1)") +
  scale_y_continuous(limits= c(0, 350), expand=c(0,0), breaks=c(0, 50, 100, 150, 200, 250, 300)) +
  scale_x_continuous(expand=c(0,0), breaks=seq(2001,2017), labels=seq(2001,2017)) +

  # axes limit
  # scale_x_date(date_breaks = "2 year", date_labels = "%Y",
  #              limits=c(ymd("2000-01-01"), ymd("2017-12-31")),
  #              expand=c(0,0)) +
  
  # scale_y_continuous(limits=c(140, 220), breaks=seq(140, 220, 20)) + 
  line_plot_theme +
  theme(legend.position = "right",
        plot.margin = unit( c(3, 0, -2, 3) , "mm"))


ggsave("../output/figures/total_flux_annual_wgcp.png", a,
       width=180, height=60, dpi=400, units='mm', type= "cairo-png")
dev.off()






# # /----------------------------------------------------------#
# #/   Make monthly lineplot

# source('./plots/theme/line_plot_theme.r')

# m <- ggplot(data=oud_df) +

#   geom_line(   aes(x=date, y=sum_mean_tgmonth), color='red', size=0.35) +
#   geom_ribbon( aes(x=date, ymin=sum_mean_tgmonth-sum_sd_tgmonth, ymax=sum_mean_tgmonth+sum_sd_tgmonth), 
#     fill='red', alpha=0.35) +
  

#   xlab("")  + ylab(expression(Wetland~emissions~(Tg~CH[4]~month^{-1}))) +

#   # scale_y_continuous(limits= c(0, 40), expand=c(0,0)) +
#   # axes limit
#   scale_x_date(date_breaks = "1 year", date_labels = "%Y",
#                limits=c(ymd("2001-01-01"), ymd("2015-12-31")),
#                expand=c(0,0)) +
  
#   facet_wrap(~member, ncol=2) +
#   # scale_y_continuous(limits=c(140, 220), breaks=seq(140, 220, 20)) + 
#   line_plot_theme +
#   theme(legend.position = "none",
#         plot.margin = unit( c(8, 8, 8, 8) , "mm"))


# # Save to file
# ggsave("../output/figures/total_TgCH4month_perensemble_facet.png", m,
#        width=180, height=200, dpi=400, units='mm', type= "cairo-png")
# dev.off()

