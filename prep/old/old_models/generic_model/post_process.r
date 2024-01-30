# /-----------------------------------------------------------------------------#
#/  Run post processing                            

# Change wd to dir of stack & where outputs are saved
setwd('../output/results/grids/v02')

# get rf output from all model
stack <- brick('generic_pred_flux_stack_v4.tif')

# Run post-processing
post_rf_processing(stack, 'gen')


# stack <- stack[[1:(24*2)]]
# summarize_stack_par(stack=stack, 
# 					nummodels=24, 
# 					summaryfcn=mean, 
# 					oufilename='test_mean_par.tif', 
# 					ncores=2)