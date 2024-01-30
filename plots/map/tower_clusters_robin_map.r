# Make CLUSTER MAP OVER WAD2M MAP 
# Carbon tracker - GCP models


# Get WAD2M AVERAGE GRID time-series
wad2m_ltavg <- raster('../../Chap3_holocene_global_wetland_loss/output/results/natwet/preswet/wad2m_Aw_mamax.tif')
# wad2m_ltavg <- stack('../../Chap3_holocene_global_wetland_loss/output/results/natwet/preswet/preswet_stack_max.tif')[[1]]
wad2m_ltavg <- wad2m_ltavg / area(wad2m_ltavg)
wad2m_ltavg[wad2m_ltavg<0.05] <- NA
plot(wad2m_ltavg)
# reformat rasters  for graph in ggplot
wad2m_ltavg_df <- WGSraster2dfROBIN(wad2m_ltavg)
names(wad2m_ltavg_df) <- c( 'x', 'y','layer')


# /----------------------------------------------------------------
#/   Get tower site clusters
clusters <- read.csv('../data/towercluster/cluster_bycluster.csv') %>% as_tibble()
clusters_coords <- cbind(clusters$Longitude, clusters$Latitude)
clusters_pts <- SpatialPointsDataFrame(clusters_coords, clusters)  ### Make spatial objects
crs(clusters_pts) = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'
clusters_pts_robin = spTransform(clusters_pts, CRS('+proj=robin'))
clusters_pts_robin_df = data.frame(clusters_pts_robin)


# /-----------------------------------------------------------------------------
#/ Make equator line 

library(sp)
eq <- Line(cbind(x=c(-180, 180), y=c(0,0)))
eql <- Lines(list(eq), ID='eq')
SPls <- SpatialLines(list(eql))
crs(SPls) =  CRS("+init=epsg:4326")
SPDF_robin <- spTransform(SPls, CRS("+proj=robin"))
SPDF_robin_df <- fortify(as(SPDF_robin, 'SpatialLinesDataFrame'))




# Color palette for inundation
my_palette <- c(sequential_hcl(6, palette = 'PuBu'), 'grey90')




# /-----------------------------------------------------------------------------
#/  Make map
cluster_robin_map <- 
    ggplot() +
    
    # Background countries; grey in-fill
    geom_polygon(data=countries_robin_df, aes(long, lat, group=group), color=NA, fill='grey95') +
    
    # Wetland grid
    geom_raster(data=wad2m_ltavg_df, aes(x=x, y=y, fill=layer*100)) +
    
    # Coastline
    geom_path(data=coastsCoarse_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    
    # Equator line
    geom_path(data=SPDF_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    
    # Tower cluster points
    geom_point(data=clusters_pts_robin_df, aes(x=coords.x1, y=coords.x2, size=percent*0.8, color=Class)) +
    geom_point(data=clusters_pts_robin_df, aes(x=coords.x1, y=coords.x2, size=percent), color='grey5', fill=NA, shape=21, stroke=0.25) +
    
    # Outline
    geom_path(data=bbox_robin_df, aes(long, lat, group=group), color='black', size=0.08) +
    
    coord_equal() +
    
    scale_fill_distiller(palette= 'PuBu', direction = 1, limits=c(0,100)) +
    scale_color_brewer(palette= 'Set1', direction = 1) +
    scale_size(range=c(.5, 6), breaks=c(1,5,15)) +
    
    guides(fill = guide_colorbar(#nrow=2, byrow=TRUE,
        nbin=8, #raster=F,
        show.limits = TRUE,
        barheight = 0.7, barwidth=10,
        breaks=c(0.05, 25, 50 ,75, 100),
        limits=c(0.05, 100),
        labels=c(0.05, 25, 50 ,75, 100),
        label=T,
        frame.colour=c('black'), frame.linewidth=0.7,
        ticks.colour='black',  direction='horizontal',
        title = expression(paste('Wetland fraction (%)')))) +
    
    map_theme() +
    
    # Add titles
    labs(title = 'Leave-One-Out Cross-Validation Cluster',
         subtitle = '(43 sites across 26 clusters)') +

    theme(legend.position=  'bottom',#c(0.01, 0.55),
          legend.direction = 'vertical',
           plot.margin = unit(c(-2, -2, -2, 10), 'mm'))

cluster_robin_map


# /-----------------------------------------------------------------------------
#/  Save map
# ggsave('../output/figures/map/tower_cluster_robin_map_v5.png',
#        cluster_robin_map,
#        width=180, height=120, dpi=500, units='mm')

ggsave('../output/figures/map/tower_cluster_robin_map_v6.pdf',
       cluster_robin_map,
       width=180, height=120, dpi=500, units='mm')
dev.off()






# guides(color=guides(color=guide_legend(nrow=2,byrow=TRUE))) +
# guides(size=guides(size=guide_legend(nrow=2,byrow=TRUE))) +

