# Latitudinal lineplot

# get function that preps data for latlineplot
source('plots/fcn/fcn_prep_upch4_for_latlineplot.r')

# /----------------------------------------------------------------------------#
#/   Get monthly WAD2M-upscaled TgCH4 grids
upch4_tg_mean_wad2m <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw.nc', varname='mean_ch4')
upch4_tg_sd_wad2m <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw.nc', varname='sd_ch4')


upch4_wad2m_tg_df <- prep_upch4_for_latlineplot(upch4_tg_mean_wad2m, upch4_tg_sd_wad2m)


# /----------------------------------------------------------------------------#
#/   Get upscaling GIEMS monthly TgCH4 grids
upch4_tg_mean_giems2 <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw_giems2.nc', varname='mean_ch4')
upch4_tg_sd_giems2 <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw_giems2.nc', varname='sd_ch4')


# Preprocess these data
upch4_giems2_tg_df <- prep_upch4_for_latlineplot(upch4_tg_mean_giems2, upch4_tg_sd_giems2)




# /----------------------------------------------------------------------------#
#/   Get range of Bottom-up GCP models

# # gcp_lat_tgyear <- read.csv('../output/comparison/gcp_models/avg_gcp_Tgmonth_per1deglat.csv') %>% 
# gcp_lat_tgyear <- read.csv('../output/comparison/gcp_models/gcp_Tgmonth_sepmodels_per1deglat.csv') %>% as_tibble() 

# Make output df
gcp_lat_tgyear <- data.frame(lat_rnd= seq(-60, 80, 1))

# Get list of models; gCH4/m2/month
models <- list.files('../output/comparison/gcp_models/models', full.names=T, pattern = "swamps")

# loop through GCP models
for (m in models){
    
    print(m)
    
    # calculate average fluxes over time-series
    m_r <- stack(m)
    m_r <- raster::calc(m_r, mean, na.rm=T)
    
    # Multiply by m^2 area of entire pixel, bc that's how flux density are calculated in GCP models
    m_r_tgyr <- m_r * (area(m_r) * 10^6) * 10^-12 * 12
    
    # Calculate per 1degree bin
    m_r_tgyr_df <- as.data.frame(m_r_tgyr, xy=TRUE, na.rm=T)
    
    m_r_tgyr_df <- m_r_tgyr_df %>%
        # write model label in df
        # rename(m = model) %>% 
        # round latitude
        mutate(lat_rnd = round(y, 0)) %>% 
        dplyr::select(-x, -y) %>% 
        # Get yearly average emissions
        # mutate(upch4_sd_tgyear = mean(c_across(starts_with(X))) *12, na.rm=T) %>% 
        group_by(lat_rnd) %>%
        # Get sum of each column
        summarise_at(c('layer'), .funs=sum) # , na.rm=T
    
    # append to same df
    gcp_lat_tgyear <- left_join(gcp_lat_tgyear, m_r_tgyr_df, by='lat_rnd')
    
}


# Get the mean, min, max of models per 1deg bin
gcp_lat_tgyear_rng <- 
    gcp_lat_tgyear %>% 
    group_by(lat_rnd) %>%
    pivot_longer(starts_with("layer"), names_to='models', values_to='tgyr') %>% 
    dplyr::select(-models) %>% 
    # summarize_at(vars(-group_cols()), .funs=c('min', 'mean', 'max'), na.rm=T) %>%
    summarize_at(vars(-group_cols()), .funs=c('mean', 'sd'), na.rm=T) %>%
    as_tibble()



# /----------------------------------------------------------------------------#
#/   WetCHARTS v1                                               -------

#   Get Carbon Tracker full stack   -  Units mg m-2 day-1
wc_1 <- stack('../output/comparison/wetcharts/wc_ee_tsavg.tif')#[[1:4]]  # these are all identical WTF

# Convert to Tg month
beginCluster(6)

# Calculate pixel area
pixarea <- area(wc_1[[1]]) 

# convert to Tg per month 
wc_11  <- overlay(wc_1, pixarea, fun=function(x,y){(x*y*0.00000003 *12)} )

endCluster()


# wc_ltavg <- raster('../output/comparison/wetcharts/wc_ee_ltavg.tif')

# Average of annual
beginCluster(6)
wc_11_tg <- clusterR(wc_11, calc, args=list(fun=mean))
endCluster()

# Calculate per 1degree bin
wc_11_tg_df <- as.data.frame(wc_11_tg, xy=TRUE, na.rm=TRUE)

# Get the mean, min, max of models per 1deg bin
wc_11_tg_df <- 
    wc_11_tg_df %>% 
    rename(wc_tgyr = layer) %>% 
    # round latitude
    mutate(lat_rnd = y) %>% 
    # mutate(lat_rnd = round(y, 0)) %>% 
    dplyr::select(-x, -y) %>% 
    group_by(lat_rnd) %>%
    summarise_at(c('wc_tgyr'), .funs=sum, na.rm=T) %>% 
    as_tibble()



# /----------------------------------------------------------------------------#
#/   Prep top down inversions
#  TO-DO prep inversions range...

td <- raster('../output/comparison/inversions/td_ltavg_mgCH4m2day_2010_2017.tif')

# Convert to annual Tg
td <- td * (area(td) *10^6)  *10^-15 * 365

# Calculate per 1degree bin
td_df <- as.data.frame(td, xy=TRUE, na.rm=TRUE)

# Get the mean, min, max of models per 1deg bin
td_df <- 
    td_df %>% 
    rename(td_tgyr = layer) %>% 
    # round latitude
    mutate(lat_rnd = y) %>% 
    # mutate(lat_rnd = round(y, 0)) %>% 
    dplyr::select(-x, -y) %>% 
    group_by(lat_rnd) %>%
    summarise_at(c('td_tgyr'), .funs=sum, na.rm=T) %>% 
    as_tibble()



