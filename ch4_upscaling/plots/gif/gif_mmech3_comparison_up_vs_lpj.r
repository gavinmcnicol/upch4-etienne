library(ncdf4)
library(R.utils)
library(raster)
library(gridExtra)
library(latticeExtra) 
library(grid) 
library(ggplot2)
library(animation)
library(maptools)
library(animation)
library(rgdal)
library(here)
library(lubridate)
library(stringr)

# set wd
here()


source("./get_country_bbox_shp_for_ggplot_map.r")


flux_stack <- readRDS('../../output/results/comparison_mmech4_upscaled_vs_lpj.rds')



#  get tower locations 
bams_towers <- read.csv("../../data/towers/BAMS_site_coordinates.csv")
xy <- bams_towers[,c(3,4)]

bams_towers <- SpatialPointsDataFrame(coords = xy, data = bams_towers,
                                      proj4string = crs(flux_stack))
bams_towers <- data.frame(bams_towers)




###       Cut the values              -------------------------------------------
my_breaks = seq(-8, 2, 0.5)
surv_data$hces_surv_asprcfao_cut <- cut(surv_data$hces_surv_asprcfao, breaks = my_breaks,
                                        dig.lab=10)



# prep gif plottin theme         ----------------------------------------------------
gif_map_theme <- function(base_size=48){
  theme_minimal() +
    
    theme(legend.position=c(0.1, 0.4),
          #legend.title = element_blank(),
          legend.key.height = unit(20, "mm"),
          #legend.key.size = unit(20, "mm"),
          legend.title=element_text(size=40),
          legend.text=element_text(size=40),
          plot.title = element_text(hjust = 0.5, face="bold", size = 40),
          legend.key.size = unit(10, "mm"),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank()) }




#ani.options("convert")
saveGIF({
  
  # loop through hyde years ======================================================
  for (t in 1:(length(names(flux_stack)))){
    
    # #  percentage wetland
    flux <- as(flux_stack[[t]], "SpatialPixelsDataFrame")
    flux <- as.data.frame(flux)
    names(flux) <- c("layer","x","y")
    #flux <- flux[flux$layer > 0,]
    #flux$layer <- flux$layer * 100
    
    
    # # convert to discontinuous 
    my_breaks =  c(-8,-1,-0.5, -0.25,0, 0.25, 0.5, 1, 2)  # seq(-10, 10, 0.5)
    flux$layer <- cut(flux$layer, breaks = my_breaks, dig.lab=10)
    # 
    # # replace the categories stings to make them nicer in the legend
    flux$layer <- gsub("\\(|\\]", "", flux$layer)
    flux$layer <- gsub("\\,", " - ", flux$layer)
    # surv_data <- surv_data %>% mutate(hces_surv_asprcfao_cut=ifelse(hces_surv_asprcfao_cut=="400 to 500000",
    #                                                                 "over 400",hces_surv_asprcfao_cut))
    # surv_data <- surv_data %>% mutate(hces_surv_asprcfao_cut=ifelse(hces_surv_asprcfao_cut=="-10000 to 0",
    #                                                                 "Negative",hces_surv_asprcfao_cut))
    flux$layer <- factor(flux$layer , levels=rev(c("-8 - -1", "-1 - -0.5", "-0.5 - -0.25", 
                                                   "-0.25 - 0",  "0.25 - 0.5", "0.5 - 1", "1 - 2")))
    
    
    
    
    
    wetplot <- ggplot() +
      
      # background countries
      #geom_polygon(data=countries_wgs84_df, aes(long, lat, group=group) , fill="grey90") +
      
      # Fw grid
      geom_tile(data=flux, aes(x=x, y=y, fill=layer)) +
      
      # country outlines
      geom_path(data=countries_wgs84_df, aes(long, lat, group=group), color='black', size=0.01) +
      
      # Tower sites
      geom_point(data=bams_towers, aes(Longitude, Latitude), color='black', fill= "red", shape=21,  size=5) +
      
      
      ggtitle(parse_date_time(str_sub(names(flux_stack[[t]]),2,11), 'ymd')) +
      #geom_text(aes(x=-50, y=-10)) + 
      
      labs(title = paste("CH4 flux ", str_sub(names(flux_stack[[t]]),2,11), "\nDifference tower upscaling vs LPJ-MERRA"),
           #subtitle = "Difference tower upscaling % LPJ-MERRA",
           caption = "Uscaled from eddy covariance flux towers.\nNote: only showing pixels with >1% wetland area")+ 
      
      scale_x_continuous(limits=c(-180, 180)) +
      scale_y_continuous(limits=c(-60, 80)) +
      
      guides(fill = guide_legend(title = expression(paste("g m"^-2, " month"^-1)))) +
      guides(shape = guide_legend(override.aes = list(size = 10))) +
      
      
      coord_equal() +
      gif_map_theme() +
      
      scale_fill_brewer(palette='PRGn') +
      # scale_fill_distiller(palette='PRGn', breaks= c(-6, -1, -0.5, -0.1, 0, 0.1, 0.5, 1, 6)) +  
      # palette='YlOrRd', direction=1, 
      #scale_fill_manual(values = colorRampPalette(brewer.pal(12, "YlOrRd"))(10), limits = c(-6, 2, 0.5)) +
      
      theme(legend.position=c(0.1, 0.3))
    
    show(wetplot)
    
    
    
    flux <- as(flux_stack[[t]], "SpatialPixelsDataFrame")
    flux <- as.data.frame(flux)
    names(flux) <- c("layer","x","y")
    
    
    diff_hist <- ggplot() + geom_histogram(data=flux, aes(x=layer, fill=layer), bins=100)
    
  
    
  }
},  movie.name = "../../output/figures/gif/comparison_up01_lpjmerra_2yrs.gif", ani.width=2000, ani.height=1000, interval = 0.8, clean=TRUE)
dev.off()

