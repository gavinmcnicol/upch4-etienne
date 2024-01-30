# Description: make ensemble of GCP models compiled by Ben Poulter.
# This script produces 2 outputs:
#      1) Stack of rasters representing the pixel-wise mean of all models at each timestep.
#      2) Summary dataframe of total fluxes for each model and the ensemble.
# To do: Vectorize the loop to speed things up.
# Note: The units of the different models vary (see list at bottom of this script).
#------------------------------------------------------------------------------#

# get list of all the monthly ncdf files;  units: mg m-2 day-1
p <- "../data/gcp_model_ch4/gcp_ch4/"
gcp_list <- list.files(path = p, pattern=".nc")


# Misc functiton summing raster values
sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}


# /---------------------------------------------------------------------------#
#/ Initiate output                                               -------------

# make empty stack
gcp_ensemble_avg_stack <- stack()

# make empty dataframe
gcp_ch4_model_sum <- data.frame(model = character(),
                                date = character(),
                                flux = numeric(),
                                units = character(),
                                stringsAsFactors = FALSE)

# convert to date format from character (because dates cannot be initialized without a specified length)
gcp_ch4_model_sum$date = as.Date(gcp_ch4_model_sum$date, "%Y-%m-%d")


# /---------------------------------------------------------------------------
#/   Loop thru months ovr 2000-2017 (max index = 204)
# 2000 =121

for (t in 1:156) {

  # create an empty temp stack to contain rasters of diff models for that month
  temp_stack <- stack()
  

  # Loop through each model
  for (i in gcp_list){
    
    # print time ticker
    print(paste0(as.Date("2000-01-01") %m+% months(t-1), "  - ", i))


    # read ch4 flux from NCDF as raster
    r <- raster(paste0(p, i), varname = "CH4_e", band = t)

    # multiply flux by grid cell area (in m^2 units)
    r <- r * area(r) * 1e+6
    
    # convert  day to month
    # r <- r * 0.0328767

    # Convert g to Tg
    r <- r * 1.0E-12
    # By now the units should be  Tg month-1 pixel-1



    # Add raster to temporary stack (used for averaging.)
    temp_stack <- stack(temp_stack, r)

    # /-----------------------------------------------------------------------#
    #/  Get global sum of individual models Global sums 

    # get the units of the ech4 variable
    units <- nc_open(paste0(p, i))$var$CH4_e$units


    gcp_ch4_model_sum <- bind_rows(gcp_ch4_model_sum, 
                                   list(model=i, 
                                        date=as.Date("2000-01-01") %m+% months(t-1),
                                        flux=sum_raster(r), 
                                        units=units))
    
  	}

}

# /-------------------------------------------------------------------------#
#/    Save outputs 

write.csv(gcp_ch4_model_sum, "../output/results/gcp_ch4_model_sum_2000_2017.csv")


  
  
  # /-----------------------------------------------------------------------#
  #/  Calculate min, med, max of model ensemble
  
  # temp_stack_med <- calc(temp_stack,function(x){median(x, na.rm = T)})
  # temp_stack_min <- calc(temp_stack,function(x){min(x, na.rm = T)})
  # temp_stack_max <- calc(temp_stack,function(x){max(x, na.rm = T)})
  

 #  #  append to the mean raster to the output ensemble stack
 #  #gcp_ensemble_avg_stack <- stack(gcp_ensemble_avg_stack, temp_stack_med)
  

 #  gcp_ch4_model_sum <- bind_rows(gcp_ch4_model_sum, 
 #                                 list(model="med", 
 #                                      date=as.Date("2000-01-01") %m+% months(t-1),
 #                                      flux=sum_raster(temp_stack_med), 
 #                                      units="non.standard"),

 #                                list(model="min", 
 #                                      date=as.Date("2000-01-01") %m+% months(t-1),
 #                                      flux=sum_raster(temp_stack_min), 
 #                                      units="non.standard"),

 #                                list(model="max", 
 #                                      date=as.Date("2000-01-01") %m+% months(t-1),
 #                                      flux=sum_raster(temp_stack_max), 
 #                                      units="non.standard"),)
  



### save the ensemble avg for each month
# # Saving to RDS doesn't work well for large rasters.
# writeRaster(gcp_ensemble_avg_stack, '../output/results/grid/gcp_ensemble_avg_stack.nc', 
#             overwrite=TRUE, format="CDF", varname="upch4", varunit="nmolm2sec", 
#             longname="nmolm2sec -- raster stack to netCDF", 
#             xname="Longitude",   yname="Latitude", zname="Time (Month)")

# /-----------------------------------------------------------------------------------
#/  Calculate the long-term average  

# # average all monthly rasters
# gcp_ensemble_2000_2010_avg <- calc(gcp_ensemble_avg_stack, fun = mean, na.rm = T)

# # save to RDS files
# saveRDS(gcp_ensemble_2000_2010_avg, paste0(p, "gcp_ensemble_2000_2010_avg_tgyr.rds"))


#closeAllNcfiles()




### List of units listed in metadata of each model NCDF   ----------------------
#  all in gCH4 / m2 / month

# 1 = CLM4.5_final     : gCH4/month
# 2 = CTEM_final       : g CH4 / m2 / month
# 3 = DLEM_final       : gCH4/month
# 4 = JULES_final      : gCH4/month
# 5 = LPJ-MPI_final    : gCH4/mo
# 6 = LPJ-wsl_final    : g CH4 /m2 /month
# 7 = LPX-Bern_final   : gCH4/month/m2 grid cell
# 8 = ORCHIDEE         : g CH4/m2/month
# 9 = SDGVM_final      : g CH4 / month
# 10= TRIPLEX-GHG_fina : g CH4/month
# 11= VISIT_final      : g CH4/m2/month
