# /-----------------------------------------------------------------------------#
#/  Run post processing                            

# Change wd to dir of stack & where outputs are saved
setwd('../output/results/grids/v02')

# get rf output from all model
stack <- brick('all_pred_flux_025deg.tif') 

# Run post-processing
post_rf_processing(stack, 'all')

