
# rm(list = ls(all.names = TRUE))
#  Load packages & misc functions
library(here); here()
source('./prep/load_packages.r')
#  Post-processing function
source('./prep/fcn/fcn_post_rf_processing.r')

# Get ancillary map data - FIXED BBOX TEARING 
source("./plots/fcn/get_country_bbox_shp_for_ggplot_map.r")

# /-------------------------------------------------------------------------
#/ Get mapping theme
source('./plots/theme/theme_gif_map.r')
source('./plots/theme/line_plot_theme.r')
source('./plots/theme/heatmap_theme.r')
source('./plots/map/get_map_data.r')
source('./plots/fcn/fcn_get_towers.r')

# /----------------------------------------------------------------
#/  FUNCTIONS
# get function that makes Saunois map
source('plots/fcn/fcn_make_saunois_mg_map.r')
# Fcn makes map of variability 
source('plots/fcn/fcn_make_var_mg_map.r')

source('plots/fcn/fcn_make_flux_heatmap.r')  # On latitude
source('plots/fcn/fcn_make_flux_heatmap_sinelat.r')  # On sinus of latitude

source('plots/fcn/fcn_make_comp_map.r') # needed? or use same as saunois map?
# Difference map + to -
source('plots/fcn/fcn_make_diff_map.r')
# R^2 of anomalies
source('plots/fcn/fcn_make_r2_map.r')

# set global extent to plot (excluding Antarctica)
com_ext <- extent(-180, 180, -56, 85)

# set output directory
od = '../output/for_map/'


# /----------------------------------------------------------------------------#
#/   INPUTS FOR COMPARISON                                                 -----

# Read input grids for comparison
source('prep/comparison/prep_diff_grids.r')

# Make maps of comparison datasets
# Not used in multipanel; used for SI figure of upscaling maps??
source('plots/map/comp_input_maps_v2.r')  

# Calculate anomaly r2
source('prep/comparison/monthly_anomaly_r2.r')

# /----------------------------------------------------------------------------#
#/   Fig.S13 -  Diff map WAD2M-GIEMS fluxes  - for SI                     ------
source('plots/map/upch4_wad2m_giems2_diff_map_multipanel.r')


# /----------------------------------------------------------------------------#
#/  for FIG.1    Diff map GCP-CT                                          ------
# source('plots/map/td_bu_diff_map.r')
# Updated figure with new panels for BU and TD
source('plots/map/td_bu_diff_map_v2.r')


# /----------------------------------------------------------------------------#
#/  for FIG.2    Tower clusters map                                       ------
#                plotted over WAD2M inundation
source('plots/map/tower_clusters_robin_map.r')


# /----------------------------------------------------------------------------#
#/    WAD2M upscaling benchmark multipanel                            ------
#    Note: Needs prep diff
source('plots/wad2m_map_multipanel.r')


# /----------------------------------------------------------------------------#
#/    Make GIEMS2 benchmark multipanel plot                              --------
source('plots/giems2_map_multipanel.r')


# /----------------------------------------------------------------------------#
#/    Make heatmap multipanel (lat heatmap + lat lineplot)                 --------
#    Includes WAD2M & GIEMS2 upscaling, so no need for a separate script
# Fig 7
source('plots/heatmap/lat_heatmap.r')


# /----------------------------------------------------------------------------#
#/    Fig.S15 - latitudinal lineplot for all inputs
source('plots/lineplot/lat_tgyr_plotline.r')




# /----------------------------------------------------------------------------#
#/   Latitudinal line plot                                           --------
# NO LONGER NEEDED BC GAVIN IS MAKING IT NOW
# source('plots/lineplot/lat_tgyr_plotline.r')




# source('plots/heatmap/heatmap_multipanel.r')