# /----------------------------------------------------------------------------#
#/    Assemble into single df - cause the scale manual trick is FUCKED!

# gcp_lat_tgyear_rng$model <- 'GCP models'
# upch4_giems2_tg_df$model
# upch4_wad2m_tg_df
# ct_df$

# df_tg_perlat_forplot <- bind_rows()


# /----------------------------------------------------------------------------#
#/     Make latitudinal lineplot
ggplot() +
    
    # GCP models; min/max
    # geom_ribbon(data= gcp_lat_tgyear_rng, aes(x=lat_rnd, ymin=min, ymax=max), fill='red', alpha=0.2) +
    # geom_line(data= gcp_lat_tgyear_rng, aes(x=lat_rnd, y=mean, color='red'), alpha=0.5, size=0.25) +
    
    # GCP models; SD
    geom_ribbon(data= gcp_lat_tgyear_rng, aes(x=lat_rnd, ymin=mean-sd, ymax=mean+sd), fill='grey65', alpha=.15) +
    geom_line(data= gcp_lat_tgyear_rng, aes(x=lat_rnd, y=mean, color='Bottom-up ensemble'), alpha=1, size=.2) +
    
    # # # Carbon Tracker
    geom_line(data= td_df, aes(x=lat_rnd, y=td_tgyr, color='Top-down ensemble'), size=0.2) +
    # 
    # # WetCharts
    # geom_line(data= wc_11_tg_df, aes(x=lat_rnd, y=wc_tgyr, color='WetCharts'), size=0.2) +
    
    # WAD2M upscaling
    geom_ribbon(data= upch4_wad2m_tg_df, aes(x=lat_rnd, ymin=upch4_lo_tgyear, ymax=upch4_hi_tgyear), fill='red', alpha=0.1) +
    geom_line(data= upch4_wad2m_tg_df, aes(x=lat_rnd, y=upch4_mean_tgyear, color='WAD2M upscaling'), size=0.2) +
    
    # GIEMS2 upscaling
    geom_ribbon(data= upch4_giems2_tg_df, aes(x=lat_rnd, ymin=upch4_lo_tgyear, ymax=upch4_hi_tgyear), fill='blue', alpha=0.1) +
    geom_line(data= upch4_giems2_tg_df, aes(x=lat_rnd, y=upch4_mean_tgyear, color='GIEMS2 upscaling'), size=0.2) +
    
    xlab('Latitude') +
    ylab(expression(paste('Wetland emissions (', TgCH[4]~~'degree'^-1~~year^-1*')'))) +
    scale_x_continuous(expand=c(0,0), limits=c(-50, 80), breaks=seq(-50, 80, 10)) + 
    scale_y_continuous(expand=c(0,0), breaks=seq(0, 12, 2)) + 
    

    scale_color_manual(name='models',
                       breaks = c('Bottom-up ensemble', 'Top-down ensemble', 'WetCharts', 'WAD2M upscaling', 'GIEMS2 upscaling'),
                       values = c('Bottom-up ensemble'='black', 
                                  'Top-down ensemble'='darkorchid3', 
                                  # 'WetCharts'='springgreen3', 
                                  'WAD2M upscaling'='red', 
                                  'GIEMS2 upscaling'='blue')) +
    
    scale_fill_manual(name='models',
                      breaks = c('Bottom-up ensemble', 'WAD2M upscaling', 'GIEMS2 upscaling'),
                       values = c('Bottom-up ensemble'='black', 
                                  'WAD2M upscaling'='red', 
                                  'GIEMS2 upscaling'='blue')) +

    coord_flip(ylim=c(0, 10)) +
    line_plot_theme +
    theme(legend.position = c(0.6, 0.85))



# /----------------------------------------------------------------------------#
#/   Save to file
ggsave('../output/figures/lat_lineplot/lat_lineplot_tgyr_v7.pdf',
       width=90, height=100, dpi=400, units='mm')

ggsave('../output/figures/lat_lineplot/lat_lineplot_tgyr_v7.png',
       width=90, height=100, dpi=400, units='mm')

dev.off()



# wad2m <- stack('../data/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc')[[13:228]]
# wad2m <- raster::calc(wad2m, mean, na.rm=T)
# wad2m_m2 <- wad2m * area(wad2m) * 10^6




# # /----------------------------------------------------------------------------#
# #/   CarbonTracker
# 
# ct <- raster('../output/comparison/carbontracker/ct_ltavg_2000_2010_mgCH4m2yr.tif')
# 
# # Convert to annual Tg
# ct <- ct * (area(ct) *10^6)  *10^-15 * 365
# 
# # Calculate per 1degree bin
# ct_df <- as.data.frame(ct, xy=TRUE, na.rm=TRUE)
# 
# # Get the mean, min, max of models per 1deg bin
# ct_df <- 
#     ct_df %>% 
#     rename(ct_tgyr = layer) %>% 
#     # round latitude
#     mutate(lat_rnd = y) %>% 
#     # mutate(lat_rnd = round(y, 0)) %>% 
#     dplyr::select(-x, -y) %>% 
#     group_by(lat_rnd) %>%
#     summarise_at(c('ct_tgyr'), .funs=sum, na.rm=T) %>% 
#     as_tibble()



# # Convert raster stack to degree sums
# wc_df_deg <- ts2monthdegsumflux(wc_11)
# # wc_df_deg <- filter(wc_df_deg, lat_rnd <=78)

# sum(wc_df_deg$sum_Tgmonth, na.rm=T)
# wc_df_deg$model <- 'WetCharts v1.0'

