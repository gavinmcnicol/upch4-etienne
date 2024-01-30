

# Set working directory
setwd('../data/predictors/sep2020')


n_members = 8

# for (m in c(1:8)){
for (m in c(3,4,7,8)){

	print(m)
	
	# ensembledir = paste0('../data/predictors/sep2020/', m)

	zipname = paste0(m, '.zip')

	# dir.create(ensembledir)
	unzip(zipname, exdir= '.') 

	}

# unzip_member <- function(ensembledir){

# unzip(zipfile, files = NULL, list = FALSE, overwrite = TRUE,
#       junkpaths = FALSE, exdir = ".", unzip = "internal",
#       setTimes = FALSE)