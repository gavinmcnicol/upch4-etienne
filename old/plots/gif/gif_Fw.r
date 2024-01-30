

source("./get_country_bbox_shp_for_ggplot_map.r")

# read the netcdf
#f <- '../../data/wetmap/gcp-ch4_wetlands_2000-2017_025deg.nc.gz'
f <- '../../data/wetmap/gcp-ch4_wetlands_2000-2017_025deg.nc'


# unzip to memory
w <- gunzip(f)

# open netcdf file
wo <- nc_open(f)


# read wet fraction as raster brick
Fw <-brick(f, varname="Fw")





gif_map_theme <- function(base_size=7){
  theme_minimal() +
    
    theme(legend.position=c(0.1, 0.4),
          legend.title = element_blank(),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank()) }




#ani.options("convert")
saveGIF({
  
  # loop through hyde years ======================================================
  for (t in 1:(length(names(Fw)))){

    # #  percentage wetland
    wet <- as(Fw[[t]], "SpatialPixelsDataFrame")
    wet <- as.data.frame(wet)
    names(wet) <- c("layer","x","y")
    wet <- wet[wet$layer > 0,]
    wet$layer <- wet$layer * 100
    
    my_breaks = seq(0,100,10)
    wet$layer <- cut(wet$layer, breaks = my_breaks, dig.lab=10)
    
    
    # replace the categories stings to make them nicer in the legend
    wet$layer <- gsub("\\(|\\]", "", wet$layer)
    wet$layer <- gsub("\\,", "-", wet$layer)
    
    
    
    wetplot <- ggplot() +
      
      # background countries
      geom_polygon(data=countries_wgs84_df, aes(long, lat, group=group) , fill="grey90") +
      
      # Fw grid
      geom_tile(data=wet, aes(x=x, y=y, fill=layer)) +
      
      geom_path(data=countries_wgs84_df, aes(long, lat, group=group), color='black', size=0.01) +
      
      
      ggtitle(ymd("1992-01-01") %m+% days(round(wo$dim$time$vals[t]))) +
      
      scale_x_continuous(limits=c(-180, 180))+
      scale_y_continuous(limits=c(-60, 80))+
      
      
      coord_equal() +
      gif_map_theme() +
      #scale_fill_brewer(palette='YlOrRd', direction=1)+#, limits=c(0,100)) +
      scale_fill_manual(values = colorRampPalette(brewer.pal(12, "YlOrRd"))(10)) +
      theme(legend.position=c(0.1, 0.3))
    
    show(wetplot)
    
  }
},  movie.name = "../../output/figures/gif/wetland_area.gif", ani.width=2000, ani.height=1000, interval = 0.8, clean=TRUE)
dev.off()

