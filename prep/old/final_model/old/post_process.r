# PARALLEL 
# # Get summary (min, mean, max) of RF models per timestep
# # https://www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-33-cluster/
# # https://stat.ethz.ch/pipermail/r-sig-geo/2013-November/019833.html

# /-----------------------------------------------------------------------------#
#/  Run post processing                            

# Change wd to dir of stack & where outputs are saved
setwd('../output/results/grids/v03')

# get rf output from all model; one file per ensemble member
fname = paste0('pred_v03_nmolm2sec_m', n_members, '_t', n_timesteps, '_b', n_bootstraps, '.tif')
stack <- brick(fname) 


#--------------------------------------------------------------------------------
# Make group label list; labels rasters from same timestep together
groupn = function(n,m){rep(1:m,rep(n/m,m))}

nlay <- length(names(stack))

# Make list of group labels
timestep_grp = groupn(nlay, nlay/n_bootstraps )

f = function(x){tapply(x, timestep_grp, summaryfcn)}



###############################################################################
# library(doParallel)  
# cl <- makeCluster(1, type='FORK', outfile='par_foreach_log_finalmodel.txt')  
# registerDoParallel(cl)
beginCluster(n_cores, type='SOCK')


# outstack <- stack()  # Make empty stack to initialize
summary_stats = c('mean', 'sd', 'var') # 'median', 'min', 'max', 'sd')

# NOTE: CHECK THE YEARS- MIGHT BE A MISMATCH BETWEEN FLUX & Fw
date_ls <- seq(as.Date('2001/1/15'), by = 'month', length.out = n_timesteps) #nlayers(stack))  # 216

print('starting summary stats loop')

#  COULDN'T GET THE clusterR inside dopar  to work...
for (s in 1:length(summary_stats)) { 

	# Get summary stat string
	summaryfcn = summary_stats[s]
	print(summaryfcn)

	# RUN SUMMARY CALC - PARALLELIZED 
	summary_nmolm2sec <- calc(stack, fun=f)

	# RENAME OUTPUT RASTERS
	names(summary_nmolm2sec) <- date_ls 

	# WRITE nmol OUTPUT 
	out_fname = paste0('pred_v03_nmolm2sec_em1_', summaryfcn, '.tif')
	writeRaster(summary_nmolm2sec,  filename=out_fname)


	# /---------------------------------------------------------------------#
	#/ Convert units for iLAMB (gC m-2 d-1 that are unscaled by wetland area)
	#  This unit conversion is simpler, and might run faster bc of built-in parallel of 'calc'
	#  https://www.r-bloggers.com/2019/01/are-you-parallelizing-your-raster-operations-you-should/

	nmolCH4m2sec.to.gCm2day <- function(x){ x *1e-9 *12.0107 *86400 }
	summary_gCm2day <- calc(summary_nmolm2sec, fun=nmolCH4m2sec.to.gCm2day)

	names(summary_gCm2day) <- date_ls

	# WRITE gC OUTPUT 
	out_fname = paste0('pred_v03_gCm2day_em1_', summaryfcn, '.tif')
	writeRaster(summary_gCm2day,  filename=out_fname)
	}

endCluster()
# parallel::stopCluster(cl)

#paste0(summaryfcn, '_', seq(1, nlayers(summary_nmolm2sec), 1))
# summary_nmolm2sec <- clusterR(stack, calc, args=list(fun=f), export=c('timestep_grp','summaryfcn'))
# foreach(s=1:length(summary_stats), .packages=c('raster'), .combine=stack, .init=outstack) %dopar% { 

# # THIS PARALLEL DOESNT WORK YET --- BUT CLOSE TO WORKING;  CURRENTLY NOT USED
# # CHECK EXPORT PART OF FUNCTION 
# # Get summary (min, mean, max) of RF models per timestep
# # https://www.gis-blog.com/increasing-the-speed-of-raster-processing-with-r-part-33-cluster/
# # https://stat.ethz.ch/pipermail/r-sig-geo/2013-November/019833.html
# summarize_stack_par <- function(stack, nummodels, summaryfcn, ncores){

# 	nlay <- length(names(stack))
# 	# Make list of group labels
# 	timestep_grp = groupn(nlay, nlay/nummodels )

# 	f = function(x){tapply(x, timestep_grp, summaryfcn, na.rm=TRUE)}

# 	beginCluster(ncores)
# 	summarizedstack <- clusterR(stack, calc, 
# 								args=list(fun=f), 
# 								export=c('timestep_grp','summaryfcn'))
# 	endCluster()

# 	return(summarizedstack)
# 	# writeRaster(summarizedstack, oufilename)  # paste0(modelname, '_min_unweighted_nmol.tif'))
# 	}
# # No need to  output all 100 iterations of every member for every month:
# # summarize mean, median, standard dev at 3 stages along the pipeline 
# # after applying wetland masks and the 2 unit conversions. 
# z02 <- summarize_stack_par(stack, nummodels=10, summaryfcn='mean', 1)

# #################################
# # summarized <- 
# # 	foreach(b=1:10, .packages=c('raster','ranger'), .combine=stack, .init=outstack) %dopar% { 
# timestep_grp = groupn(nlay, nlay/nummodels )

# beginCluster(1)
# f = function(x){tapply(x, timestep_grp, summaryfcn, na.rm=TRUE)}

# # Mean
# summaryfcn='mean'
# mean_nmolm2sec <- clusterR(stack, calc, args=list(fun=f), export=c('timestep_grp','summaryfcn'))

# endCluster()
# q1 <- calc(s, fun=function(x) quantile(x, .5, na.rm=TRUE))