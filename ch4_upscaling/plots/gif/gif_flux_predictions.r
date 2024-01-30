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



#  get tower locations 
bams_towers <- read.csv("../../data/towers/BAMS_site_coordinates.csv")
xy <- bams_towers[,c(3,4)]

bams_towers <- SpatialPointsDataFrame(coords = xy, data = bams_towers,
                               proj4string = crs(masked_flux_stack))
bams_towers <- data.frame(bams_towers)



# prep gif plottin theme         ----------------------------------------------------
gif_map_theme <- function(base_size=48){
  theme_minimal() +
    
    theme(legend.position=c(0.1, 0.4),
          #legend.title = element_blank(),
          legend.title=element_text(size=40),
          legend.text=element_text(size=40),
          plot.title = element_text(hjust = 0.5, face="bold", size = 40),
          legend.key.size = unit(10, "mm"),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank()) }




masked_flux_stack <- readRDS('../../output/results/upscaled_stack_flux_g_m2_month.rds')


#ani.options("convert")
saveGIF({
  
  # loop through hyde years ======================================================
  for (t in 1:(length(names(masked_flux_stack)))){
    
    # #  percentage wetland
    flux <- as(masked_flux_stack[[t]], "SpatialPixelsDataFrame")
    flux <- as.data.frame(flux)
    names(flux) <- c("layer","x","y")
    #flux <- flux[flux$layer > 0,]
    #flux$layer <- flux$layer * 100
    
    
    # # convert to discontinuous 
    # my_breaks = seq(0,400,50)
    # flux$layer <- cut(flux$layer, breaks = my_breaks, dig.lab=10)
    # 
    # # replace the categories stings to make them nicer in the legend
    # flux$layer <- gsub("\\(|\\]", "", flux$layer)
    # flux$layer <- gsub("\\,", "-", flux$layer)
    
    
    
    wetplot <- ggplot() +
      
      # background countries
      geom_polygon(data=countries_wgs84_df, aes(long, lat, group=group) , fill="grey90") +
      
      # Fw grid
      geom_tile(data=flux, aes(x=x, y=y, fill=layer)) +
      
      # country outlines
      geom_path(data=countries_wgs84_df, aes(long, lat, group=group), color='black', size=0.01) +
      
      # Tower sites
      geom_point(data=bams_towers, aes(Longitude, Latitude), color='black', fill= "green", shape=21,  size=6) +
      
    
      ggtitle(parse_date_time(str_sub(names(masked_flux_stack[[t]]),-10,-1), 'ymd')) +
      #geom_text(aes(x=-50, y=-10)) + 
      
      labs(title = paste("CH4 emission", str_sub(names(masked_flux_stack[[t]]),-10,-1), 'ymd'),
           #subtitle = "Uscaled from 35? eddy covariance flux towers",
           caption = "Uscaled from eddy covariance flux towers.\nNote: only showing pixels with >1% wetland area")+ 
           #x = "year", y = "team runs per game") 
      
      scale_x_continuous(limits=c(-180, 180))+
      scale_y_continuous(limits=c(-60, 80))+
      
      guides(fill = guide_legend(title = expression(paste("g m"^-2, " month"^-1)))) +
      #guides(fill = guide_legend(title = expression(paste("nmols m"^-2, " s"^-1)))) +
      guides(shape = guide_legend(override.aes = list(size = 10))) +
      
      
      coord_equal() +
      gif_map_theme() +
      
      #scale_fill_gradient(low="yellow", high="red", limits=c(0, 15)) +
      scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 15), breaks=seq(0,15,1))+
                           #labels=c(0,NA,NA,NA,NA,5,NA,NA,NA,NA,10,NA,NA,NA,NA,15)) +
      #scale_fill_manual(values = colorRampPalette(brewer.pal(12, "YlOrRd"))(10), limits = c(0,400)) +
      
      theme(legend.position=c(0.1, 0.3))
    
    show(wetplot)
    
  }
},  movie.name = "../../output/figures/gif/flux_upscale_v01_2yrs.gif", ani.width=2000, ani.height=1000, interval = 0.8, clean=TRUE)
dev.off()

