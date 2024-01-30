
setwd("/Users/efluet/Library/CloudStorage/Dropbox/upch4/scripts")



# /----------------------------------------------------------------------------#
#/  Create data lists
giems2_dates <- seq(as.Date("2001-01-01"), as.Date("2015-12-01"), by="months")
giems2_dates_2000start <- seq(as.Date("2000-01-01"), as.Date("2015-12-01"), by="months")
wad2m_v1_dates <- seq(as.Date("2000-01-01"), as.Date("2018-12-01"), by="months")
wad2m_v2_dates <- seq(as.Date("2000-01-01"), as.Date("2020-12-01"), by="months")

# /----------------------------------------------------------------------------#
#/ Original GIEMSv2

giems2_aw_na <- rast('../../Chap3_wetland_loss/output/results/natwet/preswet/giems2_aw_v3_na.tif')[[109:288]]

giems2_aw_na_sum <- global(giems2_aw_na, sum, na.rm=T)/10^6 

giems2_aw_na_sum <- giems2_aw_na_sum %>% 
                    rename(giems2_aw_original = sum) %>% 
                    mutate(date = giems2_dates)


# /----------------------------------------------------------------------------#
#/ GIEMSv2 Corrected V1 2021

giems2_corr_v1_2021 <- rast('../data/giems2_corr.tif')

giems2_corr_v1_2021_sum <- global(giems2_corr_v1_2021, sum, na.rm=T)/10^6 

giems2_corr_v1_2021_sum <- giems2_corr_v1_2021_sum %>% 
    rename(giems2_corr_v1_2021 = sum) %>% 
    mutate(date = giems2_dates)


# /----------------------------------------------------------------------------#
#/ GIEMSv2 Corrected V1 2023

giems2_corr_v1_2023 <- rast('../output/giems2_corr_v1_2023.tif')

giems2_corr_v1_2023_sum <- global(giems2_corr_v1_2023, sum, na.rm=T)/10^6 

giems2_corr_v1_2023_sum <- giems2_corr_v1_2023_sum %>% 
    rename(giems2_corr_v1_2023 = sum) %>% 
    mutate(date = giems2_dates)


# /----------------------------------------------------------------------------#
#/ GIEMSv2 Corrected V1 2023a. - same as 2023 but without cap on Corr_factor

giems2_corr_v1_2023a <- rast('../output/giems2_corr_v1_2023a.tif')

giems2_corr_v1_2023a_sum <- global(giems2_corr_v1_2023a, sum, na.rm=T)/10^6 

giems2_corr_v1_2023a_sum <- giems2_corr_v1_2023a_sum %>% 
    rename(giems2_corr_v1_2023a = sum) %>% 
    mutate(date = giems2_dates)



# /----------------------------------------------------------------------------#
#/ GIEMSv2 Corrected V2

giems2_corr_v2 <- rast('../output/giems2_corr_v2_2023.tif')

giems2_corr_v2_sum <- global(giems2_corr_v2, sum, na.rm=T)/10^6 

giems2_corr_v2_sum <- giems2_corr_v2_sum %>% 
    rename(giems2_corr_v2 = sum) %>% 
    mutate(date = giems2_dates)



# /----------------------------------------------------------------------------#
#/ GIEMSv2 Corrected V2 - July 2023

giems2_corr_v2_july2023 <- rast('../output/giems2_corr_v2_july2023.tif')
giems2_corr_v2_july2023 <- giems2_corr_v2_july2023 * cellSize(giems2_corr_v2_july2023[[1]], mask=FALSE) / 10^6

giems2_corr_v2_july2023_sum <- global(giems2_corr_v2_july2023, sum, na.rm=T)/10^6 

giems2_corr_v2_july2023_sum <- giems2_corr_v2_july2023_sum %>% 
    rename(giems2_corr_v2_july2023 = sum) %>% 
    mutate(date = giems2_dates_2000start)



# /----------------------------------------------------------------------------#
#/ WAD2M V1

wad2m_v1 <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/gcp-ch4_wetlands_2000-2018_025deg.nc')
wad2m_v1 <- wad2m_v1 * cellSize(wad2m_v1, mask=FALSE) / 10^6

wad2m_v1_sum <- global(wad2m_v1, sum, na.rm=T)/10^6

wad2m_v1_sum <- wad2m_v1_sum %>% 
    rename(wad2m_v1 = sum) %>% 
    mutate(date = wad2m_v1_dates)


# /----------------------------------------------------------------------------#
#/ WAD2M V2

wad2m_v2 <- rast('../../Chap3_wetland_loss/data/natwet/wad2m/WAD2M_wetlands_2000-2020_025deg_Ver2.0.nc')
wad2m_v2 <- wad2m_v2 * cellSize(wad2m_v2, mask=FALSE) / 10^6

wad2m_v2_sum <- global(wad2m_v2, sum, na.rm=T)/10^6

wad2m_v2_sum <- wad2m_v2_sum %>% 
    rename(wad2m_v2 = sum) %>% 
    mutate(date = wad2m_v2_dates)



# /----------------------------------------------------------------------------#
#/  Combine all tables

library(purrr)

comb_sums <- purrr::reduce(list(giems2_aw_na_sum, 
                                giems2_corr_v1_2021_sum, 
                                giems2_corr_v1_2023_sum, # giems2_corr_v1_2023a_sum, 
                                giems2_corr_v2_sum,
                                giems2_corr_v2_july2023_sum,
                                wad2m_v1_sum, wad2m_v2_sum), 
              dplyr::full_join, 
              by = 'date') 

comb_sums <- comb_sums %>% 
             pivot_longer(cols=c(giems2_aw_original,
                                 giems2_corr_v1_2021, 
                                 giems2_corr_v1_2023, 
                                 giems2_corr_v2,
                                 giems2_corr_v2_july2023,
                                 wad2m_v1, wad2m_v2), 
                          names_to='source',
                          values_to='area')

# /----------------------------------------------------------------------------#
#/ Make lineplot

ggplot(comb_sums) +
    geom_line(aes(x=date, y=area, color=source), size=.5) +
    # geom_point(aes(x=time, y=area/10^6, color=source), size=.5) +
    scale_y_continuous(limits=c(0, 6), expand=c(0, 0) ) +
    scale_x_date(expand=c(0, 0)) + #, labels=as.Date.character(dates)) +
    # scale_color_brewer(palette='Set2') +
    scale_color_manual(values=c('giems2_aw_original'='grey60', 
                                'giems2_corr_v1_2021'='#ffadb0', 
                                'giems2_corr_v1_2023'='#ff2931',
                                # 'giems2_corr_v1_2023a'='green',
                                'giems2_corr_v2'='#730004', 
                                'giems2_corr_v2_july2023'='#ca16de',
                                'wad2m_v1'='#9c99ff', 
                                'wad2m_v2'='#06008a')) +
    xlab('Date') + ylab('Global monthly wetland area (Mkm2)') +
    theme_bw() +
    theme(legend.position = 'right',
          legend.title = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(color='grey90', size=0.1))



ggsave('../output/figures/lineplot_monthly_Aw_corr_comparison_july2023.png',
       width=300, height=160, dpi=300, units='mm')
dev.off()
