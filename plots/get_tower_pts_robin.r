# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------

bams_towers <- 
	read.csv("../data/towers/db_v2_site_metadata_Feb2020.csv")  %>% 
	filter(IGBP %in% c("WET", 'WSA', "CRO - Rice")) %>%
	filter(ID != "--*") %>%
	filter(ID != "--") %>%
	filter(ID != "--**") %>%
	filter(YR_START != "--") %>%
	filter(YR_END != "--")


xy <- bams_towers[,c(6,5)]   # creat coordinates
bams_towers <- SpatialPointsDataFrame(coords = xy, data = bams_towers)

geo_proj = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
crs(bams_towers) = geo_proj

bams_towers_robin = spTransform(bams_towers, CRS("+proj=robin"))
bams_towers_robin = data.frame(bams_towers_robin)

