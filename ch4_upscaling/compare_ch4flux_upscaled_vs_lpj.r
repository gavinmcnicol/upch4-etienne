library(lubridate)
library(stringr)
library(ncdf4)

#### Get upscaled grid            ----------------------------------------------


#upscaled_flux <- readRDS('../../output/results/upscaled_stack_flux_g_m2_month.rds')
upscaled_flux <- readRDS('../../output/results/upscaled_stack_mmech4.rds')
#saveRDS(masked_flux_stack, '../../output/results/upscaled_stack_flux_g_m2_month.rds')


# aggregate to 0.5 deg to match LPJ resolution
upscaled_flux <- aggregate(upscaled_flux, fact=2, fun=mean, expand=TRUE, na.rm=TRUE)


# 
upscale_dates <- c(lapply(names(upscaled_flux), function(x) parse_date_time(str_sub(x, -10, -1), 'ymd')))
upscale_dates <- do.call("c", upscale_dates)






###  Get LPJ   data              -----------------------------------------------


# read the netcdf
d <- '../../data/lpj_mmch4e/LPJ_mmch4e_2000-2017_MERRA2.nc'
# varname: mch4e    
# var units: g CH4 /m2 /month     
# time: "months since 1860-1-1 00:00:00"

# open netcdf file
e <- nc_open(d)

# get lpj times
lpj_time <- parse_date_time("1860-1-1", "ymd")  %m+% months(e$dim$time$vals)

# read wet fraction as raster brick
# subset the lpj rasters to those matching upscaled
mch4e <-brick(d, varname="mch4e")[[which(lpj_time %in% upscale_dates)]]




###     Make gridded comparison       ------------------------------------------

# create an empty stack
comparison_stack <- stack()

for (t in seq(1, length(names(mch4e)))){
  
  print(t)
  comparison_stack <- stack(comparison_stack, mch4e[[t]] - upscaled_flux[[t]])

}
names(comparison_stack) <- upscale_dates

saveRDS(comparison_stack, '../../output/results/comparison_mmech4_upscaled_vs_lpj.rds')



###     Make total comparison            -----------------------------------------

sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}

pixarea <- area(mch4e)
crs(pixarea) <- crs(mch4e)


for (t in seq(1, length(names(mch4e)))){
  
  
  row <- data.frame(t=names(upscaled_flux[[1]]),
                    lpj = sum_raster(mch4e[[t]] * (pixarea * 10^6)) / 1e+12,
                    upscale=sum_raster(upscaled_flux[[t]] * (pixarea * 10^6)) / 1e+12 )
    

  comparison_stack <- stack(comparison_stack, mch4e[[t]] - upscaled_flux[[t]])
  
  
}
names(comparison_stack) <- upscale_dates


