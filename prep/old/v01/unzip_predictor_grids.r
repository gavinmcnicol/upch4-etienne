# /----------------------------------------------------------------------------#
#/     Unzip predictor files 
print("Unzipping predictor files")


library(R.utils)

# /----------------------------------------------------------------------------#
#/    Get MERRA2 data open  

# get list of compressed files
dir = "../data/merra2/monthly/"
merra2 <- list.files(dir, pattern = ".nc.gz")
print(merra2)

# Untar all files in compressed archive
for(m in merra2){ gunzip(filename=paste0(dir, m)) }  # overwrite = FALSE, remove = TRUE
print(" - Untarred MERRA2")

# Clean up env vars
rm(dir, merra2, m)


# /----------------------------------------------------------------------------#
#/    Get BioClim data open  

# Get list of compressed files
dir = "../data/bioclim/"
bioclim <- list.files(dir, pattern = ".zip")

print(bioclim)

# untar the one BioClim zipped file 
unzip(zipfile=paste0(dir, bioclim), exdir=dir, overwrite = FALSE) #, files = NULL)

print(" - Unzipped BioClim")

# Clean up env vars
rm(dir, bioclim)