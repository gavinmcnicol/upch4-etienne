# /-----------------------------------------------------------#
#/ Cut values into bins  
#  Var = data frame raster; Columns with values must be named 'layer'

To.Saunois2020.Scale <- function(df){

	my_breaks = c(0, 0.5, 1, 2, 5, 10, 15, 20, 30, 40, 50, 500)
	
	df$layer_cut <- cut(df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)

	# replace the categories stings to make them nicer in the legend
	df$layer_cut <- gsub("\\(|\\]", "", df$layer_cut)
	df$layer_cut <- gsub("\\)|\\[", "", df$layer_cut)
	df$layer_cut <- gsub("\\,", " to ", df$layer_cut)
	df <- df %>% mutate(layer_cut=ifelse(layer_cut=="50 to 500", "50+", layer_cut))

	# ~~~ set legend order ----------
	legend_order <- rev(c(	"0 to 0.5", "0.5 to 1", "1 to 2", "2 to 5", 
							"5 to 10",  "10 to 15", "15 to 20", "20 to 30", 
							"30 to 40", "40 to 50", "50+"))

	df$layer_cut <- factor(df$layer_cut, levels = legend_order)

	return(df)
	}



# /-----------------------------------------------------------#
#/ Cut values into bins  
#  Var = data frame raster; Columns with values must be named 'layer'

To.Diff.Map.Scale <- function(df){

	my_breaks = c(-150, -50, -10, -5, -1, 1, 5, 10, 50, 150)
	# my_breaks = c(0, 0.5, 1, 2, 5, 10, 15, 20, 30, 40, 50, 250)
	
	df$layer_cut <- cut(df$layer, breaks=my_breaks, right=FALSE, dig.lab=10)

	# replace the categories stings to make them nicer in the legend
	df$layer_cut <- gsub("\\(|\\]", "", df$layer_cut)
	df$layer_cut <- gsub("\\)|\\[", "", df$layer_cut)
	df$layer_cut <- gsub("\\,", " to ", df$layer_cut)
	df <- df %>% mutate(layer_cut=ifelse(layer_cut=="50 to 150", "50+", layer_cut))

	# # ~~~ set legend order ----------
	# legend_order <- rev(c(	"0 to 0.5", "0.5 to 1", "1 to 2", "2 to 5", 
	# 						"5 to 10",  "10 to 15", "15 to 20", "20 to 30", 
	# 						"30 to 40", "40 to 50","50+"))

	# df$layer_cut <- factor(df$layer_cut, levels = legend_order)

	return(df)
	}