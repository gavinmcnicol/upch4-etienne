
#==============================================================================#
### make raster sum function (shorten) -----------------------------------------
#==============================================================================#


sum_raster <- function(raster){sum(cellStats(raster, stat="sum"))}




upscaled_stack_tg_month <- readRDS('../../output/results/upscaled_stack_tg_permonth.rds')

# 
upscale_dates <- c(lapply(names(upscaled_stack_tg_month), function(x) parse_date_time(str_sub(x, -10, -1), 'ymd')))
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
area_0.5_m2 <- area(mch4e) * 10e+6


mch4e_tg_month <- mch4e * area_0.5_m2 / 10e+12




tg_month_total <- data.frame()

for (i in seq(1, length(names(upscaled_stack_tg_month)))){
  
  
  date = parse_date_time(str_sub(names(upscaled_stack_tg_month)[i], -10, -1),"ymd")
  
  row <- data.frame(t= date,
                    upscaled_tg_tot = sum_raster(upscaled_stack_tg_month[[i]]),
                    lpj_tg_tot = sum_raster(mch4e_tg_month[[i]]))
  
  tg_month_total <- rbind(tg_month_total, row)
  
}

library(tidyr)
tg_month_total <- tg_month_total %>% gather(source, value, upscaled_tg_tot:lpj_tg_tot)


ggplot(tg_month_total) +
  geom_line(aes(x=t, y=value, color=source)) + 
  custom_catch_trend_line_theme +
  theme(legend.position = "top") +
  #scale_color_distiller(palette = "RdBl")+
  xlab("") + ylab("Global monthly CH4 emission (Tg / month")



### save plot ------------------------------------------------------------------
ggsave("../../output/figures/global_tg_monthly_2010_2012.png",
       width=90, height=80, dpi=600, units='mm', type = "cairo-png")
