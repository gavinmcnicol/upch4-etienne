# FUNCTION THAT MAKES SAUNOIS FLUX MAP
# input: raster in WGS84 proj

make_saunois_mg_flux_map <- function(flux_mean, title_string) {
    
    # Make saunois color scale & legend
    source('plots/fcn/fcn_make_Saunois_scale.r')
    
    # reformat rasters  for graph in ggplot
    flux_mean_df <- WGSraster2dfROBIN(flux_mean)
    names(flux_mean_df) <- c( 'x', 'y','layer')
    
    flux_mean_df <- To.Saunois2020.Scale(flux_mean_df)
    
    # Color palette replicating Saunois 2020
    my_palette <- c(sequential_hcl(10, palette = 'YlOrRd'), 'grey90')
    
    # /------------------------------------------------------------------------#
    #/     Make map                                                      -------
    
    robin_flux_mean_map <- 
        ggplot() +
        
        # Background countries; grey in-fill
        geom_polygon(data=countries_robin_df, aes(long, lat, group=group), color=NA, fill='grey90') +  # 'grey95'
        
        # flux_mean grid
        geom_raster(data=flux_mean_df, aes(x=x, y=y, fill=layer_cut)) +
        
        # Coastline
        geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
        
        # Outline
        geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
        

        scale_fill_manual(values = my_palette, na.value=NA) + # 'grey95'
        coord_equal() +
        guides(fill = guide_legend(keyheight=.5, keywidth=0.7,
                                   barheight = 4, barwidth=.5,
                                   override.aes = list(size = 0.3),
                                   title = expression(paste("mg(CH"[4]*") m"^-2*" day"^-1)))) +
        map_theme() +
        ggtitle(title_string) +  # 
        theme(	legend.position=  c(0.01, 0.55),
               plot.margin = unit(c(-2, -2, -2, 10), 'mm'))
    
    return(robin_flux_mean_map)
    }
