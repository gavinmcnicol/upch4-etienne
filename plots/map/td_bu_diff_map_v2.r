# Make CLUSTER MAP OVER WAD2M MAP 
# Carbon tracker - GCP models


# Get WAD2M AVERAGE GRID time-series for masking
wad2m_ltavg <- raster('../../Chap3_wetland_loss/output/results/natwet/preswet/wad2m_Aw_mamax.tif')
wad2m_ltavg_1 <- aggregate(wad2m_ltavg, fact=4, na.rm=TRUE, fun="mean")
# wad2m_ltavg <- stack('../../Chap3_holocene_global_wetland_loss/output/results/natwet/preswet/preswet_stack_max.tif')[[1]]
# wad2m_ltavg <- wad2m_ltavg / area(wad2m_ltavg)
# wad2m_ltavg[wad2m_ltavg<0.05] <- NA
# plot(wad2m_ltavg)
# reformat rasters  for graph in ggplot
# wad2m_ltavg_df <- WGSraster2dfROBIN(wad2m_ltavg)
# names(wad2m_ltavg_df) <- c( 'x', 'y','layer')




# /----------------------------------------------------------------
#/   Get tower site clusters
clusters <- read.csv('../data/towercluster/cluster_bycluster.csv') %>% as_tibble()
clusters_coords <- cbind(clusters$Longitude, clusters$Latitude)
clusters_pts <- SpatialPointsDataFrame(clusters_coords, clusters)  ### Make spatial objects
crs(clusters_pts) = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

clusters_pts_robin = spTransform(clusters_pts, CRS('+proj=robin'))
clusters_pts_robin_df = data.frame(clusters_pts_robin)




# /----------------------------------------------------------------
#/    Get GCP model ltavg
gcp_ltavg  <- raster("../output/comparison/gcp_models/avg/gcp_ltavg_mgCH4m2day_2010_2017.tif")
gcp_1 <- aggregate(gcp_ltavg, fact=2, na.rm=TRUE, fun="mean")
gcp_1 <- mask(gcp_1, wad2m_ltavg_1)
gcp_1 <- crop(gcp_1, extent(-180, 180, -56, 86))


# /----------------------------------------------------------------------------#
#/   Get TD inversion
td_1  <- raster("../output/comparison/inversions/td_ltavg_mgCH4m2day_2010_2017.tif")
td_1 <- mask(td_1, wad2m_ltavg_1)
td_1 <- crop(td_1, extent(-180, 180, -56, 86))


# /----------------------------------------------------------------------------#
#/   Calculate difference between BU and TD
gcp_td_diff_1 <- gcp_1 - td_1
gcp_td_diff_1 <- crop(gcp_td_diff_1, extent(-180, 180, -56, 86))


# /----------------------------------------------------------------------------#
#/   Make boxes of Siberia and HBL 
library(sp)
SI <- Polygon(cbind(x=c(59, 90, 90, 59, 59), y=c(56, 56, 74, 74, 56)))
HBL <- Polygon(cbind(x=c(-101, -79, -79, -101, -101), y=c(50, 50, 59, 59, 50)))

Pls <- Polygons(list(SI, HBL), ID='SI_HBL')
SPls <- SpatialPolygons(list(Pls))
crs(SPls) =  CRS("+init=epsg:4326")
SPDF_robin <- spTransform(SPls, CRS("+proj=robin"))
SPDF_robin_df <- fortify(as(SPDF_robin, 'SpatialPolygonsDataFrame'))



# /----------------------------------------------------------------------------#
#/    Make maps 
td1_diff_map  <- diff_map_function(gcp_td_diff_1, 'Bottom-Up - Top-down')
#Add boxes for Siberia & HBL to the map
td1_diff_map <- 
    td1_diff_map + 
    geom_path(data=SPDF_robin_df, aes(long, lat, group=group), color='black', size=0.3)


# Panel A - Mean flux map 
gcp_ltavg_robin_map <- make_saunois_mg_flux_map(gcp_1, 'GCP BU')
td_ltavg_robin_map <- make_saunois_mg_flux_map(td_1, 'GCP TD')



# /----------------------------------------------------------------------------#
#/   Combine panels and save to file

td_bu_diff_maps <- plot_grid(gcp_ltavg_robin_map, 
                             td_ltavg_robin_map,
                             td1_diff_map,
               ncol=1, 
               align='hv',
               labels = c('A','B','C'))



#/ Save to file
ggsave('../output/figures/diff_map/td_bu_diff_map_v56_3panels.pdf',
       td_bu_diff_maps,
       width=180, height=300, dpi=400, units='mm')

