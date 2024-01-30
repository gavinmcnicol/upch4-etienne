# latitudinal multipanel

# /----------------------------------------------------------------------------#
#/   Latitudinal heatmap                                                   --------
source('plots/heatmap/lat_heatmap.r')

# Difference heatmap
source('plots/heatmap/diff_heatmap.r')




upch4_monthly_heatmap<- upch4_monthly_heatmap + theme(plot.margin = margin(0, 0, 0, -1, "mm"))
ct_monthly_heatmap  <- ct_monthly_heatmap + ylab('') + theme(plot.margin = margin(0, 0, 0, -1, "mm"))
wc_monthly_heatmap  <- wc_monthly_heatmap + ylab('') + theme(plot.margin = margin(0, 0, 0, -1, "mm"))
gcp_monthly_heatmap <- gcp_monthly_heatmap + ylab('') + theme(plot.margin = margin(0, 0, 0, -1, "mm"))



# /----------------------------------------------------------------------------#
#/  Multipanel
d <- plot_grid(upch4_monthly_heatmap,
               ct_monthly_heatmap,
               wc_monthly_heatmap,
               gcp_monthly_heatmap,
               nrow=1, # ncol=2,
               #align='hv'
               labels = c('A','B','C','D'))

ggsave('../output/figures/heatmap/heatmap_multipanel_wad2m_v2.png',
       d, width=180, height=140, dpi=300, units='mm')

