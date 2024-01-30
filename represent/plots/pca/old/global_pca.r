

# /-------------------------------------------------------------------------------
#/  Get  global cover df
vars_msk_sc_df <- vars_msk_df
vars_msk_sc_df <- vars_msk_sc_df %>% dplyr::select(-x, -y) 
vars_msk_sc_df <- vars_msk_sc_df[complete.cases(vars_msk_sc_df), ]
glimpse(vars_msk_sc_df)

#  filter tower data
towers_vars_filt <- towers_vars[complete.cases(towers_vars[,7:10]),]


# append to tower data
# Filter out towers in the same pixel (climatically identical)
# This ordering keeps the towers in cases of duplicates.
world_samp_vars <-  bind_rows(towers_vars_filt, vars_msk_sc_df) %>%
					distinct(.keep_all = TRUE)

pcainput = data.frame(scale(world_samp_vars[, 7:10]))
names(pcainput) <- c('LAI','SRWI','LE','Reco','MAT')


# /-------------------------------------------------------------------------------
#/  Run PCA
# Scaling for species and site scores. Either species (2) or site (1) scores are scaled by eigenvalues, and the other set of scores is left unscaled, 
#or with 3 both are scaled symmetrically by square root of eigenvalues. Corresponding negative values can be used in cca to additionally multiply results with √(1/(1-λ)). 
#This scaling is know as Hill scaling (although it has nothing to do with Hill's rescaling of decorana). 
#ith corresponding negative values in rda, species scores are divided by standard deviation of each species 
#and multiplied with an equalizing constant. Unscaled raw scores stored in the result can be accessed with scaling = 0.
#, scaling=2)
pca_out  <- rda(pcainput)
head( summary(pca_out))

sc <- scores(pca_out, choices=1:2, scaling=0, display=c("sites", "species"))

uscores <- data.frame(sc$sites)
uscores$PC1 <- uscores$PC1 * 30  # pca_out$CA$eig[1]
uscores$PC2 <- uscores$PC2 * 30  # pca_out$CA$eig[2]


# for tower sites
towers_u <- uscores[c(1:nrow(towers_vars_filt)), ]
towers_u <- bind_cols(towers_vars_filt[,c('ID','COUNTRY','Ann_Flux_mean')], towers_u )

# background
background_u <- uscores[c((nrow(towers_vars_filt)+1) : nrow(uscores)), ]

#uscores1 <- inner_join(rownames_to_column(dune.env), rownames_to_column(data.frame(uscores)), type = "right", by = "rowname")
# data.scores <- bind_cols(data.scores, towers_vars[, c('ID','COUNTRY')])

# v-scores - loading vectors
vscores <- data.frame(sc$species)


# /----------------------------------------------------------------------------#
#/  Plot MDS of all towers (acquired and not acquired)                 ---------

pca_plot = ggplot() +

	# Background points
	# stat(level))
	stat_density_2d(data = background_u, aes(x=PC1, y=PC2, fill=..level..), geom = "polygon") + # bins = 14
	scale_fill_gradient(low = "grey92",  high = "grey37", guide=FALSE) +
	new_scale_fill() +
	# geom_point(data = background_u, aes(x = PC1, y = PC2), shape=16, color='grey80', size = 0.5, alpha=0.5) + 

	# Loading vectors - arrows & labels
	geom_segment(data=vscores, aes(x=0, xend=PC1*0.6, y=0, yend=PC2*0.7), arrow = arrow(length = unit(0.3, "cm")), colour="black", size=0.3) + 
	geom_text(data=vscores, aes(x = PC1*0.65, y = PC2*0.65, label=names(pcainput)), colour="black", fontface = "bold", size=2) +
	

	# Towers points & labels
	geom_point(data = towers_u, aes(x = PC1, y = PC2, fill=Ann_Flux_mean), color='black', shape=21, size = 2.1) + 
	scale_fill_distiller(palette = "Blues", direction=1) + 
	guides(fill = guide_colorbar(title = expression(paste("gC m"^2*" yr"^-1)))) +

	# add labels
	geom_text_repel(data= subset(towers_u, (PC1>0.1 | PC1< -0.1 | PC2 > 0.1 | PC2< -0.1) ),
									aes(label=ID, x=PC1, y=PC2), 
									size = 1.8, 
									colour='blue', 
									segment.size = 0.25, 
									segment.color='blue',
									force = 5,
									box.padding = unit(0.2, 'lines'),
									point.padding = unit(0.2, 'lines')) +

	# labs(title = "Principal components of FLUXNET-CH4 towers") + 
	# xlim(-1, 1) + ylim(-1, 1) +
	# scale_x_continuous(limits=c(-0.6, 0.6)) +   scale_y_continuous(limits=c(-0.6, .85)) +
	# scale_x_continuous(breaks=c(-0.5, 0, 0.5), limits=c((min(vscores$PC1)*1.1), (max(vscores$PC1)*1.1,))) +
	# scale_y_continuous(breaks=c(-0.5, 0, 0.5), limits=c(min(vscores$PC2)*1.1, max(vscores$PC2)*1.1,)) +
	# coord_equal() +
	xlab('PC1 (59.2%)') +
	ylab('PC2 (33.6%)') +
	line_plot_theme +
	theme(panel.border = element_rect(color = "black", fill = NA, size = 0.5),
				legend.position = c(0.025, 0.18))



# Save settings for the MDS plot 
ggsave(	plot = pca_plot, 
		file = "pca_all_preds_v23_nosalt.png", 
		path = "../output/figures", 
		width = 90, height = 95, dpi = 400, units = "mm")












# # /------------------------------------------------------------------
# #/ u-scores 
# uscores <- data.frame(pca_out$CA$u)

# # for tower sites
# towers_u <- uscores[c(1:nrow(towers_vars_filt)), ]
# towers_u <- bind_cols(towers_vars_filt[,c(1:5)], towers_u )

# # background
# background_u <- uscores[c((nrow(towers_vars_filt)+1) : nrow(uscores)), ]

# #uscores1 <- inner_join(rownames_to_column(dune.env), rownames_to_column(data.frame(uscores)), type = "right", by = "rowname")
# # data.scores <- bind_cols(data.scores, towers_vars[, c('ID','COUNTRY')])


# # v-scores - loading vectors
# vscores <- data.frame(pca_out$CA$v)

# vscores$PC1 <- vscores$PC1 / pca_out$CA$eig[1]
# vscores$PC2 <- vscores$PC2 / pca_out$CA$eig[2]
