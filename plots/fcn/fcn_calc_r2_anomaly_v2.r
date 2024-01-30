# Remaining open Questions:
#  -  Need to remove NAs before 

# /------------------------------------------------------------#
#/ Detrend the UpCH4 measurements
# https://stackoverflow.com/questions/53054316/remove-linear-trend-from-raster-stack-r
# Get residuals to detrend the raw data

get_residuals <- function(x) {
    if (is.na(x[1])){ 
        rep(NA, length(x)) } 
    else {
        time <- 1:length(x)
        m <- lm(x~time) #, na.action=na.exclude)
        return(residuals(m))
    }
}

# Create our residual (detrended) time series stack
# time <- 1:nlayers(s1)
# s1_detrended <- raster::calc(s1, fun=get_residuals, progress='text')
# s2_detrended <- raster::calc(s2, fun=get_residuals, progress='text')


# /-----------------------------------------------------------------------#
#/ Per pixel, calculate R2
# https://matinbrandt.wordpress.com/2014/05/26/pixel-wise-regression-between-two-raster-time-series/
calc_raster_r2 <- function(x) { 
    if (is.na(x[1])) { NA } 
    else {
        time <- 1:(length(x)/2)
        m <- lm(x[time] ~ x[(time+max(time))]); return(summary(m)$r.squared)  # 
    }
}

# Calculated r2
# z <- stack(s1_detrended, s2_detrended)
# detrended_r2 <- calc(z, fun=calc_raster_r2)
# summary(detrended_r2)


# /-----------------------------------------------------------------------#
#/ 
detrended_r2_map <- function(s1, s2){
    
    # Create our residual (detrended) time series stack
    # time <- 1:nlayers(s1)
    s1_detrended <- calc(s1, fun=get_residuals, progress='text')
    s2_detrended <- calc(s2, fun=get_residuals, progress='text')
    print('detrended')
    
    
    # Calculated r2
    z <- stack(s1_detrended, s2_detrended)
    detrended_r2 <- calc(z, fun=calc_raster_r2)
    print('got pearsons r^2')
    
    return(detrended_r2)
}

