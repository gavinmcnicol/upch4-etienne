

# Functon making diff map
diff_map_function <- function(x, title){
    
    # Color ramp limits
    maxcap <- 30 #50
    mincap <- -30 #-50
    
    #/  Reformat to: robinson df 
    x <- WGSraster2dfROBIN(x)
    names(x) <- c('x','y','layer')
    
    # Set ceiling and floor values
    x<- x %>% 
        mutate(layer=ifelse(layer>maxcap, maxcap, layer)) %>% 
        mutate(layer=ifelse(layer< mincap, mincap, layer))
    
    #--------------------------------------------------------------------------------
    diff_map <- 
        ggplot() +
        
        # add background country polygons
        geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey95') +
        
        # Flux grid
        geom_raster(data=x, aes(x=x, y=y, fill=layer)) +
        
        # add outline of background countries
        geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
        
        # Add outline bounding box
        geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.1) +
        
        scale_fill_gradient2(	low = scales::muted('blue'),
                              mid = 'grey95',
                              high = scales::muted('red'),
                              na.value = 'white',
                              midpoint = 0) +

        guides(fill = guide_colorbar(  
            nbin=10, raster=F, barheight = 4, barwidth=.5,
            frame.colour=c('black'), frame.linewidth=0.5,
            ticks.colour='black',  direction='vertical',
            title = expression(paste("Difference\nmg(CH"[4]*") m"^-2*" day"^-1)))) +
        
        ggtitle(title) +
        coord_equal() +
        map_theme() +      
        theme(	legend.position= c(0.03, 0.65),
               plot.margin = unit(c(-2, -2, -2, 10), 'mm'))
    
    return(diff_map)
    }
