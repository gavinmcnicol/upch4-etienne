
#-------------------------------------------------------------------------------
#    get polygon of continent outline                                     -----


library(rworldmap)
data(coastsCoarse)

coastsCoarse_df <- fortify(coastsCoarse)
coastsCoarse_df <- arrange(coastsCoarse_df, id)

