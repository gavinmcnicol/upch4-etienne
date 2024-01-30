# Description: make ensemble of GCP models compiled by Ben Poulter.
# This script produces 2 outputs:
#      1) Stack of rasters representing the pixel-wise mean of all models at each timestep.
#      2) Summary dataframe of total fluxes for each model and the ensemble.
# To do: Vectorize the loop to speed things up.
# Note: The units of the different models vary (see list at bottom of this script).
#------------------------------------------------------------------------------#

# get list of all the monthly ncdf files;  units: mg m-2 day-1
#p <- "../../../GCP_Stanford_Projects/data/gcp_model_ch4/gcp_ch4/"
p <- "../data/gcp_model_ch4/gcp_ch4/"
gcp_list <- list.files(path = p, pattern=".nc")

sink(paste0("gcp_model_printout.txt"))
# loop through model files
for (i in gcp_list){
  m<-nc_open(paste0(p, i))#, varname = "CH4_e", band = t)

  print(m)
  }
sink()


### Initiate output ------------------------------------------------------------

# make empty stack
gcp_ensemble_avg_stack <- stack()

# make empty dataframe
gcp_ch4_model_sum <- data.frame(model = character(),
                                date = character(),
                                flux = numeric(),
                                units = character(),
                                stringsAsFactors = F)

# convert to date format from character (because dates cannot be initialized without a specified length)
gcp_ch4_model_sum$date = as.Date(gcp_ch4_model_sum$date, "%Y-%m-%d")



# loop through sequence of months betwen 2000-2010 (incl. so 11 years)
m = 132
for (t in seq(1, m)){

  # create an empty temp stack to contain rasters of diff models for that month
  temp_stack <- stack()
  
  # loop through model files
  for (i in gcp_list){
    

    # read ch4 flux from NCDF as raster
    r <- raster(paste0(p, i), varname = "CH4_e", band = t)
    
    # multiply flux by grid cell area (in m^2 units)
    r <- r * area(r) *1e+6
    
    # Add raster to temporary stack (used for averaging.)
    temp_stack <- stack(temp_stack, r)
    
    ### get global sums --------------------------------------------------------
    # get the units of the ech4 variable
    units <- nc_open(paste0(p, i))$var$CH4_e$units

    gcp_ch4_model_sum <- bind_rows(gcp_ch4_model_sum, 
                                   list(model=i, 
                                        date=as.Date("2000-01-01") %m+% months(t-1),
                                        flux=sum_raster(r), 
                                        units=units))
    
  }
  
  # calculate model average for that month
  temp_stack_mean <- calc(temp_stack, fun = mean, na.rm = T)
  
  
  #  append to the mean raster to the output ensemble stack
  gcp_ensemble_avg_stack <- stack(gcp_ensemble_avg_stack, temp_stack_mean)
  
  gcp_ch4_model_sum <- bind_rows(gcp_ch4_model_sum, 
                                 list(model="ensemble", 
                                      date=as.Date("2000-01-01") %m+% months(t-1),
                                      flux=sum_raster(temp_stack_mean), 
                                      units="non.standard"))
  
  # print time ticker
  print(as.Date("2000-01-01") %m+% months(t-1))
  
}


### Save outputs   -------------------------------------------------------------

write.csv(gcp_ch4_model_sum, "../output/results/gcp_ch4_model_sum.csv")



### save the ensemble avg for each month
saveRDS(gcp_ensemble_avg_stack, paste0(p, "gcp_ch4_monthly_ensemble.rds"))



### Calculate the long-term average   ------------------------------------------

# average all monthly rasters
gcp_ensemble_2000_2010_avg <- calc(gcp_ensemble_avg_stack, fun = mean, na.rm = T)

# save to RDS files
saveRDS(gcp_ensemble_2000_2010_avg, paste0(p, "gcp_ensemble_2000_2010_avg_tgyr.rds"))


closeAllNcfiles()




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
