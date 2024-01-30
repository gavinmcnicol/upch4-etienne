# Description:  Get tower locations
#				In different projections



get.towers.wgs84 <- function(){

	towers <- read.csv('../data/towers/db_v2_site_metadata_Feb2020.csv')  %>% 
				    filter(IGBP %in% c('WET', 'WSA', 'CRO - Rice')) %>%
				    filter(!ID %in% c('--*','--','--**')) %>%
				    filter(YR_START != '--') %>%
				    filter(YR_END != '--')

	xy <- towers[,c(6,5)]   # get coordinates

	towers <- SpatialPointsDataFrame(coords = xy, data = towers)

	crs(towers) = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

	return(towers)
	}


get.towers.wgs84.df <- function(){
	towers    <- get.towers.wgs84()
	towers_df <- data.frame(towers)
	return(towers_df)
	}


# Function returning towers in Robin.proj  as data frame
get.towers.robin.df <- function(){
	towers <- get.towers.wgs84()
	towers_robin = spTransform(towers, CRS('+proj=robin'))
	towers_robin_df = data.frame(towers_robin)
	towers_robin_df
	}