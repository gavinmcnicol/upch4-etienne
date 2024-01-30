
# /-------------------------------------------------
#/  Read 3 flux inputs: 3 average maps

gcp1_d<- raster('../output/diff/diff_upch4_gcp.tif')
ct1_d <- raster('../output/diff/diff_upch4_wc.tif')
wc1_d <- raster('../output/diff/diff_upch4_ct.tif')

maxcap <- 30
mincap <- -30

diff_map_function <- function(x, title){
    
    #/  Reformat to: robinson df 
    x <- WGSraster2dfROBIN(x)
    names(x) <- c('x','y','layer')
    
    x<- x %>% 
        mutate(layer=ifelse(layer>maxcap, maxcap, layer)) %>% 
        mutate(layer=ifelse(layer< mincap, mincap, layer))
 
    
    #--------------------------------------------------------------------------------
    diff_map <- 
        ggplot() +
        
        # add background country polygons
        geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey95') +
        
        # Flux grid
        geom_tile(data=x, aes(x=x, y=y, fill=layer)) +
        
        # add outline of background countries
        geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
        
        # Add outline bounding box
        geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.2) +
        
        scale_fill_gradient2(	low = scales::muted('blue'),
                              mid = 'grey95',
                              high = scales::muted('red'),
                              na.value = 'white',
                              midpoint = 0) +
        
        # labs(fill='Flux differnce\n(mgCH4 m^2 day^1)')  +
        guides(fill = guide_legend(override.aes = list(size = 0.3),
                                   title = expression(paste("mg(CH"[4]*") m"^-2*" day"^-1)))) +
        
        ggtitle(title) +
        coord_equal() +
        gif_map_theme +      
        theme(	legend.position= c(0.03, 0.5),
               plot.margin = unit(c(1, -3, 1, 8), 'mm'))
    
    return(diff_map)
    
    }



wc1_diff_map <- diff_map_function(wc1_d)

# /-----------------------------------------------------------#
#/   Cap max values 

gcp1_dr<- gcp1_dr %>% mutate(layer=ifelse(layer>maxcap, maxcap, layer))
ct1_dr <- ct1_dr %>% mutate(layer=ifelse(layer>maxcap, maxcap, layer))
wc1_dr <- wc1_dr %>% mutate(layer=ifelse(layer>maxcap, maxcap, layer))

# Cap min values at 50
gcp1_dr<- gcp1_dr %>% mutate(layer=ifelse(layer< mincap, mincap, layer))
ct1_dr <- ct1_dr %>% mutate(layer=ifelse(layer< mincap, mincap, layer))
wc1_dr <- wc1_dr %>% mutate(layer=ifelse(layer< mincap, mincap, layer))


#--------------------------------------------------------------------------------
gcp_diff_map <- 
    ggplot() +
    
    # add background country polygons
    geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey95') +
    
    # Flux grid
    geom_tile(data=gcp1_dr, aes(x=x, y=y, fill=layer)) +
    
    # add outline of background countries
    geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
    
    # Add outline bounding box
    geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.2) +
    
    scale_fill_gradient2(	low = scales::muted('blue'),
                          mid = 'grey95',
                          high = scales::muted('red'),
                          na.value = 'white',
                          midpoint = 0) +
    
    # labs(fill='Flux differnce\n(mgCH4 m^2 day^1)')  +
    guides(fill = guide_legend(override.aes = list(size = 0.3),
                               title = expression(paste("mg(CH"[4]*") m"^-2*" day"^-1)))) +
    
    ggtitle('Upscaling - GCP ensemble') +
    coord_equal() +
    gif_map_theme +      
    theme(	legend.position= c(0.03, 0.5),
           plot.margin = unit(c(1, -3, 1, 8), 'mm'))

gcp_diff_map




# /-------------------------------------------------
#/  Reformat to: robinson df 
gcp1_dr <- WGSraster2dfROBIN(gcp1_d)
names(gcp1_dr) <- c('x','y','layer')

ct1_dr  <- WGSraster2dfROBIN(ct1_d)
names(ct1_dr) <- c('x','y','layer')

wc1_dr  <- WGSraster2dfROBIN(wc1_d)
names(wc1_dr) <- c('x','y','layer')


# /-----------------------------------------------------------#
#/  Convert to Saunois factor scale; for color ramp
# gcp1_dr <- To.Diff.Map.Scale(gcp1_dr)
# ct1_dr  <- To.Diff.Map.Scale(ct1_dr)
# wc1_dr  <- To.Diff.Map.Scale(wc1_dr)


