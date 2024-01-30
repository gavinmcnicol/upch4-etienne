# /----------------------------------------------------------------------------#
#/    Get other plotting obj

# Get mapping theme
source("./plots/theme/theme_gif_map.r")

# /----------------------------------------------------------------------------#
#/    Get polygon of continent outline                                     -----
library(rworldmap)
data(coastsCoarse)
sPDF <- getMap()[getMap()$ADMIN!='Antarctica',]
# read and reproject outside box
# bbox <- readOGR(natearth_dir, "ne_110m_wgs84_bounding_box") 
# bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
# bbox_robin_df <- fortify(bbox_robin)
sPDF_robin <- spTransform(sPDF, CRS("+proj=robin")) 
sPDF_robin_df <- fortify(sPDF_robin)


library(sf)
# /----------------------------------------------------------------------------#
#/    get polygon of continent outline                                     -----
library(rworldmap)
data(coastsCoarse)
coastsCoarse_robin <- spTransform(coastsCoarse, CRS("+proj=robin")) 
coastsCoarse_robin_df <- fortify(coastsCoarse_robin)


# /----------------------------------------------------------------------------
#/ GET UNWEIGHTED AS MASK 
med_stack <- brick("../output/results/grids/v02/rf_med_ch4_monthly_2001_2018.tif")
datmask <- med_stack[[1]]

# /----------------------------------------------------------------------------#
#/    Get predicted flux grid

# flux <- brick("../output/results/grids/v02/rf_mean_ch4_monthly_composite_2001_2018_mg_m2_day.tif")
# lw_cut <- 10^-1     # define low-end cutoff

# #flux[flux < 0] = lw_cut  # replace negative (sink) values
# flux[flux < lw_cut] = lw_cut  # replace very low values
# # Average the stack
# flux <- calc(flux, mean, na.rm=TRUE)

flux <- raster("../output/results/grids/v02/rf_mean_ch4_2001_2018_mg_m2_day.tif")

flux <- mask(flux, datmask)


# declare incoming CSR (should be done wayyyyyyy earlier than this)
# crs(flux) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
flux_robin <- projectRaster(flux, crs=CRS("+proj=robin"), method='ngb', over=TRUE)


# reformat rasters  for graph in ggplot 
flux_df <- as(flux_robin, "SpatialPixelsDataFrame")
flux_df <- as.data.frame(flux_df)
names(flux_df) <- c("layer", "x", "y")
# flux_df <- flux_df %>% filter(is.na(layer))


# ~~~ Cut ca diff into bins  --------------------------------------------------
my_breaks = c(0, 0.5, 1, 2, 5, 10, 15, 20, 30, 40, 50, 150)
flux_df$layer_cut <- cut(flux_df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)

# replace the categories stings to make them nicer in the legend
flux_df$layer_cut <- gsub("\\(|\\]", "", flux_df$layer_cut)
flux_df$layer_cut <- gsub("\\)|\\[", "", flux_df$layer_cut)
flux_df$layer_cut <- gsub("\\,", " to ", flux_df$layer_cut)
flux_df <- flux_df %>% mutate(layer_cut=ifelse(layer_cut=="50 to 150", "50+", layer_cut))

# ~~~ set legend order ----------
legend_order <- rev(c("0 to 0.5", "0.5 to 1", "1 to 2",  "2 to 5", "5 to 10", "10 to 15", "15 to 20", 
					   "20 to 30", "30 to 40", "40 to 50","50+"))
flux_df$layer_cut <- factor(flux_df$layer_cut, levels = legend_order)
# levels(flux_df$layer_cut)


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------

# bams_towers <- read.csv("../data/towers/BAMS_site_coordinates.csv")
bams_towers <- read.csv("../data/towers/db_v2_site_metadata_Feb2020.csv")  %>% 

    filter(IGBP %in% c("WET", 'WSA', "CRO - Rice")) %>%
    filter(ID != "--*") %>%
    filter(ID != "--") %>%
    filter(ID != "--**") %>%
    filter(YR_START != "--") %>%
    filter(YR_END != "--")

xy <- bams_towers[,c(5,6)]   # creat coordinates
xy <- bams_towers[,c(6,5)]   # creat coordinates
# bams_towers <- data.frame(SpatialPointsDataFrame(coords = xy, data = bams_towers))
bams_towers <- SpatialPointsDataFrame(coords = xy, data = bams_towers)


geo_proj = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
crs(bams_towers) = geo_proj


bams_towers_robin = spTransform(bams_towers, CRS("+proj=robin"))
bams_towers_robin = data.frame(bams_towers_robin)

# /----------------------------------------------------------------------------#
#/    Get predicted grids

my_palette <- c(sequential_hcl(10, palette = "YlOrRd"), 'grey90')


