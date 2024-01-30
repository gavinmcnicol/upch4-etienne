#  unzip predictor files 

# /----------------------------------------------------------------------------#
#/    get MERRA2 data open  

# get list of compressed files
dir = "./data/merra2/monthly/"
merra2 <- list.files(dir, pattern = ".nc.gz")

print(merra2)

for(m in merra2){
  
  untar(paste0(dis, m))
  
}

# clean up env
rm(dir, merra2, m)


# /----------------------------------------------------------------------------#
#/    get BioClim data open  

# get list of compressed files
dir = "./data/merra2/monthly/"
bioclim <- list.files(dir, pattern = ".nc.gz")

print(bioclim)

for(b in bioclim){
  
  untar(paste0(dis, b))
  
}



#    - unzip bioclim
#    - unzip merra
#    - make stack
#    - 