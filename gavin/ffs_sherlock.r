## Select predictor subset using FFS (Meyer et al. 2018; CAST package)

# Threshold date ranges for sites
# Add lags and leads
# Use FFS on cv folds to subset predictors, output predictor rankings

## Gavin McNicol
## June 2020

# packages
library(tidyverse)
library(ggplot2)
library(caret)
library(doParallel)
library(parallel)
library(ranger)
library(randomForest)
library(CAST)

# set up cluster
cl <- makeCluster(3, type='FORK')
registerDoParallel(cl)

# load data
data <- read.csv("/home/groups/robertj2/upch4/data/flux_feat/200803_FWET_ffs_train.csv")
features <- read.csv("/home/groups/robertj2/upch4/data/flux_feat/200803_FWET_ffs_train_all_predictors.csv") %>% pull()

set.seed(23)

# space-time folds
space_folds <- CreateSpacetimeFolds(data, spacevar = "Cluster", timevar = NA, k = 10)

## Create tune-grid
tgrid <- expand.grid(
  mtry = c(2)
)

## Create trainControl object
myControl <- trainControl(
  method = "cv",
  classProbs = FALSE,
  allowParallel = TRUE,
  verboseIter = TRUE, 
  savePredictions = TRUE,
  index = space_folds$index
)

## train rf on folds
# ffs function only allows for ~150 features per train
# break into 3 x 93 (total 297) subsets
feat <- list()
feat[[1]] <- features[1:3]
feat[[2]] <- features[4:6]
feat[[3]] <- features[7:9]

# parallelize 
ffs_model <- list()

# i is a feature subset 
for(i in 1:3) {

  return(paste0('i',i))

ffs_model[[i]] <- ffs(
  data[,feat[[i]]], 
  data$FCH4,
  num.trees = 100, # start 300 drop to 100
  method = 'rf',
  trControl = myControl,
  tuneGrid = tgrid,
  metric = "RMSE"
)

}


saveRDS(ffs_model, "/home/groups/robertj2/upch4/output/gavin/ffs/ffs_model.rds") # local dir.

parallel::stopCluster(cl)


