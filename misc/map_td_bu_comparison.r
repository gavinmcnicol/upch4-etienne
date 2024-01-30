# map difference between Top down and bottom up
# compare annual fluxes (averaged over 2000-2010) as gCH4 yr-1z

###   Read the TEOW for masking                ---------------------------------
teow_raster <- readRDS("../output/results/teow_raster.rds")

#-------------------------------------------------------------------------------
#       Read in the CarbonTracker long term average                       ------
#       this is the grid average of monthly values over 2000-2010

# readin the decadal monthly average
td_lt_avg <- readRDS("../output/results/carbontracker_2000_2010_avg_TgCH4yr.rds")


#-------------------------------------------------------------------------------
#      read the GCP model ensemble                                        ------
#      original units: gCH4/month,  the aggregatd units are in Tg/year

# make directory where ensemble are
p <- "../../../GCP_Stanford_Projects/data/gcp_model_ch4/gcp_ch4/"

#bu <- readRDS(paste0(p, "gcp_ensemble_2000_2010_avg.rds"))
bu <- readRDS(paste0(p, "gcp_ensemble_2000_2010_avg_tgyr.rds"))

# calculate sum of all rasters in thee stack
#bu <- calc(bu, fun = mean, na.rm = T)

# aggregate to 1degree
bu <- aggregate(bu, fact=2, fun=sum, na.rm=T)

# convert to gCH4 year-1
bu <- bu * 12

# conver from g to Tg 
bu <- bu / 1e12



#-------------------------------------------------------------------------------
#     Calculate differences in TD & BU comparison                       --------


# mask out oceans deom both top-down and bottom-up grids
td_lt_avg[is.na(teow_raster)] <- NA
bu[is.na(teow_raster)] <- NA

# calculate RMSE between the two grids
diff = bu - td_lt_avg

# convert to df
diff_df <- as(diff, "SpatialPixelsDataFrame")
diff_df <- as.data.frame(diff_df)

# set breaks in color ramp
diff_df$layer_cut <- cut(diff_df$layer, c(-1.5, -0.75, -0.5, -0.25, -0.01, 0.01, 0.25, 0.5, 0.75, 1.5))




# replace the categories stings to make them nicer in the legend
# diff_df$layer_cut <- gsub("\\(|\\]", "", diff_df$layer_cut)
# diff_df$layer_cut <- gsub("\\,", " to ", diff_df$layer_cut)

#-------------------------------------------------------------------------------
#   save the grids as GeoTIFFs                                           -------


writeRaster(bu, '../output/results/rasters/bottomup/bottomup_gcpmodelensemble_2000_2010_tgyr.tif', options=c('TFW=YES'))

writeRaster(td_lt_avg,'../output/results/rasters/topdown/topdown_carbontracker_2000_2010_tgyr.tif',options=c('TFW=YES'))

writeRaster(diff, '../output/results/rasters/difference/difference_bu_minus_td_tgyr.tif',options=c('TFW=YES'))




#==============================================================================#
###    GET TOWER POINTS                                       -------

sites_updated <- read.csv("../data/tower_sites/Sites_all_BAMS_15march2019.csv")

# get coordinates
pts_coords <- cbind(sites_updated$LOCATION_LONG, sites_updated$LOCATION_LAT)

# make spatial object
sites_updated_pts <- SpatialPointsDataFrame(pts_coords, sites_updated)
sites_updated_pts_df <- data.frame(sites_updated_pts)

# set order of tower points
IGBPorderfromsara <- c('CRO - Other', 'CRO - Rice', 'DBF', 'EBF', 'ENF', 'GRA', 'MF', 'URB', 'WAT','WET')

# apply order to factors indf
sites_updated_pts_df$IGBP <- factor(sites_updated_pts_df$IGBP, levels=IGBPorderfromsara)

# recreate color map from Sara Knox 
sara_cmap <- c(rgb(230/255,138/255,0/255), 
               rgb(139/255, 208/255, 0/255), 
               rgb(223/255, 67/255, 0/255),
               rgb(255/255, 188/255, 174/255), 
               rgb(152/255, 17/255, 20/255), 
               rgb(255/255, 255/255, 29/255),
               rgb(231/255, 120/255, 159/255), 
               rgb(97/255, 3/255, 149/255), 
               rgb(35/255, 64/255, 153/255),
               rgb(37/255, 135/255, 108/255))


#------------------------------------------------------------------------------#
#     Make map of td-bu diff and towr points                         ------

# Get plotting theme
source('./plots/themes/map_raster_theme.r')


# make plot
ggplot() +
  
  # plot raster of td bu difference
  geom_raster(dat=diff_df, aes(x, y, fill=layer_cut))+ 
  
  # add color bar for td-bu difference
  scale_fill_brewer(palette = "RdBu", drop = FALSE, name=expression("Tg yr"^-1)) +
  
  # create new color scale, so points and grid can both be in the legend
  new_scale("fill") +
  
  # plot continent outline 
  geom_path(data=coastsCoarse_df, aes(long, lat, group=group), color="grey20", size=0.1) +
  
  
  # add equator & tropics lines 
  geom_line(aes(x=c(-180, 180), y=c(0, 0)),         size=0.1, color="grey60", na.rm = FALSE, show.legend = NA) +
  geom_line(aes(x=c(-180, 180), y=c(23.50, 23.5)),  size=0.1, color="grey60", na.rm = FALSE, show.legend = NA, linetype = "dashed") +
  geom_line(aes(x=c(-180, 180), y=c(-23.5, -23.5)), size=0.1, color="grey60", na.rm = FALSE, show.legend = NA, linetype = "dashed") +
  geom_line(aes(x=c(-180, 180), y=c(60, 60)), size=0.1, color="grey60", na.rm = FALSE, show.legend = NA, linetype = "dashed") +


  # plot sites we do not have data for yet
  geom_point(data=sites_updated_pts_df, 
             aes(x=LOCATION_LONG, y=LOCATION_LAT, fill=IGBP, shape=Data_acquired, size=Data_acquired), color="black", stroke=0.1) +
  
  # set scales
  scale_fill_manual(values= sara_cmap) +
  scale_size_manual(values= c(1.3, 1.8)) +
  scale_shape_manual(values= c(21, 24)) +
  scale_y_continuous(limits = c(-60,85)) +   # remove antartica
  
  
  labs(fill = "Wetland type") +
  guides(size = "none", shape = "none", fill="legend") +
  guides(fill=guide_legend(override.aes=list(shape=21))) +
  
  coord_equal() +
  theme_raster_map() +
  theme(legend.direction = "vertical", 
        legend.position = "bottom")#c(0.1,0.3)) 
 

# save figure as PDF (for manual updating in Illustrator) 
ggsave('../output/figures/map_td_bu_difference_v7.pdf', 
       width=140, height=90, dpi=800, units="mm", useDingbats=FALSE)
dev.off()

#guides(fill = guide_legend(nrow = 1))

