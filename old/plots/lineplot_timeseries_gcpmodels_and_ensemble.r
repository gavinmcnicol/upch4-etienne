
# read in summary table
g <- read.csv("../output/results/gcp_ch4_model_sum.csv", stringsAsFactors = F)
g$date <- as.Date(g$date)
g$flux_tg <- g$flux / 1e12


# make line plot
ggplot() +
  
  # individual models
  geom_line(data= subset(g, model != "ensemble"),
            aes(x=date, y=flux_tg, group=model, color=model), size=0.6) +
  
  
  geom_line(data= subset(g, model == "ensemble"),
            aes(x=date, y=flux_tg), color="black", size=0.8) +
  
  scale_x_date(date_labels = "%Y", expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  theme_bw() +
  theme(legend.position = "top",
        legend.title = element_blank()) +
  guides(color=guide_legend(nrow=3, byrow=TRUE)) +
  xlab("") +
  ylab("Monthly global CH4 flux (Tg month-1)")


### save plot
ggsave("../output/figures/lineplot_timeseries_gcpmodels_and_ensemble.png",
       width=180, height=200, dpi=300, units='mm', type = "cairo-png")

dev.off()
