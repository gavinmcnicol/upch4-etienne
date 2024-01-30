library(curl)
library(dplyr)
library(ggplot2)
library(here)
library(RcppCCTZ)
library(rgeos)
library(rgdal)
library(sp)
library(tidyr)
library(stringr)

library(tidyverse)


here()



### GEt list of images at coordinate     ---------------------------------------
sj = read.csv("../data/sj_delta_alos1p5.csv", stringsAsFactors = FALSE)

# clean up names
names(sj) <- gsub(x = names(sj), pattern = "\\.", replacement = "")

# get only numerics of granule
#sj$Granule <- substr(sj$GranuleName, 7, 16)


# reformat tablee
sj_poly <- bind_rows(
  sj %>% select(GranuleName, lon = "NearStartLon",lat = "NearStartLat"),
  sj %>% select(GranuleName, lon = "NearEndLon",  lat = "NearEndLat"),
  sj %>% select(GranuleName, lon = "FarEndLon",   lat = "FarEndLat"),
  sj %>% select(GranuleName, lon = "FarStartLon", lat = "FarStartLat")) #%>% mutate(Granule = as.numeric(Granule)) %>% arrange(Granule)


sj_poly$Granule <- substr(sj_poly$GranuleName, 7, 16)

# keep only
sj_poly <- sj_poly %>% select(Granule, lon,lat)


# sj %>% select(Granule, lon = "NearStartLon",lat = "NearStartLat")

# make a list
sj_list <- split(sj_poly, sj_poly$Granule)
# only want lon-lats in the list, not the names
sj_list <- lapply(sj_list, function(x) { x["Granule"] <- NULL; x })


ps <- lapply(sj_list, Polygon)


# add id variable
p1 <- lapply(seq_along(ps), function(i) Polygons(list(ps[[i]]), ID = names(sj_list)[i]))

# create SpatialPolygons object
scenepolys <- SpatialPolygons(p1, proj4string = CRS("+proj=longlat +datum=WGS84") ) 

# Extract polygon ID's
pid <- sapply(slot(scenepolys, "polygons"), function(x) slot(x, "ID"))

# Create dataframe with correct rownames
p.df <- data.frame( ID=1:length(p1), row.names = pid)

# Try coersion again and check class
p <- SpatialPolygonsDataFrame(scenepolys, p.df)

plot(my_spatial_polys)
plot(p)





### Download images from Granule         ---------------------------------------


#  curl "https://api.daac.asf.alaska.edu/services/search/param?point=-121.7,38.06&platform=ALOS&processingLevel=L1.5&output=csv" > sj_delta_alos1p5.csv


### 
# convert to date
sj$AcquisitionDate <- parseDatetime(sj$AcquisitionDate, fmt = "%Y-%m-%dT%H:%M:%E*S%Ez", tzstr = "UTC")

sj$month <-  format(sj$AcquisitionDate,'%m')


ggplot(sj) +
  geom_point(aes(x=AcquisitionDate, y=BeamMode, color=BeamMode), size=3, shape=21, stroke=2) +
  theme_bw() + #+   scale_x_date(date_breaks = "1 year", date_labels = "%y")
  theme(legend.position = "none")
  

### plot month coverage     ----------------------------------------------------




# plot stacked bars
ggplot(sj) +
  geom_bar(aes(x=month, y=..count.., fill=BeamMode)) + 
  theme_bw()


### save plot
ggsave("../output/figures/alos_passes_sjdelta.png",
       width=120, height=120, dpi=300, units='mm', type = "cairo-png")

dev.off()





### plot image bouding box  ---------------------------------------------------------------


# sj_long <- sj %>%
#            gather(, corner, "StartTime:FarEndLon")



sj2 <- bind_rows(
  sj %>% select(GranuleName, lon = "NearStartLon",lat = "NearStartLat"),
  sj %>% select(GranuleName, lon = "NearEndLon",  lat = "FarEndLat"),
  sj %>% select(GranuleName, lon = "FarStartLon", lat = "FarStartLat"),
  sj %>% select(GranuleName, lon = "FarEndLon",   lat = "FarEndLat"),
  sj %>% select(GranuleName, lon = "NearStartLon",lat = "NearStartLat")) %>%
  mutate(GranuleName = as.numeric(GranuleName)) %>%
  arrange(GranuleName)


ps <- lapply(sj2, Polygon)

# add id variable
p1 <- lapply(seq_along(ps), function(i) Polygons(list(ps[[i]]), 
                                                 ID = names(buildings_list)[i]  ))

# create SpatialPolygons object
my_spatial_polys <- SpatialPolygons(p1, proj4string = CRS("+proj=longlat +datum=WGS84") ) 
  
  


2### Make polygon from pts


ps <- lapply(buildings_list, Polygon)

# add id variable
p1 <- lapply(seq_along(ps), function(i) Polygons(list(ps[[i]]), 
                                                 ID = names(buildings_list)[i]  ))

# create SpatialPolygons object
my_spatial_polys <- SpatialPolygons(p1, proj4string = CRS("+proj=longlat +datum=WGS84") ) 




# "NearStartLat", "NearStartLon", 
# "FarStartLat", "FarStartLon",
# "NearEndLat", "NearEndLon", 
# "FarEndLat",  "FarEndLon"


i = 1


Ps1 = SpatialPolygons()
  
#[(x_min, y_min), (x_max, y_min), (x_max, y_max), (x_max, y_min), (x_min, y_min)]

coords = matrix(c(sj[i,"NearStartLon"], sj[i,"NearStartLat"],
                  sj[i,"NearEndLon"], sj[i,"NearEndLat"],
                  sj[i,"FarEndLon"], sj[i,"FarEndLat"],
                  sj[i,"FarStartLon"], sj[i,"FarStartLat"],
                  sj[i,"NearStartLon"], sj[i,"NearStartLat"]), 
                ncol = 2, byrow = TRUE)


ggplot(sj) +
  geom_polygon()


P1 = Polygon(coords)
Ps1 = SpatialPolygons(list(Polygons(list(P1), ID = "a")), proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
plot(Ps1, axes = TRUE)
