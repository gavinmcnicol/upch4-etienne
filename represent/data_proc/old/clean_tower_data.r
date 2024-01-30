
# Get annual fluxes  per site (from Kyle - 27 May 2020)
towers_sum_flux <- read.csv('../data/towers/annual_sum.csv') %>%
				   dplyr::select(Site, Ann_Flux_mean, Year) %>%
				   group_by(Site) %>%
				   summarize(Ann_Flux_mean= mean(Ann_Flux_mean, na.rm=T)) %>%
				   ungroup() 


# /----------------------------------------------------------------
#/  Get wetland classification
towers_class <- read.csv('../data/towers/Full_data_table_200715.csv') %>%
				dplyr::select(SITE_ID, SITE_NAME, LAT, LON, Ann_Flux_g_CH4.C_m.2)

glimpse(towers_class)

# /----------------------------------------------------------------
#/ Read tower metadata  
towers_all <- read.csv('../data/towers/db_v2_site_metadata_Feb2020.csv')
towers_all$ID <-gsub("-", "", towers_all$ID)
towers_all$ID 

# Clean the tower data and pick out the main things we want from the dataset (All towers whether acquired or not)
towers_wet <- towers_all %>% 
				filter(IGBP %in% c("WET", 'WSA')) %>%  # , "CRO - Rice"
				filter(ID != "--*") %>%
				filter(ID != "--") %>%
				filter(ID != "--**") %>%
				filter(YR_START != "--") %>%
				filter(YR_END != "--") %>%
				filter(SALINITY != "SW") %>%
				
				# Count number of data years
				mutate(YR_END = ifelse(YR_END=="Present", 2019, YR_END)) %>%
				mutate(YR_END = as.numeric(YR_END), YR_START= as.numeric(YR_START)) %>%
				# Join the annual flux tables
				left_join(., towers_sum_flux, by=c('ID'='Site'))


# #===============================================================================

# # Get coordinates from the tower data
tower_coords <- cbind(towers_wet$LON, towers_wet$LAT)

# # Make spatial objects
cols2keep <- c('ID','SITE_NAME','LAT','LON','COUNTRY','Ann_Flux_mean')
towers_wet_pts <- SpatialPointsDataFrame(tower_coords, towers_wet[,cols2keep])







# towers_coords_df_all <- data.frame(towers_coords_all)
# # Extract pixel values at towers
# towers_coords_df_all <- cbind(towers_coords_df_all, raster::extract(bioclim_stack, towers_coords_all))
# # Get rid of any NA in the climatic variables
# # towers_coords_df_all <- na.omit(towers_coords_df_all) 