# Latitudinal lineplot

# Get monthly TgCH4 grids
upch4_tg_mean <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw.nc', varname='mean_ch4')
# upch4_tg_sd <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw.nc', varname='sd_ch4')


# /----------------------------------------------------------------------------#
#/  Convert MEAN to df, keep latitude in WGS84
upch4_tg_mean_df <- as.data.frame(upch4_tg_mean, xy=TRUE, na.rm=TRUE) 

upch4_tg_mean_df2 <- 
    upch4_tg_mean_df %>%
    dplyr::select(-x) %>% 
    pivot_longer(starts_with('X'), names_to='time', values_to='tg_month') %>% 
    mutate(time = as.numeric(str_sub(time, 2, -1)))


    # round latitude
    mutate(lat_rnd = round(y,0)) %>% 
    dplyr::select(-x, -y) %>% 
    # Get yearly average emissions
    mutate(upch4_mean_tgyear = mean(c_across(starts_with('X'))) *12) %>% 
    group_by(lat_rnd) %>%
    # Get sum of each column
    summarise_at(c('upch4_mean_tgyear'), .funs=sum)


glimpse(upch4_tg_mean_df)


# /----------------------------------------------------------------------------#
#/   Convert SD to df, keep latitude in WGS84
upch4_tg_sd_df <- as.data.frame(upch4_tg_sd, xy=TRUE, na.rm=TRUE)

upch4_tg_sd_df <- upch4_tg_sd_df %>%
    # round latitude
    mutate(lat_rnd = round(y,0)) %>% 
    dplyr::select(-x, -y) %>% 
    # Get yearly average emissions
    mutate(upch4_sd_tgyear = mean(c_across(starts_with(X))) *12, na.rm=T) %>% 
    group_by(lat_rnd) %>%
    # Get sum of each column
    summarise_at(c('upch4_sd_tgyear'), .funs=sum)



upch4_tg_df <- 
    left_join(upch4_tg_mean_df, upch4_tg_sd_df, by=c('lat_rnd')) %>% 
    mutate(upch4_lo_tgyear = upch4_mean_tgyear + upch4_sd_tgyear,
           upch4_hi_tgyear = upch4_mean_tgyear - upch4_sd_tgyear)

# /----------------------------------------------------------------------------#
#/   Get range of GCP models



wad2m <- stack('../data/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc')[[13:228]]
wad2m <- raster::calc(wad2m, mean, na.rm=T)
wad2m_m2 <- wad2m * area(wad2m) * 10^6


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
    m_r_tgyr_df <- as.data.frame(m_r_tgyr, xy=TRUE, na.rm=TRUE)
    
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
        summarise_at(c('layer'), .funs=sum)
    
    # append to same df
    gcp_lat_tgyear <- left_join(gcp_lat_tgyear, m_r_tgyr_df, by='lat_rnd')
    
}


# Get the mean, min, max of models per 1deg bin
gcp_lat_tgyear <- 
    gcp_lat_tgyear %>% 
    group_by(lat_rnd) %>%
    pivot_longer(starts_with("layer"), names_to='models', values_to='tgyr') %>% 
    dplyr::select(-models) %>% 
    summarize_at(vars(-group_cols()), .funs=c('min', 'mean', 'max')) %>%
    # summarise(across(starts_with("layer")), list(min, mean, max), na.rm=T, .names = "{.col}.fn{.fn}") %>% 
    # summarize_at(vars(-group_cols()), .funs=c('min', 'mean', 'max')) %>% 
    as_tibble()


gcp_lat_tgyear


# /----------------------------------------------------------------------------#
#/   From top-down

ct <- stack('../output/comparison/carbontracker/ct_ltavg_2000_2010_mgCH4m2yr.tif')
ct <- ct * (area(ct) *10^6)  *10^-15 *365

# Calculate per 1degree bin
ct_df <- as.data.frame(ct, xy=TRUE, na.rm=TRUE)

# Get the mean, min, max of models per 1deg bin
ct_df <- 
    ct_df %>% 
    rename(ct_tgyr = layer) %>% 
    # round latitude
    mutate(lat_rnd = round(y, 0)) %>% 
    dplyr::select(-x, -y) %>% 
    group_by(lat_rnd) %>%
    summarise_at(c('ct_tgyr'), .funs=sum, na.rm=T) %>% 
    as_tibble()