# /-----------------------------------------------------------#
#/   Cap max values 
maxcap <- 30
mincap <- -30

gcp1_dr<- gcp1_dr %>% mutate(layer=ifelse(layer>maxcap, maxcap, layer))
ct1_dr <- ct1_dr %>% mutate(layer=ifelse(layer>maxcap, maxcap, layer))
wc1_dr <- wc1_dr %>% mutate(layer=ifelse(layer>maxcap, maxcap, layer))

# Cap min values at 50
gcp1_dr<- gcp1_dr %>% mutate(layer=ifelse(layer< mincap, mincap, layer))
ct1_dr <- ct1_dr %>% mutate(layer=ifelse(layer< mincap, mincap, layer))
wc1_dr <- wc1_dr %>% mutate(layer=ifelse(layer< mincap, mincap, layer))


#--------------------------------------------------------------------------------
gcp_diff_map <- 
	ggplot() +
	
	# add background country polygons
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey95') +

	# Flux grid
	geom_tile(data=gcp1_dr, aes(x=x, y=y, fill=layer)) +
	
	# add outline of background countries
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
	
	# Add outline bounding box
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.2) +

	scale_fill_gradient2(	low = scales::muted('blue'),
							mid = 'grey95',
							high = scales::muted('red'),
							na.value = 'white',
							midpoint = 0) +

	# labs(fill='Flux differnce\n(mgCH4 m^2 day^1)')  +
    guides(fill = guide_legend(override.aes = list(size = 0.3),
                               title = expression(paste("mg(CH"[4]*") m"^-2*" day"^-1)))) +
    
    ggtitle('Upscaling - GCP ensemble') +
	coord_equal() +
	gif_map_theme +      
	theme(	legend.position= c(0.03, 0.5),
			plot.margin = unit(c(1, -3, 1, 8), 'mm'))

gcp_diff_map




#--------------------------------------------------------------------------------
wc_diff_map <- 
	ggplot() +
	
	# add background country polygons
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +

	# Flux grid
	geom_tile(data=wc1_dr, aes(x=x, y=y, fill=layer)) +
	
	# add outline of background countries
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
	
	# Add outline bounding box
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.2) +
	
	# Tower sites
	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +
	# theme_raster_map() +
	
	# scale_y_continuous(limits=c(-6600000, 8953595)) +
	# scale_y_continuous(limits=c(-60, 90))+

	scale_fill_gradient2(	low = scales::muted('blue'),
							mid = 'grey90',
							high = scales::muted('red'),
							na.value = 'white',
							midpoint = 0) +

	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
	coord_equal() +
	gif_map_theme +
    ggtitle('Upscaling - WetCharts') +
	theme(	legend.position= c(0.03, 0.5),
			plot.margin = unit(c(1, -3, 1, 8), 'mm'))




#--------------------------------------------------------------------------------
ct_diff_map <- 
	ggplot() +
	
	# add background country polygons
	geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +

	# Flux grid
	geom_tile(data=ct1_dr, aes(x=x, y=y, fill=layer)) +
	
	# add outline of background countries
	geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
	
	# Add outline bounding box
	geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.2) +
	
	# Tower sites
	# geom_point(data=bams_towers_robin, aes(LON.1, LAT.1), color='black', fill= 'black', shape=21,  size=0.5, stroke=0.1) +
	# theme_raster_map() +
	
	scale_y_continuous(limits=c(-6600000, 8953595)) +
	# scale_y_continuous(limits=c(-60, 90))+

	scale_fill_gradient2(	low = scales::muted('blue'),
							mid = 'grey90',
							high = scales::muted('red'),
							na.value = 'white',
							midpoint = 0) +

	labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)') +
    ggtitle('Upscaling - Carbon Tracker') +
	coord_equal() +
	gif_map_theme +      
	theme(	legend.position= c(0.03, 0.5),
			plot.margin = unit(c(1, -3, 1, 8), 'mm'))





# /-----------------------------------------------------------------------------
#/ arrange plots grob into layout 

library(ggpubr)
p <- ggarrange(gcp_diff_map, 
               wc_diff_map,
               ct_diff_map,
               ncol=1, labels = c('A', 'B', 'C'),
               align='h')



ggsave('../output/figures/diff_map/diff_map_v04_3panels.png',
	   p, width=180, height=240, dpi=300, units='mm')
dev.off()
