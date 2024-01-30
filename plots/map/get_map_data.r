

com_ext <- extent(-180, 180,  -57, 85)



natearth_dir = '../data/nat_earth/'

# /-----------------------------------------------------------------------------
#/   PREP BOUNDING BOX
bbox <- readOGR(natearth_dir, 'ne_110m_wgs84_bounding_box') 
bbox <- crop(bbox, com_ext)  # Set smaller extent, excl. Antarctica
bbox_robin <- spTransform(bbox, CRS('+proj=robin'))  # reproject bounding box
bbox_robin_df <- fortify(bbox_robin)

# /-----------------------------------------------------------------------------
#/   LANDMASS OUTLINE                                       -----
# FIXED - SO THERE'S NO LINE STRETCHING BETWEEN ALASKA-KAMATCHAKA

library(rworldmap)
data(coastsCoarse)

crs(bbox) <- crs(coastsCoarse)
coastsCoarse <- gIntersection(coastsCoarse, bbox, byid = TRUE, drop_lower_td = TRUE)
coastsCoarse <- crop(coastsCoarse, com_ext)  # Set smaller extent, excl. Antarctica
coastsCoarse_robin <- spTransform(coastsCoarse, CRS('+proj=robin'))
coastsCoarse_robin <- as(coastsCoarse_robin, 'SpatialLinesDataFrame')
coastsCoarse_robin_df <- fortify(coastsCoarse_robin)



#/    Get country shapefiles                                       --------

# read and reproject countries  -  and ticks to  Robinson 
# natearth_dir <- '../data/nat_earth'
countries <- readOGR(dsn=natearth_dir, layer='ne_110m_admin_0_countries')
crs(countries) <- crs(bbox) # Harmonize the projections; no reason they should be different anyway
countries <- crop(countries, com_ext)  # Set smaller extent, excl. Antarctica
countries_robin <- spTransform(countries, CRS('+proj=robin'))
countries_robin <- as(countries_robin, 'SpatialPolygonsDataFrame')
countries_robin_df <- fortify(countries_robin)
