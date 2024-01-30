# /---------------------------------------------------------------------------#
#/      Read data                                               -------

# read the predicted ncdfs
med_conv <- brick('../output/results/grid/upch4_med_nmolm2sec.nc')
max_conv <- brick('../output/results/grid/upch4_max_nmolm2sec.nc')
min_conv <- brick('../output/results/grid/upch4_min_nmolm2sec.nc')


# Get date list
parseddates <- readRDS('../output/results/parsed_dates.rds')


# /---------------------------------------------------------------------------#
#/      Make raster sum                                                -------

# Get function
source("./prep/fcn/fcn_sum_flux_grid.r")

# Apply function
med_sum <- sum_stack(med_conv, parseddates)
min_sum <- sum_stack(min_conv, parseddates)
max_sum <- sum_stack(max_conv, parseddates)

# Add labels
med_sum$valtype <- "med"
min_sum$valtype <- "min"
max_sum$valtype <- "max"

# Combine to single df
sum_df <- bind_rows(med_sum, min_sum, max_sum)

# Save to CSV file
write.csv(sum_df, "../output/results/upscaled_sum.csv")
