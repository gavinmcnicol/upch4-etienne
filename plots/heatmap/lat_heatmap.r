# Makes heat map of monthly average flux

# /----------------------------------------------------------------------------#
#/    UPSCALING w/ WAD2M                                                --------

# Read full stack of upscaling
upch4_sum <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw.nc', varname='mean_ch4') #%>% 

# Convert raster stack to degree sums df
upch4_wad2m_sum_df_deg <- ts2monthdegsumflux(upch4_sum)
upch4_wad2m_sum_df_deg$model <- 'Upscaling (WAD2M)'
# Make heatmap plot
# upch4_wad2m_monthly_heatmap <- make_flux_heatmap(upch4_wad2m_sum_df_deg, 'sum_Tgmonth')


# /----------------------------------------------------------------------------#
#/    UPSCALING WITH GIEMS2
# Read full stack of upscaling
upch4_sum <- stack('../output/stack/upch4_v04_m1_TgCH4month_Aw_giems2.nc', varname='mean_ch4') #%>% 

# Convert raster stack to degree sums df
upch4_giems2_sum_df_deg <- ts2monthdegsumflux(upch4_sum)
upch4_giems2_sum_df_deg$model <- 'Upscaling (GIEMS2)'
# Make heatmap plot
# upch4_giems2_monthly_heatmap <- make_flux_heatmap(upch4_giems2_sum_df_deg, 'sum_Tgmonth')


# /----------------------------------------------------------------------------#
#/   WetCHARTS v1                                               -------

#   Get Carbon Tracker full stack   -  Units mg m-2 day-1
wc_1 <- stack('../output/comparison/wetcharts/wc_ee_tsavg.tif')#[[1:4]]  # these are all identical WTF
wc_1 <- crop(wc_1, com_ext)

# Convert to Tg month
beginCluster(6)

# Calculate pixel area
pixarea <- area(wc_1[[1]]) 

# bc they all the same [[1:12]]
wc_11  <- overlay(wc_1, pixarea, fun=function(x,y){(x*y*0.00000003)} )

endCluster()

# Convert raster stack to degree sums
wc_df_deg <- ts2monthdegsumflux(wc_11)
# wc_df_deg <- filter(wc_df_deg, lat_rnd <=78)

# sum(wc_df_deg$sum_Tgmonth, na.rm=T)
wc_df_deg$model <- 'WetCharts v1.0'
# Make heatmap plot
# wc_monthly_heatmap <- make_flux_heatmap(wc_df_deg, 'sum_Tgmonth')



# /----------------------------------------------------------------------------#
#/  Bottom-up GCP ensemble                                           ---------

#  Read average GCP model lat ditribution
#  This is averaged after the month-1deg sums;  keeps a seasonal pattern as opposed to when calculated from tsavg grid
gcp_ts_1_df_deg <- read.csv('../output/comparison/gcp_models/avg_gcp_Tgmonth_per1deglat.csv') %>% 
    mutate(month_name = substr(month.abb[month],1,1)) %>% 
    dplyr::select(-X)

gcp_ts_1_df_deg$model <- 'Bottom-up ensemble'
gcp_ts_1_df_deg$sum_Tgmonth <- gcp_ts_1_df_deg$mean_sum_Tgmonth
# Make heatmap plot
# gcp_monthly_heatmap <- make_flux_heatmap(gcp_ts_1_df_deg, 'mean_sum_Tgmonth')



# /----------------------------------------------------------------------------#
#/   Top down inversions  - Units mg m-2 day-1                           --------

#   Get Carbon Tracker full stack
td_1  <- stack("../output/comparison/inversions/td_tsavg_mgCH4m2day_2010_2017.tif")
td_1 <- crop(td_1, com_ext)
td_1 <- disaggregate(td_1, fact=2, method='')  # Disagg to 0.5 to standardize steps with other inputs

beginCluster(6)

# Convert to Tg month
pixarea <- area(td_1[[1]]) 

# Convert to units from mgCH4m2day to TgMonth
td_11  <- overlay(td_1, pixarea, fun=function(x,y){(x*y*0.00000003)} )

