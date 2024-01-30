#!/bin/bash
#SBATCH --job-name=upscaling
#SBATCH --time=60:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --output=R-upscaling_test.log


# load modules
ml reset
ml R
ml load physics  # needs to be loaded before gdal
ml load proj     # needs to be loaded before geos
ml load gdal/2.2.1
ml load geos
ml load netcdf

# The R_libs path can be defined with:
cat << EOF > $HOME/.Renviron
R_LIBS=/home/groups/robertj2/R_libs
EOF



# run 
srun sleep 1
# run R code
R --no-save << source("./scripts/cluster_runall.r")