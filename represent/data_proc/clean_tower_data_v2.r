# /----------------------------------------------------------------
#/  Get wetland classification
# towers_wet <- read.csv('../data/towers/Full_data_table_200715.csv') %>%
# towers_wet <- read.csv('../data/towers/Full_data_table_200715_updated.csv') %>%
towers_wet <- read.csv('../data/towers/Table B2_Final_metadata_file.csv') %>%
		  	  dplyr::select(SITE_ID, SITE_NAME, LAT, LON, SITE_CLASSIFICATION, Ann_Flux_g_CH4.C_m.2) %>%
		  	  dplyr::filter(SITE_CLASSIFICATION %in% c('Swamp', 'Bog', 'Fen', 'Wet tundra', 'Marsh'))

# Remove towers that were excluded from database v2ß
### OCTOBER 2020 - FILTER OUT   RU-Sam and SE-Sto
### NOVEMBER 2020 - FILTER OUT  RU-VRK and SE-ST1
towers_wet <- 	towers_wet %>% dplyr::filter(!SITE_ID %in% c('RUSAM', 'SESTO', 'SE-St1', 'RU-Vrk', ''))


glimpse(towers_wet)
unique(towers_wet$SITE_ID)


# /----------------------------------------------------------------
#/  Get coordinates from the tower data
tower_coords <- cbind(towers_wet$LON, towers_wet$LAT)

### Make spatial objects
towers_wet_pts <- SpatialPointsDataFrame(tower_coords, towers_wet)
crs(towers_wet_pts) = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'


towers_robin = spTransform(towers_wet_pts, CRS('+proj=robin'))
towers_robin_df = data.frame(towers_robin)