# Convert raster stack to degree sums
td_df_deg <- ts2monthdegsumflux(td_11)
# x<-td_11
# x %>% group_by(month) %>% summarise(sum_Tgmonth=sum(sum_Tgmonth))

endCluster()

# Filter lat, to prevent offset of heatmap
# ct_df_deg <- filter(ct_df_deg, lat_rnd <=78)

sum(td_df_deg$sum_Tgmonth, na.rm=T) # 185
td_df_deg$model <- 'Top-down ensemble'
# Make heatmap plot
# ct_monthly_heatmap <- make_flux_heatmap(ct_df_deg, 'sum_Tgmonth')



# /----------------------------------------------------------------------------#
#/  FACET MULTIPANEL of HEATMAPs  (ABSOLUTE FLUXES)

# Combine into single df
sum_df_deg <- bind_rows(upch4_wad2m_sum_df_deg, upch4_giems2_sum_df_deg, gcp_ts_1_df_deg, wc_df_deg, td_df_deg)

# Get global sum for facet label
global_sum<-sum_df_deg %>% group_by(model) %>% summarise(global_sum_Tgmonth = round(sum(sum_Tgmonth,na.rm=T),0))

sum_df_deg <- 
    left_join(sum_df_deg, global_sum, by='model') %>% 
    mutate(labels = paste0(model, '\n', global_sum_Tgmonth , ' Tg/year'))

# Convert labels to factors; for sorting
sum_df_deg$model = factor(sum_df_deg$model, levels=c('Upscaling (WAD2M)', 'Upscaling (GIEMS2)',
                                                     'Bottom-up ensemble', 'WetCharts v1.0', 'Top-down ensemble'))
                          # labels=c("Upscaling\n(WAD2M)\n149 Tg/year", "Upscaling\n(GIEMS2)\n72 Tg/year",
                          #          "Bottom-up\nensemble (WAD2M)\n147 Tg/year", "WetCharts v1.0\n157 Tg/year",
                          #          "Top-down\nensemble\n185 Tg/year"  ))

# Maximum value?
maxcap= 1.0
# Make facet plot
monthly_heatmap_facet_flux <- make_flux_heatmap_facet(sum_df_deg, 'sum_Tgmonth', 'model')
# monthly_heatmap_facet_flux

# /----------------------------------------------------------------------------#
#/  FACET MULTIPANEL of HEATMAPs  (Relative pegged to 150Tg of WAD2M upscaling)

# Combine into single df
sum_df_deg <- bind_rows(upch4_wad2m_sum_df_deg, upch4_giems2_sum_df_deg, gcp_ts_1_df_deg, wc_df_deg, td_df_deg)

# Calculate global totals; and scale fluxes to common WAD2M emissions
sum_df_deg <- 
    sum_df_deg %>% 
    group_by(model) %>% 
    mutate(global_sum_Tgmonth = sum(sum_Tgmonth, na.rm=T)) %>% 
    mutate(sum_Tgmonth_scaled = sum_Tgmonth * 149/global_sum_Tgmonth) %>% 
    ungroup()

# Get global sum for facet label
global_sum_scaled <-sum_df_deg %>% group_by(model) %>% summarise(global_sum_Tgmonth_scaled = round(sum(sum_Tgmonth_scaled,na.rm=T),0))

sum_df_deg <- 
    left_join(sum_df_deg, global_sum_scaled, by='model') %>% 
    mutate(labels_scaled = paste0(model, '\n', global_sum_Tgmonth_scaled , ' Tg/year'))

# Convert labels to factors; for sorting
sum_df_deg$model = factor(sum_df_deg$model, 
                          levels=c('Upscaling (WAD2M)', 'Upscaling (GIEMS2)',
                                   'Bottom-up ensemble', 'WetCharts v1.0', 'Top-down ensemble'))
                          # labels=c("Upscaling\n(WAD2M) 149 Tg/year", "Upscaling\n(GIEMS2) 72 Tg/year",
                          #          "Bottom-up ensemble\n147 Tg/year", "WetCharts v1.0\n157 Tg/year",
                          #          "Top-down ensemble \n185 Tg/year"  ))

