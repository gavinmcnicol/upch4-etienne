# /---------------------------------------------------------------------------#
#/    Title:       CH4 Upscaling Run-all script
#     Description: Produces gridded upscaled flux from EC tower training.
#     Authors:     Etienne Fluet-Chouinard, Gavin McNichol, Zutao Yang
#     Institution: Stanford University, 2020

ptm <- proc.time()

# /---------------------------------------------------------------------------#
#/     set R working directory on cluster                                 -----
# library(here);  here()
rm(list = ls(all.names = TRUE))
setwd('/home/groups/robertj2/upch4/scripts')
source('./prep/load_packages.r')              #  Load packages & misc functions
source('./prep/fcn/fcn_post_rf_processing.r') #  Post-processing function
library(doParallel)  


# /---------------------------------------------------------------------------#
#/   FINAL RF MODEL w/ BOOTSTRAPING              -----
# 	 13 predictors,  2001-2015 (180 months)

n_cores 	   = 14

start_members  = 3
n_members 	   = 3

start_timestep = 1
n_timesteps    = 180	# max=180

n_bootstraps   = 500	# max=500



# /----------------------------------------------------------------------------#
#/ Unzip predictor folder                                            -----------
# Each members is up in predcitors > sep202 > 1.zip 
# zip names as 1-8
if(0){ source('./prep/final_model/unzip')
	   source('./prep/final_model/sep_rf_models.r')  }

#  Predict with RF model with Read pre-processed predictors

if(1){ 	source('./prep/final_model/read_Fw.r') 
		#  v3 has the global sum in each step
		source('./prep/final_model/predict_grid_lowmempar_v3.r')  }

# stack the bootstrap output, and save as ncdf
if(0){ source('./prep/final_model/comb_bstrap_preds.r')   }


# Post processing
if(0){  source('./prep/final_model/read_Fw.r')
		source('./prep/final_model/fcn_save_ncdf.r')
		#source('./prep/final_model/fcn_post_rf_processing.r')
		# source('./prep/final_model/post_process.r') 
		source('./prep/final_model/post_process_v2.r') 
		setwd('/home/groups/robertj2/upch4/scripts')  }

if(0){	source('./prep/final_model/create_output_ncdf') }



# /---------------------------------------------------------------------------#
#/   GENERIC MODEL  (2001 - 2018)

#/ Prepare predictors (only once)
if(0){  source('./prep/generic_model/prep_predictors.r')   }

# Predict random forest on grid with prepped predictors
if(0){  source('./prep/generic_model/read_agg_predictors.r')
		source('./prep/generic_model/predict_grid_v4.r')    }

# Run  post-processing (min, mean, max;  conv units;  global totals;  monthly composites)
if(0){  source('./prep/generic_model/post_process.r')  
		setwd('/home/groups/robertj2/upch4/scripts') }

if(0){  source('./plots/lineplot_total_timeseries.r') }

#/    Get sum of GCP model 
if(0){ 	source('./prep/make_gcp_ch4_ensemble.r') }


# /---------------------------------------------------------------------------#
#/   ALL MODEL   over:  2003-2013  (11 years, 132 months)             	  -----

# Prep all gridded predictors; only run once
# if(0){  source('./prep/all_model/prep_predictors.r')  }

#  Predict with RF model with Read pre-processed predictors
if(0){  source('./prep/all_model/read_agg_predictors.r')  
		source('./prep/all_model/predict_grid.r')   }

# Post processing (min, mean, max;  conv units;  global totals;  monthly composites)
if(0){  source('./prep/all_model/post_process.r') 
		setwd('/home/groups/robertj2/upch4/scripts')  }

if(0){ 	source('./create_output_ncdf') }




# /---------------------------------------------------------------------------#
#/  PLOT

if (0){
	source('./plots/fcn/fcn_map_flux_mg.r')

	#/ GET UNWEIGHTED AS MASK
	od = '../output/results/grids/v02/'

	mg_map( flux= paste0(od, 'gen_mean_weighted_mg_avg.tif'), 
			datmask= paste0(od, 'gen_mean_unweighted_nmol.tif'), 
			outfile= '../output/figures/gen_mean_ch4_mg.png') 

	mg_map( flux= paste0(od, 'all_mean_weighted_mg_avg.tif'), 
			datmask= paste0(od, 'all_mean_unweighted_nmol.tif'), 
			outfile= '../output/figures/all_mean_ch4_mg.png')
	}

### Difference maps

# Compare upscaling to Peltola

# Compre upscaling to WetCharts

# Compare upscaling to GCP models

# Compare upscaling to Top-Down CarbonTrackers



# /----------------------------------------------------------------------------#
#/    Plot GIF of predicted flux                                          ------
# source('./plots/plot_upscaled_flux.r')
if(0){  source('./plots/gif_map_flux_v3.r') }

#/         Compare upscaled grid to LPJ output (Tg / month))              ------
#source('./compare_ch4flux_upscaled_vs_lpj.r')





print(proc.time() - ptm)  # Stop the clock, print time elapsed


#registerDoMC(4)  #change the 2 to your number of CPU cores  
# print(paste0('N.cores detected: ', detectCores()))
# cl <- makeCluster(4)
# registerDoParallel(cl)
#registerDoParallel(cores=3)

# controls:
# indx_date_start = 240 + 1
# indx_date_end = 240 + 1 + 204

# stopCluster(cl)
# registerDoSEQ()
#on.exit(stopCluster(cl))


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