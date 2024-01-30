# Multi-panel figure
# A: ML map    				B: Lat barplot of fluxes
# C: diff map vs GCP		D: Lat barplot of diff
# E: diff map vs CT			F: Lat barplot of diff

# TODO:  Use different ML maps for 2001-2010  and 2001-2015
# Q. use only member #1 of ML?
# Q. Use different resolutions?  or all 1deg?
# Sum Tg differences per 1deg lat (need to upscale for that)
# Make table of comparison datasets?

source('plots/fcn/fcn_make_Saunois_scale.r')



# /-------------------------------------------------
#/  Get wetland area
# source('prep/final_v2_model/read_Fw.r')
# Aw_m2  <- aggregate(Aw_m2, fact=4, na.rm=TRUE, fun="sum")


# /-------------------------------------------------
#/  Read 3 flux inputs: 3 average maps

# Machine learning upsaling
upch4_025 <- raster('../output/results/grids/v04/m1/upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif') # 0.25
# ml1   <- aggregate(ml025, fact=4, na.rm=TRUE, fun="mean")

# Land Surface Models
# gcp <- raster('../output/comparison/gcp_models/gcp_avg_mgCH4m2day_2001_2015.tif') # 0.5
gcp <- raster('../output/comparison/gcp_models/gcp_avg_mgCH4m2day_2001_2017.tif')
# gcp1 <- aggregate(gcp,    fact=2, na.rm=TRUE, fun="mean")

# Wetcharts 
wc  <- stack('../output/comparison/wetcharts/wc_ee_mean.tif')
wc  <- calc(wc, na.rm=TRUE, fun=mean)
wc  <- disaggregate(wc, fact=, method='')  # Disaggregate to 0.25deg
# wc1 <- aggregate(wc, fact=2, na.rm=TRUE, fun="mean")

# Carbon Tracker
ct1  <- raster("../output/comparison/carbontracker/ct_2000_2010_mgCH4m2yr.tif")