# Maximum value
maxcap= 1.0
# Make facet plot
monthly_heatmap_facet_scaled <- make_flux_heatmap_facet(sum_df_deg, 'sum_Tgmonth_scaled', 'model')


# /----------------------------------------------------------------------------#
#/  FACET MULTIPANEL of HEATMAPs  (% of annual flux)

# Combine into single df
sum_df_deg <- bind_rows(upch4_wad2m_sum_df_deg, upch4_giems2_sum_df_deg, gcp_ts_1_df_deg, wc_df_deg, td_df_deg)

# Calculate global totals; and scale fluxes to common WAD2M emissions
sum_df_deg <- 
    sum_df_deg %>% 
    group_by(model) %>% 
    mutate(global_sum_Tgmonth = sum(sum_Tgmonth, na.rm=T)) %>% 
    mutate(sum_Tgmonth_perc = sum_Tgmonth / global_sum_Tgmonth * 100) %>% 
    ungroup()

# Convert labels to factors; for sorting
sum_df_deg$model = factor(sum_df_deg$model, levels=c('Upscaling (WAD2M)', 'Upscaling (GIEMS2)',
                                                     'Bottom-up ensemble', 'WetCharts v1.0', 'Top-down ensemble'),
                          labels=c("Upscaling\n(WAD2M)", "Upscaling\n(GIEMS2)",
                                   "Bottom-up\nensemble", "WetCharts v1.0", "Top-down\nensemble"))

# Maximum value
# maxcap= 1.0
# Make facet plot
monthly_heatmap_facet_perc <- make_perc_heatmap_facet(sum_df_deg, 'sum_Tgmonth_perc', 'model')


# /----------------------------------------------------------------------------#
#/  FACET MULTIPANEL of DIFFERENCE HEATMAPs  (Relative pegged to 150Tg of WAD2M upscaling)

# Combine into single df
sum_df_deg <- bind_rows(upch4_wad2m_sum_df_deg, upch4_giems2_sum_df_deg, gcp_ts_1_df_deg, wc_df_deg, td_df_deg)


sum_df_deg_diff <- sum_df_deg %>% 
    dplyr::select(-mean_sum_Tgmonth, -sd_sum_Tgmonth) %>% 
    ungroup() %>% 
    pivot_wider(id_cols=c('lat_rnd', 'month', 'month_name'), names_from=model,  values_from=sum_Tgmonth) %>% 
    mutate(`Difference Upscaling (GIEMS2)` = `Upscaling (WAD2M)` - `Upscaling (GIEMS2)`,
           `Difference Bottom-up ensemble` = `Upscaling (WAD2M)` - `Bottom-up ensemble`,
           `Difference WetCharts v1.0` = `Upscaling (WAD2M)` - `WetCharts v1.0`,
           `Difference Top-down ensemble` = `Upscaling (WAD2M)` - `Top-down ensemble`) %>% 
    dplyr::select(-`Upscaling (WAD2M)`, -`Upscaling (GIEMS2)`, -`Bottom-up ensemble`, -`WetCharts v1.0`, -`Top-down ensemble`) %>% 
    pivot_longer(cols=`Difference Upscaling (GIEMS2)`:`Difference Top-down ensemble`, names_to='model', values_to='diff_Tgmonth')

sum_df_deg_diff<-bind_rows(sum_df_deg_diff, data.frame(model='Upscaling (WAD2M)', month=NA, diff_Tgmonth=NA))

# Convert labels to factors; for sorting
sum_df_deg_diff$model = factor(sum_df_deg_diff$model, levels=c('Upscaling (WAD2M)', 'Difference Upscaling (GIEMS2)', 'Difference Bottom-up ensemble',
                                                          'Difference WetCharts v1.0','Difference Top-down ensemble'  ),
                               labels=c("Upscaling\n(WAD2M)", "Upscaling\n(GIEMS2)",
                                        "Bottom-up\nensemble", "WetCharts v1.0", "Top-down\nensemble"))

monthly_heatmap_facet_diff <- make_diff_heatmap_facet(sum_df_deg_diff, 'diff_Tgmonth', 'model')
# monthly_heatmap_facet_diff


