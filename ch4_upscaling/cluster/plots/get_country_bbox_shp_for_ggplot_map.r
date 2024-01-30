
# /----------------------------------------------------------------------#
#/    Get country shapepfiles                                       --------


# read and reproject countries  -  and ticks to  Robinson 
natearth_dir <- "../data/nat_earth"
countries <- readOGR(dsn=natearth_dir, layer="ne_110m_admin_0_countries")
countries_df <- fortify(countries)


### Country outlines in Robinson projection 
#countries_robin <- spTransform(countries, CRS("+proj=robin"))
#countries_robin_df <- fortify(countries_robin)


### Read and reproject outside box
# bbox <- readOGR(natearth_dir, "ne_110m_wgs84_bounding_box") 
# bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
# bbox_robin_df <- fortify(bbox_robin)
# bbox_wgs84_df <- fortify(bbox)