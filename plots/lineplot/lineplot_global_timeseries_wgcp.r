# Get plot theme
source("./plots/theme/line_plot_theme.r")

#options(date.origin = "1980-01-01")

gcp <- read.csv("../output/results/gcp_ch4_model_sum_2000_2017.csv", 
                stringsAsFactors = FALSE) 
# gcp <- read.csv("../output/results/gcp_ch4_model_sum_old.csv", 
#                 stringsAsFactors = FALSE) 

gcp<- gcp %>%
  filter(model != "ensemble") %>%
  #  mutate(flux = flux * 1e-12) %>%
  dplyr::select(-units) %>%
  group_by(date) %>%
  summarise( med = median(flux),
             min = min(flux),
             max = max(flux)) %>%
    mutate(time = ymd(date)) %>%
    filter(time <= parseddatessubset[t])
 
 
 
 # /----------------------------------------------------------
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
	   mutate(time = floor_date(time, "month")) %>%
	   filter(time <= parseddatessubset[t])
 
# print(max(gcp$time))
# print(max(sum_df_temp$time))
# print(parseddatessubset[t])

 # /----------------------------------------------------------#
 #/   Make lineplot of stacked month
 
 l <- ggplot(data=sum_df_temp) +
   
   # GCP ensemble
   geom_line(data=gcp, aes(x=time, y=med), color='grey75', size=0.18) + 
   geom_ribbon(data=gcp, aes(x=time, ymin=min, ymax=max), fill='grey75', alpha=0.2) +
   
   # Upscaled flux
   geom_line(   aes(x=time, y=med), color='red', size=0.18) + 
   geom_ribbon( aes(x=time, ymin=min, ymax=max), fill='red', alpha=0.2) +
   
   # Moving point - of upscaling
   geom_point(aes(	x= unlist(max(sum_df_temp$time)), 
                   y= c(sum_df_temp[which.max(sum_df_temp$time), 'med'])$med ), 
              shape=21, color='red', fill='black', size=0.6) +
   
   # Axes labels
   xlab("")  + ylab("Wetland CH4 emissions (Tg)") +
   
   # Axes limits & ticks
   scale_x_date(date_breaks = "1 year", date_labels = "%Y", 
                limits=c(ymd("2010-01-01"), 
                         ymd("2013-01-01")),
                expand=c(0,0)) +  
   
   scale_y_continuous(limits=c(0, 42), breaks=seq(0,40,10)) + 
   
   line_plot_theme +
   theme(	legend.position = "right",
          plot.margin = unit( c(-2, 2, -2, 0) , "mm"))

 