# /----------------------------------------------------------------------------#
#/      COMBINE FACET PLOTS                                             --------

# Top row
monthly_heatmap_facet_flux<- 
    monthly_heatmap_facet_flux + xlab('') + 
    theme(plot.margin = margin(0, 30, 0, 1, 'mm'),
          legend.position = c(1.15, .5))
    
# Middle row
monthly_heatmap_facet_perc  <- 
    monthly_heatmap_facet_perc + xlab('') + 
    theme(plot.margin = margin(0, 30, 0, 1, 'mm'),
          legend.position = c(1.13, .5))

# Bot row
monthly_heatmap_facet_diff <- 
    monthly_heatmap_facet_diff + xlab('') + 
    theme(plot.margin = margin(0, 30, 0, 1, 'mm'),
          legend.position = c(1.13, .5))

d <- plot_grid(monthly_heatmap_facet_flux,
               monthly_heatmap_facet_perc,
               monthly_heatmap_facet_diff,
               nrow=3, ncol=1,
               align='hv')

# /----------------------------------------------------------------------------#
#/    SAVE MULTIPANEL TO FILE                                           --------

ggsave('../output/figures/heatmap/heatmap_multifacetpanel_v9.png',
       d, width=195, height=200, dpi=300, units='mm')


ggsave('../output/figures/heatmap/heatmap_multifacetpanel_v9.pdf',
       d, width=190, height=200, dpi=300, units='mm')




# # /----------------------------------------------------------------------------#
# #/  Multipanel of separate graphs
# 
# upch4_monthly_heatmap<- upch4_monthly_heatmap + theme(plot.margin = margin(0, 0, 0, -1, 'mm'))
# ct_monthly_heatmap  <- ct_monthly_heatmap + ylab('') + theme(plot.margin = margin(0, 0, 0, -1, 'mm'))
# wc_monthly_heatmap  <- wc_monthly_heatmap + ylab('') + theme(plot.margin = margin(0, 0, 0, -1, 'mm'))
# gcp_monthly_heatmap <- gcp_monthly_heatmap + ylab('') + theme(plot.margin = margin(0, 0, 0, -1, 'mm'))
# 
# d <- plot_grid(upch4_monthly_heatmap,
#                ct_monthly_heatmap,
#                wc_monthly_heatmap,
#                gcp_monthly_heatmap,
#                nrow=1, # ncol=2,
#                #align='hv'
#                labels = c('A','B','C','D'))
# 
# ggsave('../output/figures/heatmap/heatmap_multipanel_wad2m_v3.png',
#        d, width=180, height=140, dpi=300, units='mm')


# /----------------------------------------------------------------------------#
#/   Carbon Tracker  - Units mg m-2 day-1                           --------

# #   Get Carbon Tracker full stack
# ct_1  <- stack('../output/comparison/carbontracker/ct_ts_2000_2010_mgCH4m2yr.tif')
# ct_1 <- crop(ct_1, com_ext)
# ct_1 <- disaggregate(ct_1, fact=2, method='')
# 
# beginCluster(6)
# 
# # Convert to Tg month
# pixarea <- area(ct_1[[1]]) 
# 
# # [[1:24]]
# ct_11  <- overlay(ct_1, pixarea, fun=function(x,y){(x*y*0.00000003)} )
# 
# # Convert raster stack to degree sums
# ct_df_deg <- ts2monthdegsumflux(ct_11)
# 
# endCluster()
# 
# # Filter lat, to prevent offset of heatmap
# # ct_df_deg <- filter(ct_df_deg, lat_rnd <=78)
# 
# sum(ct_df_deg$sum_Tgmonth, na.rm=T)  # 193
# ct_df_deg$model <- 'Carbon Tracker'
# # Make heatmap plot
# # ct_monthly_heatmap <- make_flux_heatmap(ct_df_deg, 'sum_Tgmonth')


# wc_1 <- stack('../output/comparison/wetcharts/wc_ee_mean.tif')#[[1:4]]  # these are all identical WTF
# wc_1 <- aggregate(wc_1, fact=2, na.rm=TRUE, fun='mean')  # Aggregating to 1deg, creates 2deg blocks in df