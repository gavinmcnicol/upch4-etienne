# /---------------------------------------------------------------------------#
#/    Title:       CH4 Upscaling Run-all script
#     Description: Produces gridded upscaled flux from EC tower training.
#     Authors:     Etienne Fluet-Chouinard & Gavin McNicol
#     Institution: Stanford University, 2019
rm(list = ls(all.names = TRUE))
ptm <- proc.time()  # Start the clock!

# /---------------------------------------------------------------------------#
#/     set R working directory on cluster                                 -----
# library(here)
# here()

setwd('/home/groups/robertj2/upch4/scripts')


# /---------------------------------------------------------------------------#
#/     Load packages & misc functions                                     -----
source("./gavin/load_packages.r")


# /---------------------------------------------------------------------------#
#/     Set up parallel env                                               -----

# /---------------------------------------------------------------------------#
#/    Unzip gridded predictors (only run once)                            -----

if(1==0){ source("./prep/unzip_predictor_grids.r") }
if(1==0){ source("./prep/get_avg_merra_for_nathaniel.r") }


# /---------------------------------------------------------------------------#
#/    Forward feature selection                         -----
#     THIS IS WHERE GAVIN'S CODE IS CALLED.
if(1==1){ source("./gavin/ffs_sherlock.r") }


# /---------------------------------------------------------------------------#
#/    Apply random forest to predictor grid                               -----


# MERRA2       1980-01-01 to 2016-12-31  (468 indices)
# SWAMPS-GLWD: 2000-01-01 to 2017-12-31  (216 indices)
# Indices of common period (MERRA indices) are:  241 to 444 (241+204)
if(1==0){ 

	#registerDoMC(4)  #change the 2 to your number of CPU cores  
	print(paste0("N.cores detected: ", detectCores()))
	cl <- makeCluster(4)
	registerDoParallel(cl)
	#registerDoParallel(cores=3)
	
	# controls:
	indx_date_start = 240 + 1
	indx_date_end = 240 + 1 + 204
	source("./prep/rf_predict_grid_v3.r")# , print.eval = 'echo')
	print(" - Predicted")

	stopCluster(cl)
	registerDoSEQ()
	#on.exit(stopCluster(cl))
	}

# TODO:  Pass on the minute list and parse the time
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


# THIS STILL DOESN'T WORK FOR MIN & MAX
if(1==0){ 
	source("./prep/sum_global_flux.r")
	print(" - Summed global flux")
	}


# /----------------------------------------------------------------------------#
#/    Get sum of GCP model ensemble                                             ------
if(1==0){
	print("Starting GCP ensemble")
	source("./prep/make_gcp_ch4_ensemble.r")
	print(" - Got GCP model sums")
	}

# /----------------------------------------------------------------------------#
#/    Plot GIF of predicted flux                                          ------
# source("./plots/plot_upscaled_flux.r")
if(1==0){ 
	source("./plots/gif_map_flux_v3.r")
	print( " - Plotted GIF; map & lineplot")
	}

# /---------------------------------------------------------------------------#
#/         Compare upscaled grid to LPJ output (Tg / month))             ------
#source("./compare_ch4flux_upscaled_vs_lpj.r")


# /---------------------------------------------------------------------------#
#/ Close multicluster
# stopCluster(cl)
# registerDoSEQ()
#on.exit(stopCluster(cl))

print(proc.time() - ptm)  # Stop the clock, print time elapsed