# Gavin McNicol, Nov 2019 
# Train machine learning ensembles with LOSOCV (to eventually be run in Sherlock)
#   1) Setup and train MLAs (use parallel processing for the for-loop over sites)
#   2) Output ML ensembles (.RDS)
#   3) Output concatenated LOSOCV predictions (.csv) 

# packages
#library(tidyverse)
#library(ggplot2)
library(caret)

# clear workspace
rm(list=ls())

# ggplot theme
mytheme <- theme_bw() +
  theme(panel.border = element_blank(),
        axis.title=element_text(size=14), axis.text=element_text(size=14),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position = "bottom",
        strip.text = element_text(face="bold", size=10),
        strip.background = element_rect(fill='white', colour='white',size=1))

# Read in training data
# train <- read.csv("/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/Data_flux_feat/191127_train_daily_bagIm_spatialRSMETFLUX.csv") # local path
train <- read.csv("../data/flux_feat/191127_train_daily_bagIm_spatialRSMETFLUX.csv") # Sherlock path

# get features
names(train)
spatial.feat <- train %>% dplyr::select("wc10", "wc5", "wc1", "wc6", "sgrids_cc") %>% names()
seasonal.feat <- train %>% dplyr::select("EVI_F", "NDWI_F", "SRWI_F", "LSWI_F") %>% names()
met.t.feat <- train %>% dplyr::select("TA", "PA", "LW_IN") %>% names()
# flux.t.feat <- train %>% dplyr::select("RECO_NT", "LE") %>% names()
# soil.t.feat <- train %>% dplyr::select(30:32) %>% names()

# combine features of desired (check read data file, should match the final feature set suffice (e.g., _RS or _RSMET))
feat <- c(spatial.feat, seasonal.feat, met.t.feat)
feat_l <- length(feat)

# finalize label and feat data
train <- train %>% filter(!is.na(FCH4))  # remove any daily gaps
train_label <- train$FCH4
train_feat <- train %>% dplyr::select(feat)
train_l <- length(train_label)

# setup folds
# folds <- train %>% dplyr::select(Fold) %>% max()
folds <- 2
folds_index <- list()
for (i in 1:folds){
  folds_index[[i]] <- train %>% 
    mutate(index = 1:n()) %>% 
    filter(!Fold == i) %>% 
    dplyr::select(index) %>% pull()
}

## set up lists (for rf)
tgrid <- list()
myControl <- list()

# (0) Spatial feature hyperparameters: mtry = 18, min.node.size = 0.01*train_l
set.seed(23)
## Create tune-grid
tgrid <- expand.grid(
  .mtry = c(8),
  .splitrule = "variance", 
  .min.node.size = c(train_l*0.001)
)

## Create trainControl object
myControl <- trainControl(
  method = "oob",
  classProbs = FALSE,
  verboseIter = TRUE,
  savePredictions = TRUE,
  index = folds_index
)

## train rf on folds
rf_model <- list()
for (i in 1:folds){
  rf_model[[i]] <- train(
    x = train_feat[folds_index[[i]],], 
    y = train_label[folds_index[[i]]],
    method = 'ranger',
    trControl = myControl,
    tuneGrid = tgrid,
    num.trees = 100,
    importance = 'permutation'
  )
  print(i)
}

## save/output model structure
# saveRDS(rf_model, "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/ml_ensembles/191202_daily_bagIm_spatial_top5_RSMET_top7_deep.rds") # local dir.
saveRDS(rf_model, "../output/ml_ensembles/191202_daily_bagIm_spatial_top5_RSMET_top7_deep.rds") # Sherlock dir.
# rf_model <- readRDS("/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/ml_ensembles/191120_daily_medIm_spatial.rds") # local dir.

# look at r2 for all models
x <- c()
for (i in 1:length(rf_model)){
  x[i] <- max(rf_model[[i]]$results$Rsquared)
}

summary(x)

# get all predictions
rf.pred <- list()
for (i in 1:folds) {
  rf.pred[[i]] <- train %>% 
    ungroup() %>%  
    filter(Fold == i) %>%   
    mutate(FCH4P = predict(rf_model[[i]], .),
           index = 1:n())
}
rf.pred.all <- bind_rows(rf.pred)

# write.csv(rf.pred.all, "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/ml_preds/191202_daily_bagIm_spatial_top5_RSMET_top7_deep.csv",
#          row.names = FALSE)
write.csv(rf.pred.all, "../output/ml_preds/191202_daily_bagIm_spatial_top5_RSMET_top7_deep.csv",
        row.names = FALSE)

