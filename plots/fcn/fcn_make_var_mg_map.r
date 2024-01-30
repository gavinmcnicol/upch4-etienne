
make_flux_var_map <- function(flux_var, flux_mean, ceilingval){
    
    # ceilingval <- 400
    
    
    ## MAKE LOWFLUX MASK FOR VAR & VAR_PERC MAPS
    flux_mean[flux_mean < 0.5] <- NA
    
    
    # Calculate sd from var
    flux_cv <- sqrt(flux_var) / flux_mean * 100
    # Apply ceiling value
    flux_cv[flux_cv > ceilingval] <- ceilingval
    # Convert to df
    flux_var_df <- flux_cv %>% WGSraster2dfROBIN(.)
    

    # Make map
    flux_robin_cv_map <- 
        ggplot() +
        
        # Background countries
        geom_polygon(data=countries_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
        
        # flux_var grid
        geom_tile(data=flux_var_df, aes(x=x, y=y, fill=layer)) +
        
        # Coastline
        geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
        
        # Outline
        geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
        
        coord_equal() +
        
        scale_fill_gradient(low='#e3fdff', high='#00444a', limits=c(0, ceilingval)) +
                            # breaks=c(0, .25, .20),
        # #008894
        #
        guides(fill = guide_colorbar(nbin=10, raster=F,
                                     barheight = 4, barwidth=.5,
                                     frame.colour=c('black'), frame.linewidth=0.5,
                                     ticks.colour='black',  direction='vertical',
                                     title = 'Coefficient of\nvariation (%)')) +
        map_theme() +
        theme(	legend.position=  c(0.01, 0.55),
               plot.margin = unit(c(-2, -2, -2, 10), 'mm'))
    
    
    return(flux_robin_cv_map)
    }
