#!/bin/bash 
#SBATCH --job-name=upch4_final2
#SBATCH --time=6:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=8G
#SBATCH --output=upch4_final2.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=$efluet@stanford.edu

# whole thing runs for t=216 in 42hrs

start_time=`date +%s`

# /-------------------------------------------------
#/    Load modules
ml R             # Load R (default 3.5)
ml load physics  # load category: for gdal and geos
ml load proj     # needs to be loaded before geos
ml load gdal/2.2.1
ml load geos
ml load netcdf
ml system
ml imagemagick   # for animated GIF

# set wd
cd /home/groups/robertj2/upch4/scripts


# /----------------------------------------------------------------------------#
#/     Set R_libs path for pckg download                                 -------
# Note:  Really not sure it needs to be ran every time, but I leave it 2b on safer side.
# EOF:  passes  multi-line string to shell.
cat << EOF
$HOME/.Renviron
R_LIBS=/home/groups/robertj2/R_libs
EOF
# Set the R library environment variable (R_LIBS)  to include your R package directory   
export R_LIBS=~/Rlibs

# /----------------------------------------------------------------------------#
#/  There are 2 options to run R script from Bash 

# For options: R --help

# 1. Run R code with BASH CMD
# Requires an input file, saves to .r.Rout
# Echoes I/O inline
# Cannot write output to stdout
#R CMD BATCH ./cluster_runall.r. # or with $HOME?

# R CMD BATCH --no-save --quiet --slave < ./cluster_runall.r
# echo " - Opening Rout"
# cat ./cluster_runall.r.Rout

# 2. Run with Rscript
# Requires shebang: #!/usr/bin/Rscript
# Req. auth. to run chmod +x script.r)
# Output from print() and cat() sent to STDOUT; no file is made

chmod +x runall_v4.r
echo " - Running Rscript"
Rscript runall_v4.r > runall_v4.r.Rout


end=`date +%s`
runtime=$((end-start))
#&& 
echo run time is $(expr `date +%s` - $start_time) 
# echo runtime

# echo "End of program at `date`"

# to install packages from terminal
# R INSTALL		Install add-on packages