
#===================================================================================================

# K-means clustering
k <- kmeans(na.omit(bioclim_stack_df[, 1:num_bio]), centers = 10, nstart = 100)

# Put into stack
bioclim_stack_df_k <- na.omit(bioclim_stack_df)
bioclim_stack_df_k$k <- k$cluster

# Convert data frame into raster
k_raster <- SpatialPixelsDataFrame(bioclim_stack_df_k[, c('x', 'y')], data = bioclim_stack_df_k)
k_raster <- raster(k_raster, layer = ncol(bioclim_stack_df_k))

# Extract the cluster ID of each tower
towers_coords_df_acquired$k <- raster::extract(k_raster, towers_coords_acquired)
