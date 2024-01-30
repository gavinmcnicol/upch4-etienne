

### get country shpfiles =======================================================


# read and reproject countries  -  and ticks to  Robinson 
natearth_dir <- "../../chap5_global_inland_fish_catch/data/gis/nat_earth"
countries <- readOGR(natearth_dir, "ne_110m_admin_0_countries")
countries_df <- fortify(countries)
countries_robin <- spTransform(countries, CRS("+proj=robin"))
countries_wgs84_df <- fortify(countries)


# # read and reproject outside box
# bbox <- readOGR(natearth_dir, "ne_110m_wgs84_bounding_box") 
# bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
# bbox_robin_df <- fortify(bbox_robin)
# bbox_wgs84_df <- fortify(bbox)