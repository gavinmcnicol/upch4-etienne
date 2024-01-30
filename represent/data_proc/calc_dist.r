
#  filter data for complete rows
towers_vars_filt <- towers_vars[complete.cases(towers_vars[,varnames]),]
vars_msk_df <- vars_msk_df[complete.cases(vars_msk_df[,varnames]),]


# append to tower data &  Filter out towers in the same pixel (climatically identical)
world_samp_vars <-  bind_rows(towers_vars_filt, vars_msk_df) %>%
                    distinct(.keep_all = TRUE)


# Scale the variables
indist = world_samp_vars[, varnames]
indist = data.frame(scale(indist))

# Split into towers & global
indist_towers <- indist[ c(1:nrow(towers_vars_filt)),]
indist_glob   <-  indist[c((nrow(towers_vars_filt)+1) : nrow(indist) ),]

# Function clculating distance
calc_dist <- function(x, y, bind_dat){
	dist <- proxy::dist(x = x,  y = y, method = "Euclidean", diag = FALSE,  upper = FALSE)
	dist <- as.data.frame(as.matrix.data.frame(dist))
	names(dist) <- bind_dat 
	return(dist) }


#===================================================================================================
# DISTANCE AMONG TOWERS

dist_tower <- calc_dist(x = indist_towers, y = indist_towers,
						bind_dat = towers_vars_filt$SITE_ID)

dist_tower[dist_tower == 0] <- NA
mean_dist_among_towers = mean(as.matrix(dist_tower), na.rm=T)


#===================================================================================================
# Global distance
dist_glob <- calc_dist(	x = indist_glob, 
                        y = indist_towers, 
						bind_dat = towers_vars_filt$SITE_ID)
nrow(dist_glob)

# Find the minimum distance
min_dist  <- apply(dist_glob, MARGIN = 1, FUN = min, na.rm = TRUE)

# Find the tower that has the minimum distance
closest_tower <- c(apply(dist_glob, MARGIN = 1, FUN = which.min))

closest_tower <- colnames(dist_glob)[unlist(closest_tower)]


# Bind columns into same df
dist_glob <-  cbind(dist_glob, min_dist) %>% mutate(min_dist_di=min_dist / mean_dist_among_towers)
# dist_glob <-  cbind(dist_glob, min_dist_di)
dist_glob <-  cbind(dist_glob, closest_tower)
dist_glob <-  cbind(dist_glob, vars_msk_df[,c('wet_area','x','y')])



# dist_glob[is.infinite(dist_glob)] <- 0
# dist_glob <- bind_cols(dist_glob, min_dist)
# dist_glob[is.finite(rowSums(df)),] <- NA
# dist_glob$
# min_dist_di <- dist_glob$min_dist / mean_dist_among_towers

# dist_for_map <- bind_cols(vars_msk_df[,c('x','y')], min_dist)
# Convert numeric to tower ID
# bioclim_stack_df_wdist$closest_tower <- colnames(bioclim_stack_df_wdist[, (num_bio + 3):num_col])[bioclim_stack_df_wdist$closest_tower]

# colnames(dist_glob)[unlist(closest_tower)]
# )[bioclim_stack_df_wdist$closest_tower]

#===================================================================================================
# # Calculate eucledian distance to all other pixels of all the climatic variables for each tower
# dist_glob <- proxy::dist(x = indist[ c(1:nrow(towers_vars_filt)) , ] ,  #bioclim_stack_df[c(1:num_bio)], 
#                         y = indist[c(nrow(towers_vars_filt)+1 : nrow(indist) ),],      #towers_vars[c(17: (16 + num_bio))], 
#                         method = "Euclidean",
#                         diag = FALSE, 
#                         upper = FALSE)

# # Reformat to be usable for analysis
# distance <- as.data.frame(as.matrix.data.frame(distance))
# names(distance) <- towers_vars_filt$ID
# bioclim_stack_df_wdist <- cbind(bioclim_stack_df, distance)