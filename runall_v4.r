# /---------------------------------------------------------------------------#
#/    Title:       CH4 Upscaling Run-all script
#     Description: Produces gridded upscaled flux from EC tower training.
#     Authors:     Etienne Fluet-Chouinard, Gavin McNichol, Zutao Yang
#     Institution: Stanford University, 2021


# /---------------------------------------------------------------------------#
#/     set R working directory on cluster                             ---------
# library(here);  here()
rm(list = ls(all.names = TRUE))
setwd('/home/groups/robertj2/upch4/scripts')
#  Load packages & misc functions
source('./prep/load_packages.r')
#  Post-processing function
source('./prep/fcn/fcn_post_rf_processing.r') 
# Get mapping theme
source("./plots/theme/theme_gif_map.r")
source("./plots/theme/line_plot_theme.r")
# Get ancillary map data - FIXED BBOX TEARING 
source("./plots/fcn/get_country_bbox_shp_for_ggplot_map.r")

# Get mapping theme
source('./plots/theme/theme_gif_map.r')
source('./plots/map/get_map_data.r')
source('./plots/fcn/fcn_get_towers.r')

# set global extent to plot (excluding antarctica)
com_ext <- extent(-180, 180, -56, 85)




# /---------------------------------------------------------------------------#
#/   FINAL-v2 RF MODEL w/ BOOTSTRAPING  -   May 2021               ----------
# 	 8 predictors,  2001-2018  (216 long)

#########################
# Final model config 
n_cores 	   = 15

start_members  = 1
n_members 	   = 1
m 			   = 1

start_timestep = 1
n_timesteps    = 216	# max=216

n_bootstraps   = 500	# max=500
#########################


#/ Unzip predictor folder -  Each members is up in predcitors > sep202 > 1.zip 
# zip names as 1-8
if(0){  source('./prep/final_v2_model/unzip_member.r')
		source('./prep/final_v2_model/sep_rf_models.r')  }

# Read Fw  (required in both next steps)
if(0){ 	source('./prep/final_v2_model/read_Fw.r')  }

#  Predict with RF model with Read pre-processed predictors
#  v3 has the global sum in each step
if(0){ 	source('./prep/final_v2_model/predict_grid_lowmempar_v3.r')  }


# Post processing
if(0){ 	source('./prep/final_v2_model/fcn_save_ncdf.r')
		# stack the bootstrap output, and save as ncdf
		source('./prep/final_v2_model/comb_bstrap_preds.r')   
		# Generates 3 more outputs; different units and scaled by wetland area
		source('./prep/final_v2_model/post_process_v2.r') }


# Calculate mean mg flux for map
		# Get mean variance per-pixel; for uncertainty map
if(0){ 	source('./plots/map/prep_upch4_mean_var_mgm2day.r') }
		# source('./plots/map/prep_upch4_var_mgm2day.r') }


# PLOT - map of mgCH4m2day - MASKED
if(0){
	# Function that plots avg fluxes
	source('./plots/fcn/fcn_map_flux_mg.r')
	# set output directory
	od = '../output/results/grids/v04/m1/for_map/'
	# Run mapping function; this was a functionbc of multiple members
	mg_map( flux= paste0(od, 'upch4_v04_m1_mgCH4m2day_Aw_mean_msk.tif'), 
			outfile= '../output/figures/v04/map/mean_mgCH4m2day_msk.png')  }

# TODO- make map of uncertainty in mgCH4 m-2 sec-1
# TODO- make 

# /---------------------------------------------------------------------#
#/   Comparison of UpCH4 to: GCP, CarbonTracker, WetCHARTS, Peltola

# Prep average grids; used in difference maps 
# Make average time-series of GCP models, WetCHARTS

if(0){	print('Prepping comparison data')
		# Gets tsavg and ltavg
		# source('./prep/comparison/gcp_models/gcp_avg_mgCH4m2day.r')  # 2001-20017
		# Gets tsavg and ltavg
		source('./prep/comparison/wetcharts/ltavg_wetcharts.r')  # 2001-2015
		source('./prep/comparison/carbontracker/ct_avg_map.r')	  # 2000-2010
		source('./prep/comparison/peltola/avg_peltola_grid_.r')  # DYTOP
		}


# Prep difference grids of avg flux
if(0){ 	source('./prep/comparison/prep_diff_grids.r')  }


# Make pearson map of r2 between 
if(1){ 	source('./prep/comparison/monthly_anomaly_r2.r')  }


# Make comparison maps of avg flux
if(0){ 	source('./plots/map/comp_input_maps.r')  # 2001-20017
		source('./plots/map/comp_diff_maps.r')  
		}



# Latitudinal heatmaps 
# Latitudinal lineplot




## TODO:  Needs fixing; as of May 7 2021
# if(0){  source('./plots/lineplot_total_timeseries_v2.r') }



### Difference maps

# upscaling -vs- GCP models
# upscaling to WetCharts
# Compare upscaling to Top-Down CarbonTrackers
# upscaling -vs- Peltola



# TODO:  
#		- Pass on the minute list and parse the time
# 		- Fix the index used to subset of MERRA vs looped for SWAMPS GLWD
#       - predict each model at a time, using clusterR# is that possible?
#		- Change range of color in map
#       - Add GCP model outputs from 
#       - Add Top-down global estimate to linplot
# 		- Add Latitudinal barblot on right of map.
# 		- Make legend a barplot (log axis?) per color bar.
# 		- Make annual sum overlay on a 3rd plot (or second axis).
# 		- Add GCP ensemble as ribbon.
# 		- Animation: Make monthly plot stacked for each year, shaded colors. 
# 					(even with ribbon?).
#		- Add annual total plot
# 		- Make anther stacked for wetland area.
# 		- Later: Use GIEMS as another map.