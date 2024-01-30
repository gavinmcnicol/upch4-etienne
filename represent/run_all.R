# NOTES FROM CALL ON 27 MARCH 2020 --------------------------------------------- 
# global dissimilarity analysis / coverage
# Exclude drained wetlands?
# Kyle - include subset of sites? include upland? 
#      - Exclude sites with little seasonality?  Few data points

# Run on 1) all sites, 
#        2) only wetland sites, 
#        3) good data sites (selected by Kyle).
#        4) All CO2 towers in wetland (for expansion)


# TODOs items in my mind (these are not all necessary, so more of a wish list):
#   
#   Update the distance representativeness with A) database v2, and B) updated set of climatology grids, C) consider temporal data coverage/gaps when evaluating the climate-space sampled by the network.
# New component of representativeness with wetland types?
#   New componentof temporal coverage/representation (related to 1C)
# Expand to consider best new CO2 towers (first check how many CO2 towers are in wetlands)
# For Gavin's paper:  A) map error prediction as function of distance to network, B) make monthly representativeness

rm(list = ls(all.names = TRUE))

# library(here)
# here()
setwd('/home/groups/robertj2/upch4/scripts')

# import libraries
source('represent/import_libraries.r')
source('represent/plots/tower_color_ls.r')
source('represent/plots/themes/line_plot_theme.r')
source('represent/plots/themes/map_theme.r')

source('./prep/load_packages.r') 
# Get mapping theme
source('./plots/theme/theme_gif_map.r')


source('./plots/get_map_data.r')
source('./plots/fcn/fcn_get_towers.r')
options(stringsAsFactors = F)
library(ggnewscale)

#/     Get tower locations                                               -------
towers_robin <- get.towers.robin.df()


# /-----------------------------------------------------------------------------
#/  Get data

# Get wetland grid
source('represent/data_proc/get_wet_grid.r')

# Clean the tower data so that it is usable
source('./represent/data_proc/clean_tower_data_v2.r')

# Read the climatic variables and the tower data and extract the climatic variables
# from the location of the tower site
if(0) {	source('represent/data_proc/prep_vars_v3.r')  }
source('represent/data_proc/get_all_vars_v2.r')


# /-----------------------------------------------------------------------------
#/   PCA
source('represent/plots/pca/global_pca_v2.r')


# /----------------------------------------------------------------------------#
#/  eucledian distance on climatic variables
source('represent/data_proc/calc_dist.r')
#  ADD HEATMAP OF THE DISTANCE MATRIX

# MAP Distance
source('represent/plots/dist_map/dist_map_v2.r')
# source('represent/plots/tower_dist_map.r')

# # K-means clustering
# source('represent/data_proc/calc_kmeans.r')
# source('represent/data_proc/ks_test.r')






















# Do tower specific analyses
# Tower to tower analyses specifcally against towers where methane flux data have not been acquired
# yet, used for indication of optimal towers that should be added to the methane flux network
# MDS plot indication shows all the towers and which ones we have acquired or not, also gives us a visual
# of which clusters of towers would be beneficial to the network
# source('./scripts/plots/tower_nmds.r')
# source('./scripts/plots/plot_nmds.r')


# Plot our analysis of the representativeness analyses
# All plots will be automatically saved when this script is running
# Plots will be saved in /SESUR/Outputs
# source('./scripts/plots/plot.r')

# # Plot the number of towers in the network over time
# source('./scripts/tower_count_yearly.r')