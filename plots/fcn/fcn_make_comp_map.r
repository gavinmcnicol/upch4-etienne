

map_comp_input <- function(x){
    
    source('plots/fcn/fcn_make_Saunois_scale.r')
    my_palette <- c(sequential_hcl(11, palette = "YlOrRd"), 'grey90')
    
    x <- WGSraster2dfROBIN(x)
    names(x)<- c('x','y','layer')
    x <- To.Saunois2020.Scale(x)
    
    #--------------------------------------------------------------------------------
    comp_input_map <- 
        ggplot() +
        
        # add background country polygons
        geom_polygon(data=countries_robin_df, aes(long, lat, group=group), fill='grey90') +
        
        # Flux grid
        geom_tile(data=x, aes(x=x, y=y, fill=layer_cut)) +
        
        # add outline of background countries
        geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='grey20', size=0.1) +
        
        # Add outline bounding box
        geom_path(data=bbox_robin_df, aes(long, lat, group=group), color="black", size=0.2) +
        
        scale_fill_manual(values = my_palette) +
        
        labs(fill='Wetland Flux\n(mgCH4 m^2 day^1)')  +
        coord_equal() +
        map_theme() +      
        theme(	legend.position= c(0.03, 0.5),
               plot.margin = unit(c(-2, -2, -2, 10), 'mm'))
    
    return(comp_input_map)
}