m <- ggplot() +
	
	# background countries
  	geom_polygon(data=sPDF, aes(long, lat, group=group), 
            color=NA, fill='grey95') +
  
	# Flux grid
	geom_tile(data=flux_df, aes(x=x, y=y, fill=layer_cut)) +
	
	# Coastline
	geom_path(data=coastsCoarse, aes(long, lat, group=group), 
	          color='black', size=0.08) +
	
	# Tower sites
	geom_point(data=bams_towers, aes(LON.1, LAT.1), #aes(Longitude, Latitude),
		color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
	
	# Write title as month-day format
	# ggtitle(substr(mymonths[t])) + 
	# ggtitle(mymonths[t]) + 
	#geom_text(aes(90, 0, label=substr(parseddates[t], 1, 7), size=4)) + 
	
	# Set scales (setting longitude can create tearing)
	#scale_x_continuous(limits=c(-180.1, 180.1))+
	scale_y_continuous(limits=c(-60, 90))+
	# scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 0.02), 
	# 					 breaks=c(0, 0.001, 0.005, 0.01, 0.02),
	# 					 #breaks=seq(0, 0.02, 0.002),
	# 					 labels=format_format(scientific = FALSE)) +

	scale_fill_manual(values = my_palette) +


	# scale_fill_gradientn(colors= rev(sequential_hcl(10, palette = 'YlOrRd')), 
	# 					trans="log", 
	# 					breaks=c(10^-1, 10^0, 10^1, 10^2),
	# 					#labels=c(10^-5, 10^-4, 10^-3, 10^-2),
	# 					labels=c(expression(10^{-1}),
	# 					         expression(10^{0}),
	# 					         expression(10^{1}),
	# 					         expression(10^{2})),
	# 					limits=c(lw_cut, 10^{2})) +


	# Format colorbar
	# guides(fill = guide_colorbar(nbin=10, raster=F, 
	#                              barheight = 3.5, barwidth=0.5, 
	#                              frame.colour=c("black"), frame.linewidth=0.2, 
	#                              ticks.colour="black", ticks.linewidth = 0.15,  
	#                              direction="vertical",
	#                              title = expression(paste("mg(CH"[4]*") m"^-2*" day"^-1)))) +
  				

	coord_equal() +
	gif_map_theme +      
	theme(	legend.position= c(0.01, 0.35),
			plot.margin = unit(c(1, -3, 1, 7), "mm"))



ggsave("/home/groups/robertj2/upch4/output/figures/ch4_mean_v200_g_m2_day_saunois2020legend.png", m,
       width=120, height=60, dpi=400, units="mm") #type = "cairo-png")
dev.off()



###################



robinmap <- ggplot() +
	
	# background countries
  	geom_polygon(data=sPDF_robin_df, aes(long, lat, group=group), 
            color=NA, fill='grey95') +
  
	# Flux grid
	geom_tile(data=flux_df, aes(x=x, y=y, fill=layer_cut)) +
	
	# Coastline
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), 
	          color='black', size=0.08) +
	
	# geom_path(data=bbox_robin_df, aes(long, lat, group=group), 
	#           color='black', size=0.08) +

	# Tower sites
	geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), #aes(Longitude, Latitude),
		color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
	
	# Write title as month-day format
	# ggtitle(substr(mymonths[t])) + 
	# ggtitle(mymonths[t]) + 
	#geom_text(aes(90, 0, label=substr(parseddates[t], 1, 7), size=4)) + 
	
	# Set scales (setting longitude can create tearing)
	#scale_x_continuous(limits=c(-180.1, 180.1))+
	# scale_y_continuous(limits=c(-60, 90))+
	# scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 0.02), 
	# 					 breaks=c(0, 0.001, 0.005, 0.01, 0.02),
	# 					 #breaks=seq(0, 0.02, 0.002),
	# 					 labels=format_format(scientific = FALSE)) +

	scale_fill_manual(values = my_palette) +

	# scale_fill_gradientn(colors= rev(sequential_hcl(10, palette = 'YlOrRd')), 
	# 					trans="log", 
	# 					breaks=c(10^-1, 10^0, 10^1, 10^2),
	# 					#labels=c(10^-5, 10^-4, 10^-3, 10^-2),
	# 					labels=c(expression(10^{-1}),
	# 					         expression(10^{0}),
	# 					         expression(10^{1}),
	# 					         expression(10^{2})),
	# 					limits=c(lw_cut, 10^{2})) +


	# Format colorbar
	# guides(fill = guide_colorbar(nbin=10, raster=F, 
	#                              barheight = 3.5, barwidth=0.5, 
	#                              frame.colour=c("black"), frame.linewidth=0.2, 
	#                              ticks.colour="black", ticks.linewidth = 0.15,  
	#                              direction="vertical",
	#                              title = expression(paste("mg(CH"[4]*") m"^-2*" day"^-1)))) +
  				

	coord_equal() +
	gif_map_theme +      
	theme(	legend.position= c(0.11, 0.35),
			plot.margin = unit(c(1, -3, 1, 4), "mm"))



ggsave("/home/groups/robertj2/upch4/output/figures/ch4_mean_v200_g_m2_day_saunois2020legend_robin.png", 
	   robinmap,
       width=80, height=50, dpi=600, units="mm") #type = "cairo-png")
dev.off()
