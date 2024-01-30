
# Function that preprocesses data for latitudinal lineplot
prep_upch4_for_latlineplot <- function(upch4_tg_mean, upch4_tg_sd){
    
    # /----------------------------------------------------------------------------#
    #/  Convert MEAN to df, keep latitude in WGS84
    upch4_tg_mean_df <- as.data.frame(upch4_tg_mean, xy=T, na.rm=F) 
    
    upch4_tg_mean_df <- upch4_tg_mean_df %>%
        # slice_sample(n=10000) %>% 
        filter_at(vars(X1:X180), any_vars(!is.na(.))) %>% 
        # round latitude, to integer
        mutate(lat_rnd = round(y, 0)) %>% 
        dplyr::select(-x, -y) %>%
        # Get yearly average emissions
        rowwise() %>% 
        mutate(upch4_mean_tgyear = mean(c_across(X1:X180), na.rm=T) *12) %>%
        arrange(desc(upch4_mean_tgyear)) %>% 
        ungroup() %>% 
        group_by(lat_rnd) %>%
        # Get sum of each column
        summarise_at(vars(upch4_mean_tgyear), sum, na.rm=T)
    
    
    # /----------------------------------------------------------------------------#
    #/   Convert SD to df, keep latitude in WGS84
    upch4_tg_sd_df <- as.data.frame(upch4_tg_sd, xy=T, na.rm=F)
    
    upch4_tg_sd_df <- upch4_tg_sd_df %>%
        filter_at(vars(X1:X180), any_vars(!is.na(.))) %>% 
        mutate(lat_rnd = round(y, 0)) %>%       # round latitude, to integer
        dplyr::select(-x, -y) %>%
        # Get yearly average emissions
        rowwise() %>% 
        mutate(upch4_sd_tgyear = mean(c_across(X1:X180), na.rm=T) *12) %>%
        arrange(desc(upch4_sd_tgyear)) %>% 
        ungroup() %>% 
        group_by(lat_rnd) %>%
        # Get sum of each column
        summarise_at(vars(upch4_sd_tgyear), sum, na.rm=T)
    
    
    # Combine mean and sd figures
    upch4_tg_df <- 
        left_join(upch4_tg_mean_df, upch4_tg_sd_df, by=c('lat_rnd')) %>% 
        mutate(upch4_lo_tgyear = upch4_mean_tgyear + upch4_sd_tgyear,
               upch4_hi_tgyear = upch4_mean_tgyear - upch4_sd_tgyear)
    
    return(upch4_tg_df)
    
}

