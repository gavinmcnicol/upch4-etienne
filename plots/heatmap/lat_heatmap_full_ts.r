
# Read full stack of upscaling
upch4_sum <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw.nc', varname='mean_ch4') #%>% 



# /----------------------------------------------------------------------------#
#/  Make Full time series heatmap 

# Full time series - 216 months
upch4_sum_df2 <- upch4_sum_df %>% 
    # Round latitude
    mutate(lat_rnd = round(y, 0)) %>% 
    dplyr::select(-c('x','y')) %>% 
    group_by(lat_rnd) %>% 
    # Sum per 1deg of lat
    summarise_all(sum, na.rm=T) %>%
    ungroup() %>% 
    pivot_longer(X1:X216, names_to='timestep', values_to='sum_Tgmonth') %>% 
    mutate(timestep=as.numeric(substr(timestep, 2, length(timestep))))


glimpse(upch4_sum_df2)

heatmap <-
    ggplot(upch4_sum_df2) +
    geom_tile(aes(x=timestep, y=lat_rnd, fill= sum_Tgmonth)) +
    scale_fill_viridis_c() +
    scale_x_continuous(expand=c(0,0)) +
    scale_y_continuous(expand=c(0,0)) +
    xlab('Time') +
    ylab('Latitude') +
    theme_bw()

heatmap

# ggsave('../output/figures/upch4_lat_heatmap_Tgmonth.png',
#        width=180, height=100, dpi=300, units='mm')
# dev.off()
# 