# 
# # /-------------------------------------------------
# #/  Calculate differences between maps at 1deg resolution
# gcp1_d <- ml1 - gcp1
# ct1_d  <- ml1 - ct1
# wc1_d  <- ml1 - wc1
# 
# 
# # /-------------------------------------------------
# #/  Reformat to: robinson df 
# gcp1_dr <- WGSraster2dfROBIN(gcp1_d)
# ct1_dr  <- WGSraster2dfROBIN(ct1_d)
# wc1_dr  <- WGSraster2dfROBIN(wc1_d)
# 
# 
# # /-----------------------------------------------------------#
# #/  Convert to Saunois factor scale; for color ramp
# # gcp1_dr <- To.Saunois2020.Scale(gcp1_dr)
# # ct1_dr  <- To.Saunois2020.Scale(ct1_dr)
# # wc1_dr  <- To.Saunois2020.Scale(wc1_dr)
# 
# 
# gcp1_dr <- To.Diff.Map.Scale(gcp1_dr)
# ct1_dr  <- To.Diff.Map.Scale(ct1_dr)
# wc1_dr  <- To.Diff.Map.Scale(wc1_dr)
# 
# 
# # Cap values at 50
# gcp1_dr<- gcp1_dr %>% mutate(layer=ifelse(layer>50, 50, layer))
# ct1_dr <- ct1_dr %>% mutate(layer=ifelse(layer>50, 50, layer))
# wc1_dr <- wc1_dr %>% mutate(layer=ifelse(layer>50, 50, layer))
# 
# 
# gcp1_dr<- gcp1_dr %>% mutate(layer=ifelse(layer< -50, -50, layer))
# ct1_dr <- ct1_dr %>% mutate(layer=ifelse(layer< -50, -50, layer))
# wc1_dr <- wc1_dr %>% mutate(layer=ifelse(layer< -50, -50, layer))
# 
# 
# # /----------------------------------------------------------------------------#
# #/    Get predicted grids
# my_palette <- c(sequential_hcl(10, palette = "YlOrRd"), 'grey90')
# 
# 
# 
# #--------------------------------------------------------------------------------
# gcp_diff_map <- 
# 	ggplot() +
# 	
# 	# add background country polygons
# 	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +
# 
# 	# Flux grid
# 	geom_tile(data=gcp1_dr, aes(x=x, y=y, fill=layer)) +
# 	
# 	# add outline of background countries
# 	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
# 	
# 	# Add outline bounding box
# 	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.2) +
# 	
# 	# Tower sites
# 	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
# 	# theme_raster_map() +
# 	
# 	scale_y_continuous(limits=c(-6600000, 8953595)) +
# 	# scale_y_continuous(limits=c(-60, 90))+
# 
# 	scale_fill_gradient2(	low = scales::muted("blue"),
# 							mid = "grey90",
# 							high = scales::muted("red"),
# 							na.value = "white",
# 							midpoint = 0) +
# 	# scale_fill_manual(values = my_palette) +
# 
# 	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
# 	coord_equal() +
# 	gif_map_theme +      
# 	theme(	legend.position= c(0.03, 0.5),
# 			plot.margin = unit(c(1, -3, 1, 8), "mm"))
# 
# 
# 
# ggsave("../output/figures/diff_map/gcp_diff_map.png", 
# 	   gcp_diff_map, width=180, height=80, dpi=300, units="mm")
# dev.off()
# 
# 
# 
# 
# 
# #--------------------------------------------------------------------------------
# wc_diff_map <- 
# 	ggplot() +
# 	
# 	# add background country polygons
# 	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +
# 
# 	# Flux grid
# 	geom_tile(data=wc1_dr, aes(x=x, y=y, fill=layer)) +
# 	
# 	# add outline of background countries
# 	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
# 	
# 	# Add outline bounding box
# 	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.2) +
# 	
# 	# Tower sites
# 	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
# 	# theme_raster_map() +
# 	
# 	scale_y_continuous(limits=c(-6600000, 8953595)) +
# 	# scale_y_continuous(limits=c(-60, 90))+
# 
# 	scale_fill_gradient2(	low = scales::muted("blue"),
# 							mid = "grey90",
# 							high = scales::muted("red"),
# 							na.value = "white",
# 							midpoint = 0) +
# 	# scale_fill_manual(values = my_palette) +
# 
# 	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
# 	coord_equal() +
# 	gif_map_theme +      
# 	theme(	legend.position= c(0.03, 0.5),
# 			plot.margin = unit(c(1, -3, 1, 8), "mm"))
# 
# 
# 
# ggsave("../output/figures/diff_map/wc_diff_map.png", 
# 	   wc_diff_map, width=180, height=80, dpi=300, units="mm")
# dev.off()
# 
# 
# 
# 
# #--------------------------------------------------------------------------------
# ct_diff_map <- 
# 	ggplot() +
# 	
# 	# add background country polygons
# 	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +
# 
# 	# Flux grid
# 	geom_tile(data=ct1_dr, aes(x=x, y=y, fill=layer)) +
# 	
# 	# add outline of background countries
# 	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
# 	
# 	# Add outline bounding box
# 	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.2) +
# 	
# 	# Tower sites
# 	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= "black", shape=21,  size=0.5, stroke=0.1) +
# 	# theme_raster_map() +
# 	
# 	scale_y_continuous(limits=c(-6600000, 8953595)) +
# 	# scale_y_continuous(limits=c(-60, 90))+
# 
# 	scale_fill_gradient2(	low = scales::muted("blue"),
# 							mid = "grey90",
# 							high = scales::muted("red"),
# 							na.value = "white",
# 							midpoint = 0) +
# 	# scale_fill_manual(values = my_palette) +
# 
# 	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
# 	coord_equal() +
# 	gif_map_theme +      
# 	theme(	legend.position= c(0.03, 0.5),
# 			plot.margin = unit(c(1, -3, 1, 8), "mm"))
# 
# 
# 
# ggsave("../output/figures/diff_map/ct_diff_map.png", 
# 	   ct_diff_map, width=180, height=80, dpi=300, units="mm")
# dev.off()
