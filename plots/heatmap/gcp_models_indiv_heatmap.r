# Convert the GCP grids to units:  mgCH4m2day

# The models originally cover: 2000-2017;  truncated to 2001-2017

# get list of all the monthly ncdf files;  units: mg m-2 day-1
# gCH4/m2/month
# p <- "../data/comparison/gcp_models/gcp_models_april2020/prescribed/"
p <- "../output/comparison/gcp_models/models/"
# gcp_list <- list.files(path = p, pattern="swamps") # ".nc")
gcp_list <- list.files(path = p, pattern=".nc")

# Subset for testing
i <- gcp_list[3]

# /---------------------------------------------------------------#
#/  GCP MODELS UNITS:  gCH4/m2/month  
#  Convert to mgCH4m2day #* 1e-9 * 16.04246 * 1000 *86400 }
# gCH4.m2.month.to.mgCH4m2day <- function(x){  x * 1000 / 30 }
# gCH4.m2.month.to.Tgmonth <- function(x){ x * 1000 / 30 }  #* 1e-9 * 16.04246 * 1000 *86400 }
# pixarea <- area(x[[1]])

# mult <- 1e+6 * 1.0E-12 *30
# mg.m2.day.to.Tg.month <- function(x) { x * pixarea * 1e+6 * 1.0E-12 *30; return(x)}

gcp_temp_df <- data.frame()

# t_start = 13  
# t_end = 216  # 228

# /-------------------------------------------------------
#/  Loop through timesteps
# for (t in t_start:t_end) {


# /------------------------------------------------------
#/ Loop through each model
for (i in gcp_list){
    
    print(paste0('  i: ', i))  # Print ticker
    
    # Read ch4 flux from NCDF as raster
    r <- stack(paste0(p, i), varname = "ech4")#, band = t)
    
    # Convert units
    # beginCluster(6)
    # r <- clusterR(r, calc, args=list(fun=mg.m2.day.to.Tg.month), export='pixarea')
    
    # Convert to Tg month
    pixarea <- area(r[[1]]) 
    # r  <- overlay(r, pixarea, fun=function(x,y){(x*y*0.00000003)} )  # This is faster than clusterR alternative 
    r  <- overlay(r, pixarea, fun=function(x,y){(x*y* 1e+6 * 1.0E-12)} )  # This is faster than clusterR alternative 
    
    # m <- c(NA, NA, 0)
    # m <- matrix(m, ncol=3, byrow=TRUE)
    # r <- reclassify(r, rcl=m, right=FALSE, overwrite=TRUE)
    
    # Reclassify NA to 0s
    m <- c(NA, NA, 0)
    m <- matrix(m, ncol=3, byrow=TRUE)
    beginCluster(12)
    r <- clusterR(r, reclassify, args=list(rcl=m, right=FALSE), overwrite=TRUE)
    endCluster()
    
    # Convert to 1deg lat sum df
    r_df <- ts2monthdegsumflux(r)

    # Add column value
    r_df$model <- i
    
    # Add raster of model i to stack
    gcp_temp_df <- bind_rows(gcp_temp_df, r_df)
    
}




# /------------------------------------------------------
#/   Make heatmap facet for each model
colnamestring <- 'sum_Tgmonth'
y <-
    ggplot(gcp_temp_df) +
    geom_tile(aes(x=month, y=lat_rnd, fill=get(colnamestring))) +
    scale_x_continuous(expand=c(0,0), breaks=seq(1,12), labels=month.abb) +
    scale_y_continuous(expand=c(0,0), limits=c(-56, 85), breaks=pretty_breaks(n=8)) + 
    scale_fill_gradient(low="#fffcba", high="#ad0000", na.value="grey92") +
    
    guides(fill = guide_colorbar(nbin=10, raster=F,
                                 barheight= 0.6, barwidth=8,
                                 frame.colour=c('black'), frame.linewidth=0.5,
                                 ticks.colour='black',  direction='horizontal', position='top',
                                 
                                 title = expression(paste("TgCH"[4]*" month"^-1*" degree"^-1)))) +
    
    facet_wrap(~substr(model, 1, 10), nrow=3) +
    xlab('Months') +
    ylab('Latitude') +
    theme_bw() +
    theme(legend.position = 'top',
          axis.text = element_text(color='black'))

y

ggsave('../output/figures/heatmap/heatmap_indiv_gcp_models.png',
       y, width=300, height=200, dpi=300, units='mm')


write.csv(gcp_temp_df, '../output/comparison/gcp_models/gcp_Tgmonth_sepmodels_per1deglat.csv')

# /------------------------------------------------------
#/   Get sum and sd; save to file
gcp_temp_df_avg <- 
    gcp_temp_df %>% 
    group_by(lat_rnd, month, month_name) %>% 
    summarise(mean_sum_Tgmonth = mean(sum_Tgmonth, na.rm=T),
              sd_sum_Tgmonth = sd(sum_Tgmonth, na.rm=T))
    
write.csv(gcp_temp_df_avg, '../output/comparison/gcp_models/avg_gcp_Tgmonth_per1deglat.csv')
