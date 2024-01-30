# Remaining open Questions:
#  -  Need to remove NAs before? convert all to zeroes?

# /------------------------------------------------------------#
#/ Detrend the UpCH4 measurements

# get_residuals <- function(x) { if (is.na(x[1])){ rep(NA, length(x)) } else { predict( m<-lm(x ~ time)); residuals(m) }}
# get_residuals <- function(x) { if (is.na(x[1])){ rep(NA, length(x)) } else { m<-lm(x ~ time); residuals(m) }}
get_residuals <- function(x) {  m<-lm(x ~ time); residuals(m) }


# /-----------------------------------------------------------------------#
#/ Per pixel, calculate R2


calc_raster_r2 <- function(x) {
    # if 1st value is NA, return NA
    if (is.na(x[1])) { NA }  # { rep(NA, length(x)) } 
    else {
        # Time is half the stack; bc two ts are stacked
        time <- 1:(length(x)/2)
        # Model between paired data; offset by time step
        m <- lm(x[time] ~ x[(time+max(time))]); return(summary(m)$r.squared) }}



# /-----------------------------------------------------------------------#
#/ Run detrending
detrended_r2_map <- function(s1, s2){
    
    # tic()
    # beginCluster(10)
    time <- 1:nlayers(s1)
    # Create our residual (detrended) time series stack
    s1_detrended <- clusterR(s1, calc, args=list(fun=get_residuals), export='time')
    s2_detrended <- clusterR(s2, calc, args=list(fun=get_residuals), export='time')
    print('Detrended')
    
    # Calculated r2
    z <- stack(s1_detrended, s2_detrended)
    detrended_r2 <- clusterR(z, calc, args=list(fun=calc_raster_r2), export='time')
    print('Calc pearsons r^2')
    # toc()
    # endCluster()
    
    return(detrended_r2)
}



# beginCluster(5)
# r2 <- detrended_r2_map(upch4_1[[1:12]], gcp_1[[1:12]])
# r2 <- detrended_r2_map(s1=upch4_1[[1:24]] , s2= gcp_1[[1:24]])

# # /-----------------------------------------------------------------------#
# #/  Calculate R2 from detrended data
# detrended_r2_map <- function(s1, s2){
#     
#     # Create our residual (detrended) time series stack
#     time <- 1:nlayers(s1)
#     beginCluster(6)
#     s1_detrended <- calc(s1, fun=get_residuals, progress='text')
#     s2_detrended <- calc(s2, fun=get_residuals, progress='text')
#     print('Detrended')
#     
#     # Calculated r2
#     z <- stack(s1_detrended, s2_detrended)
#     detrended_r2 <- calc(z, fun=calc_raster_r2, progress='text')
#     print('Calc pearsons r^2')
#     endCluster()
#     return(detrended_r2)
# }

# https://stackoverflow.com/questions/53054316/remove-linear-trend-from-raster-stack-r
# https://gis.stackexchange.com/questions/171027/r-raster-predict-using-lm-time-series
# https://matinbrandt.wordpress.com/2014/05/26/pixel-wise-regression-between-two-raster-time-series/

