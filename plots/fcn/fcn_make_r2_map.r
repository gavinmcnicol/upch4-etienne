# Anomaly map function
anomaly_r2_map<- function(x, maxcap){
    
    # Apply mask
    x<- x %>% 
        mask(., low_flux_mask_1) %>% 
        WGSraster2dfROBIN(.) %>% 
        as_tibble()
    
    # Rename layer
    names(x) <- c('x','y','layer')
    
    x<- x %>%  mutate(layer=ifelse(layer>=maxcap, maxcap, layer))
    
    # Color palette replicating Saunois 2020
    my_palette <- sequential_hcl(10, palette = 'Purples')
    
    # Make map
    r2_map <- 
        
        ggplot() +
        # Background countries; 
        geom_polygon(data=countries_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
        
        # Flux grid
        geom_tile(data=x, aes(x=x, y=y, fill=layer)) +
        
        # Coastline
        geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
        
        # Map outline
        geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
        coord_equal() +
        
        scale_fill_gradient(low='#f7d9ff', high='#640080', limits=c(0, maxcap)) +
        #
        guides(fill = guide_colorbar(nbin=10, raster=F,
                                     barheight = 4, barwidth=.5,
                                     frame.colour=c('black'), frame.linewidth=0.5,
                                     ticks.colour='black',  direction='vertical',
                                     title = expression(paste("Pearson's R"^2)))) +
        
        ggtitle('') +
        map_theme() +
        theme(	legend.position=  c(0.01, 0.55),
               plot.margin = unit(c(-2, -2, -2, 10), 'mm'))
    
    
    return(r2_map)
}
