# Gavin McNicol, May 2019
# First version: February 1, 2019
# Part 1:  Combine site EC data, subset tower predictors, and output flat .csv
# Part 2:  Combine site flux data, site metadata, worldclim data, MODIS data, and pre-process for random forest.
#           (Remove/fill CH4 NAs, impute missing predictor values, split data for leave-one-site-out-validation excluding proximal sites)
# Part 3: Step-wise variable selection: add best predictor, one at a time
# Part 4: Random Forest training: using all variables
#### Variable importance  subsection
# Part 5: Performance and visualization 
# Part 6: Partial Dependency Plots
# Part 7: Random forest training, by wetland class
# Part 8: CART analysis

############
## Part 1 ##
############

# clear workspace
rm(list=ls())

# location/working directory (April 2019; more recent database version is V2.0)
flux_loc <- "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Data_combined/SiteData/V3.0"

# packages
library(lubridate)
library(tidyverse)
library(caret)
library(ranger)
library(RColorBrewer)
library(officer)
library(svMisc)
library(pdp)
library(vip)
library(rpart)

# get all csvs
setwd(flux_loc)
site.names <-list.files(flux_loc, pattern = "csv$", full.names = FALSE)

# load fluxes into list, takes a couple of minutes
FLUXES <- list()
for (i in 1:length(site.names)){
  FLUXES[[i]] <- read.csv(paste(flux_loc,"/",site.names[i],sep="")) # read in each site csv
  names(FLUXES)[i] <- substr(site.names[i],1,5)  # name each list element with site name
  FLUXES[[i]]$ID <- rep(substr(site.names[i],1,5),length(FLUXES[[i]]$Year))   # add ID column with site name repeated
}
FLUXES$USMyb
# store in temporary list to reload quickly
FLUXES0 <- FLUXES
# FLUXES <- FLUXES0 # to reload

# get variable names
var.names <- list()
for (i in 1:length(site.names)){
var.names[[i]] <- FLUXES[[i]] %>% names()
}

# take a look, most things standard but some differences for SWC, TA, TS
var.names

# identify which sites have the variable naming we want (TA = TA_F and TS = TS_1)
x1 <- c(); x2 <- c()
for (i in 1:length(site.names)){
x1[i] <- sum(var.names[[i]] == "TS_1")
x2[i] <- sum(var.names[[i]] == "TA_F")
}
x <- as_tibble(cbind(site.names, x1, x2))
names(x) <- c("site","TS","TA")

x <- x %>% mutate(TS = as.factor(TS),
                  TA = as.factor(TA)) %>% 
           mutate(TS = fct_recode(TS, "TS_1" = "1"),
                  TA = fct_recode(TA, "TA_F" = "1"),
                  TA = fct_recode(TA, "TA" = "0"))

# take a look
View(x2) 

# manually reassign to correct the naming, fill with "ID" where TS is missing entirely
# note to AI folks, TS actually missing from some sites, check coverage for wetland only later.
x2 <- x$TS %>% as.character() 
x2[c(7,17,25,47,48)] <- "ID"
x2[20] <- "TS"
x2[x2 == 0] <- "TS_F"
x2
  
# now use the correct variable designations to fill a generic TS and TA column in the list
for (i in 1:length(site.names)){
  FLUXES[[i]]$TS <- FLUXES[[i]] %>% select(x2[i]) %>% pull() %>% as.numeric()
  FLUXES[[i]]$TA <- FLUXES[[i]] %>% select(x$TA[i]) %>% pull() %>% as.numeric()
}

# flatten the list, this will produce a single data frame with many variables that appear across any csvs
FLUXES.full <- bind_rows(FLUXES)
names(FLUXES.full) # look at all names

# make month variable, some missing timestamp
FLUXES.full <- FLUXES.full %>% 
  mutate(Month = as.factor(substr(TIMESTAMP_END, 5,6)))

#create variable summary table that summarizes the fraction data coverage for each variable, i.e., inverse of #NaNs in each site dataset
# this can help visualize best variables for predictors
FLUXES.variable.summary <- FLUXES.full %>% 
                            group_by(ID) %>% 
                            summarize_all(funs(DataCov = sum(!is.na(.))/length(.)))
View(FLUXES.variable.summary)

write.csv(FLUXES.variable.summary, paste(model_output,"/var_coverage_by_site.csv",sep =""))

#simplify fluxes to the timeseries (ID, Year, Month, DOY, Hour) label (FCH4, FCH4_F, FCH4_F_ANN) and predictor variables(TS, TA, P, VPD, GPP, RECO, NEE, LE, H)
FLUXES.full <- FLUXES.full %>% select(ID, Year, Month, DOY, Hour, 
                                      FCH4, FCH4_F, FCH4_F_ANN, FCH4_uncertainty,
                                      USTAR, SW_IN = SW_IN_F, LW_IN = LW_IN_F, NETRAD = NETRAD_F, RH = RH_F, PA = PA_F, TS, TA, P, VPD = VPD_F,
                                      WS, WTD = WTD_F, D_SNOW = D_SNOW_F, G = G_F, SWC = SWC_F, 
                                      GPP_DT, RECO_DT, NEE = NEE_F_ANN, LE = LE_F_ANN, H = H_F)

# write out flat fluxes csv
# write.csv(FLUXES.full, "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/V3.0/flat_fluxes.csv")



############
## Part 2 ##
############


# location/working directories
data_loc <- "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data"
modis_loc <- "/Users/macbook/Box Sync/MODIS Data/AppEEARS Data"
worldclim_loc <- "/Users/macbook/Box Sync/Upscaling Resources/WorldClim Data"
model_output <- "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/V3.0"
merra2_loc <- "/Users/macbook/Box Sync/Met Reanalysis/merra2.csv"

# load flattened tower flux data
fluxes <- read.csv(paste(data_loc,"/Upscaling_analysis/V3.0/","flat_fluxes.csv",sep=""))

# create a copy to reload from
fluxes1 <- fluxes
fluxes <- fluxes1

# get site.names
site.names <- fluxes %>% select(ID) %>% distinct() %>%  pull()

# get metadata (e.g., biome, class, latitude, longitude, etc.)
metadata <- read_csv(paste(data_loc,"/Upscaling_analysis/V3.0/site_metadata.csv",sep="")) %>% 
  mutate(ID = substr(site.names, 1,5),
         Class = site.class,
         Biome = site.biome,
         PF = site.pf,
         LAT = site.lat,
         LONG = site.long) %>% 
  select(ID, Class, Biome, PF, LAT, LONG)

# load geospatial predictor data  (for now, MODIS dataset)
modis <- read.csv(paste(modis_loc,"/V2.0_MODIS.csv",sep=""))

# Convert Date into Year/DOY 
modis <- modis %>% 
  mutate(DATE = as.Date(DATE, format = "%Y-%m-%d")) %>% 
  mutate(ID = substr(ID, 1,5),
         DOY = yday(DATE),
         DATE = as_date(DATE),
         Month = as.numeric(substr(DATE, 6,7)),
         Year = as.integer(substr(DATE,1,4)),
         SRWI = b02/b05) %>% 
  dplyr::select(ID, LAT, LONG ,DATE, Year, Month, DOY, LSTD, LSTN, EVI, LAI, SRWI) 

# Check data coverage
modis %>% group_by(ID, Year) %>% 
  filter(ID == "BCBog" & Year > 2010) %>% 
  summarize(records1 = sum(!is.na(LSTD)),
            records2 = sum(!is.na(LSTN)),
            records3 = sum(!is.na(EVI)),
            records4 = sum(!is.na(SRWI)))

# get monthly means
modis <- modis %>% 
  group_by(ID, Year, Month) %>% 
  summarize_all(funs(mean(., na.rm = TRUE))) %>% 
  select(ID, Year, Month, LSTD, LSTN, EVI, LAI, SRWI)

# join metadata
fluxes <- fluxes %>% left_join(metadata, by = "ID") %>% 
  mutate(index = 1:n()) %>% 
  select(35,1,33,34,30,31,32,2:29) %>% 
  mutate(Month = as.numeric(Month))

# join modis
fluxes <- fluxes %>% left_join(modis, by = c("ID","Year","Month"))

# read in merra2 data
merra2 <- read.csv(merra2_loc)
merra2 <- merra2 %>% 
          mutate(ID = site.names)

fluxes <- fluxes %>% left_join(merra2, by = c("ID","Year","DOY"))

# look at different sites to evaluate gap-filled trends/weirdness
fluxes %>%
  filter(ID == "USMyb") %>%
  # filter(Year == 2015 & DOY == 200 ) %>%
  ggplot(aes(DOY, LW_M)) +
  geom_point(col = 'black') +
  # geom_point(aes(Hour, FCH4_F_ANN), col = 'pink', alpha = 0.3) +
  scale_y_continuous() +
  facet_wrap(~Year, ncol = 3) +
  theme_bw()

#### skip these steps to avoid using gap-filled data

# filter long gaps and fill short gaps with ANN data
FCH4_tofill <- fluxes %>% 
  filter(!is.na(FCH4_F) & is.na(FCH4)) %>%
  select(index) %>% pull()

# fill with ANN
fluxes$FCH4[FCH4_tofill] <- fluxes$FCH4_F_ANN[FCH4_tofill]

# retain only gap filled data (2.5 million half hours)
fluxes <- fluxes %>% 
  filter(!is.na(FCH4_F)) %>% 
  select(-FCH4_F, -FCH4_F_ANN)

#### end of section to skip

# retain only non-gap filled FCH4 rows
fluxes <- fluxes %>% 
  filter(!is.na(FCH4)) %>% 
  select(-FCH4_F, -FCH4_F_ANN)

# save again as new temporary version
fluxes2 <- fluxes
# fluxes <- fluxes1
# fluxes2 <- fluxes

# remove non-wetland sites 
fluxes <- fluxes %>% filter(Class %in% c("Bog","Fen","Marsh","Peat plateau","Swamp","Wet tundra"))

# remove firest year of USSne (wetland was restoring)
join.sne <- fluxes %>% 
  filter(ID == "USSne" & Year == 2016)
fluxes <- fluxes %>% setdiff(join.sne)

# filter any remaining missing FCH4 rows
fluxes <- fluxes %>% filter(!is.na(FCH4))

# explore quick half hour plots
fluxes %>%
  filter(ID == "") %>%
  ggplot(aes(DOY, P_M)) +
  geom_point() +
  scale_y_continuous(limits=c(0,500)) 
# facet_wrap(~Year, ncol = 1)

fluxes %>% 
  filter(ID == "USBgl")

# get daily means
daily <- fluxes %>% 
  group_by(ID,LAT, LONG, Biome, Class,PF,Year,Month, DOY) %>% 
  summarize_all(funs(mean(., na.rm = TRUE))) %>% 
  select(-Hour) 

# get monthly means
monthly <- fluxes %>% 
  group_by(ID,LAT, LONG, Biome, Class,PF,Year,Month) %>% 
  summarize_all(funs(mean(., na.rm = TRUE))) %>% 
  select(-Hour, -DOY) 

# get worldclim data (static climate variables)
worldclim <- read.csv(paste(worldclim_loc, "/V2.0_sites_worldclim.csv", sep=""))
worldclim <- worldclim %>% 
  mutate(ID = site.names) %>% 
  select(-site.names) %>% 
  mutate(ID = substr(ID,1,5))

#simplify bioclim names
bio <- c("bio1", "bio2", "bio3", "bio4", "bio5", "bio6",
         "bio7", "bio8", "bio9", "bio10", "bio11", "bio12",
         "bio13", "bio14", "bio15", "bio16", "bio17", "bio18", "bio19")

# clean up worldclim
worldclim <- worldclim %>% 
  select(-site.class,-site.biome,-site.pf,-site.lat,-site.long,-X,-X1)

# join worldclim data
daily <- daily %>% left_join(worldclim, by = "ID") %>% select(-index,-X,-X1,-site.class,-site.biome,-site.lat,-site.long,-site.pf)
monthly <- monthly %>% left_join(worldclim, by = "ID") %>% select(-X.x,-X.y,-site.names,-site.class,-site.biome,-site.lat,-site.long,-site.pf)

daily <- daily %>% select(1:36, bio = 37:55)
monthly <- monthly %>% select(1:41, bio = 42:60)

### for MET data, there is no 2018, so filter!
monthly <- monthly %>% 
  filter(Year != 2018 & ID != "USBgl")

# ############# save csv as new version
# write.csv(daily, paste(model_output,"/190513_daily_alldata.csv",sep=""))
write.csv(monthly, paste(model_output,"/190530_monthly_plusMET.csv",sep=""))

# read monthly or daily data
monthly <- read.csv(paste(model_output,"/190513_monthly_alldata.csv",sep=""))

glimpse(monthly)

# quick daily plots
daily %>%
  # filter(ID %in% c("USORv","JPBBY","USStJ")) %>%
  ggplot(aes(DOY, FCH4))+
  geom_point() +
  # scale_y_continuous(limits=c(250,350)) +
  facet_wrap(~ID, ncol = 6, scales = 'free')

# quick monthly plots
monthly %>%
  # filter(ID %in% c("USORv","JPBBY","USStJ")) %>%
  ggplot(aes(Month, LAI)) +
  geom_point() +
  scale_y_continuous() +
  facet_wrap(~ID, ncol = 6)

# split data for machine learning, leave-one-out-x-validation, excluding adjacent sites
train <- ungroup(monthly) 

# break into label and features
train_x <- train[,]
train_y <- train[,10]$FCH4

# redefine site.names variable, after wetland subsetting
site.names <- train %>% select("ID") %>% distinct() %>% pull()

# create a tibble where each site name row is assocaited  with its adjacent 'close by' sites
#  this is clunky bit of coding, could try to automate based a LAT LON threshold
close.sites <- list()
close.sites[[1]] <- c("BCFEN","YFBsf") #BCBog
close.sites[[2]] <- c("BCBog","YFBsf") #BCFEN
close.sites[[3]] <- c("CASCC") #CASCB
close.sites[[4]] <- c("CASCB") #CASCC
close.sites[[5]] <- c("DESfN") #placeholder (i.e. no close sites, site removed as validation site)
close.sites[[6]] <- c("DEZrk") #placeholder
close.sites[[7]] <- c("FILom") #placeholder
close.sites[[8]] <- c("FISi2") #FISi1
close.sites[[9]] <- c("FISi1") #FISi2
close.sites[[10]] <- c("JPBBY") #placeholder

close.sites[[11]] <- c("MYMLM") #MYMLM
close.sites[[12]] <- c("NZKop") #placeholder
close.sites[[13]] <- c("RUChe") #RUCh2
close.sites[[14]] <- c("RUCh2") #RUChe
close.sites[[15]] <- c("RUSAM") #placeholder
close.sites[[16]] <- c("RUVrk") #placeholder
close.sites[[17]] <- c("SEDeg") #placeholder
close.sites[[18]] <- c("SESto") #SESt1
close.sites[[19]] <- c("SESt1") #SESto
close.sites[[20]] <- c("USAtq") #placeholder
close.sites[[21]] <- c("USBes", "USNGB","USBrw") # USBeo

# close.sites[[22]] <- c("USBgl") #placeholder
close.sites[[22]] <- c("USFwm") #USBms
close.sites[[23]] <- c("USBms") #USFwm
close.sites[[24]] <- c("USIcs") #placeholder
close.sites[[25]] <- c("USIvo") #placeholder
close.sites[[26]] <- c("USLos") #placeholder
close.sites[[27]] <- c("USSne","USSnd","USBi1","USTwt","USBi2") #USMyb
close.sites[[28]] <- c("USNC4") #placeholder
close.sites[[29]] <- c("USBeo","USBes","USBrw") #USNGB

close.sites[[30]] <- c("USNGC") #placeholder
close.sites[[31]] <- c("USORv", "USOWC") #placeholder
close.sites[[32]] <- c("USWPT", "USCRT", "USORv") # USOWC
close.sites[[33]] <- c("USMyb","USSnd","USBi1","USBi2") #USSne
close.sites[[34]] <- c("USStj") #placeholder
close.sites[[35]] <- c("USSnd","USBi1","USTw4","USTwt","USBi2") #USTw1
close.sites[[36]] <- c("USSnd","USBi1","USTw1","USTwt","USBi2") #USTw4
close.sites[[37]] <- c("USOWC", "USCRT", "USORv") #USWPT

close.sites.list <- list()
close.sites.list <- as_tibble(cbind(sites = as.character(site.names), proximate = close.sites))

# create folds for LOOCV without proximate sites
folds_train <- list()
for (i in 1:length(site.names)) {
  folds_train[[i]] <- ungroup(train_x) %>%
    mutate(IDX = 1:n()) %>%
    filter(!ID %in% c(close.sites.list$proximate[[i]], as.character(site.names[i]))) %>%
    select("IDX") %>% pull()
}

## evalute NaNs across dataset
train.nans <- train %>% 
  group_by(ID) %>% 
  summarize_all(funs(DataCov = sum(!is.na(.))/length(.)))
# write.csv(train.nans, "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Data_combined/SiteData/V3.0/data_coverage.csv")
View(train.nans)

# get predictors that are complete (SW, LW, PA, TA, VPD, NEE,) and those that are reasonable to impute (USTAR, NETRAD, RH, TS) 
Bio.short <- c("bio1","bio5","bio6","bio10","bio11")
predictors <- train %>% 
  select(36:41,Bio.short) %>% 
  names()

## impute missing predictor values
# select all predictor variables that can be used to preprocess predictors
train_x <- train[,predictors]

# preprocess (using caret)
pp <- preProcess(train_x, method = c("bagImpute"))
train_x_pp <- predict(pp, train_x)
train_x_pp$ID <- train$ID
train_x_pp$Biome <- train$Biome
length(train_x_pp)
train_x_pp <- train_x_pp %>% 
  select(45,46,1:44)

# now check if filled variables were reasonable
# quick monthly plots
train_x_pp %>%
  # filter(ID %in% c("USORv","JPBBY","USStJ")) %>%
  ggplot(aes(Month, TS)) +
  geom_point() +
  scale_y_continuous() +
  facet_wrap(~ID, ncol = 6)



## now subset rf predictors and train model
# select only predictors
train_x <- train_x_pp[,predictors]

# fill NAs in original training set using the imputed values and save the file 
train[,predictors] <- 
  train_x_pp[,predictors]

# save
# write.csv(train, "/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/V3.0/190530_monthly_train.csv" )

## I have gapfilled all the NaNs in the monthly dataset for variables that were reasonable to impute, and using additoin info. e.g, biome
## Now I just take the predictors I want to use

# #####  Start machine learning  #####
# # get training and label data
# train_y <- train$FCH4
# train_x <- train %>% 
#   select(predictors) %>% 
#   select(-1,-2,-3,-5,-6)
# names(train_x)
# # for now, remove DOY
# train_x <- train_x %>% 
#   select(-2)
# names(train_x)

## set up lists (for rf)
tgrid <- list()
myControl <- list()

## Create tune-grid
tgrid <- expand.grid(
  .mtry = c(5,8,10),
  .splitrule = "variance", 
  .min.node.size = c(2,10,20)
)

## Create trainControl object
myControl <- trainControl(
  method = "oob",
  classProbs = FALSE,
  verboseIter = TRUE,
  savePredictions = TRUE,
  index = folds_train
)

## train rf on folds
rf_model <- list()
for (i in 1:length(site.names)){
  rf_model[[i]] <- train(
    x = train_x[folds_train[[i]],], 
    y = train_y[folds_train[[i]]],
    method = 'ranger',
    trControl = myControl,
    tuneGrid =tgrid,
    num.trees = 100,
    importance = 'permutation'
  )
  print(i)
}

## save/output model structure
saveRDS(rf_model, paste(model_output,"/190530_rf_wetlands_monthly_MET_subset.rds",sep=""))
rf_model <- readRDS(paste(model_output,"/190514_rf_wetlands_daily_all_preds.rds",sep=""))


########## LOOK AT VARIABLE IMPORTANCE

## look at variable importance, create table of all site rankings
variable.imp <- list()
var.imp.ranks <- list()
variable.imp.single <- list()
for (i in 1:37) {
  variable.imp[[i]] <- varImp(rf_model[[i]], scale = TRUE)
  
}
var.imp.names <- rownames(variable.imp[[1]]$importance)
for (i in 1:37) {
  var.imp.ranks[[i]] <- variable.imp[[i]]$importance$Overall
  variable.imp.single[[i]] <- cbind(var.imp.names, var.imp.ranks[[i]])
  variable.imp.single[[i]] <- variable.imp.single[[i]] %>% as_tibble() %>% mutate(V2 = as.numeric(V2))
  variable.imp.single[[i]] <- variable.imp.single[[i]] %>% arrange(desc(V2)) %>% select(var.imp.names)
}

variable.importance <- as_tibble(bind_cols(variable.imp.single))
names(variable.importance) <- as.character(site.names)


MaxTable <- function(x) {
  dd <- unique(x)
  dd[which.max(tabulate(match(x,dd)))]
}
#1 method
variable.importance %>% 
  rownames_to_column %>% 
  gather(sitename, predictor, -rowname) %>% 
  mutate(rowname = as.numeric(rowname)) %>% 
  spread(rowname, predictor) %>% 
  mutate_all(., as.factor) %>% 
  summarize_all(., MaxTable)

#2 method
vars.list <- list()
for (i in 2:37) {
  variable.importance %>% 
    rownames_to_column %>% 
    gather(sitename, predictor, -rowname) %>% 
    mutate(rowname = as.numeric(rowname)) %>% 
    spread(rowname, predictor) %>% 
    mutate_all(., as.factor) %>% 
    select(i) %>% 
    pull() -> 
    vars.list[[i]]
}

# now look at summary for top 10 variables
for (i in 2:21) {
  print(summary(vars.list[[i]]))
}




##################

# look at r2 for all models
x <- c()
for (i in 1:length(rf_model)){
  x[i] <- max(rf_model[[i]]$results$Rsquared)
}

summary(x)

# get all predictions
rf.pred <- list()
for (i in 1:length(rf_model)) {
  rf.pred[[i]] <- train %>% 
    filter(ID == site.names[i]) %>%   
    mutate(FCH4P = predict(rf_model[[i]], .))
}
rf.pred.all <- bind_rows(rf.pred)

write.csv(rf.pred.all, paste(model_output,"190530_monthly_MET_subset_pred.csv",sep=""))


train %>% 
  filter(ID == "BCBog") %>% 
  group_by(ID,LAT, LONG, Biome, Class,PF,Year,Month) %>% 
  summarize_all(funs(mean(., na.rm = TRUE))) 

# get monthly means
monthly.pred <- rf.pred.all %>% 
  group_by(ID,LAT, LONG, Biome, Class,PF,Year,Month) %>% 
  summarize_all(funs(mean(., na.rm = TRUE)))


### plotting predictions
# plot all site-years
monthly.pred %>% 
  filter(ID %in% c("BCBog","USBeo","FISi1","USSne","RUChe","USMyb","USORv","NZKop","JPBBY")) %>% 
  ggplot(aes(Month, FCH4))+
  geom_point(size = 2, col = "grey") +
  scale_y_continuous(limits = c(0,400))+
  geom_point(aes(Month, FCH4P), col = 'orange', size = 2, alpha = 0.8)+
  facet_wrap(~ID, ncol = 3) +
  theme_bw() +
  theme(panel.border = element_blank(), 
        axis.title=element_text(size=14), axis.text=element_text(size=14),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black")) +
  labs(x= 'Month', y = expression(CH[4]*' Flux (nmol m'^{-2}*' s'^{-1}*')')) +
  theme(strip.text = element_text(face="bold", size=8),
        strip.background = element_rect(fill='grey', colour='black',size=1))


# plot USMYB
monthly.pred %>% 
  # filter(ID %in% c("BCBog","USBeo","FISi1","USSne","RUChe","USMyb","USORv","NZKop","JPBBY")) %>% 
  filter(ID == "FISi1") %>% 
  ggplot(aes(Month, FCH4))+
  geom_point(size = 2, col = "grey") +
  scale_y_continuous(limits = c(0,100))+
  geom_point(aes(Month, FCH4P), col = 'orange', size = 2, alpha = 0.8)+
  facet_wrap(~Year, ncol = 3) +
  theme_bw() +
  theme(panel.border = element_blank(), 
        axis.title=element_text(size=14), axis.text=element_text(size=14),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black")) +
  labs(x= 'Month', y = expression(CH[4]*' Flux (nmol m'^{-2}*' s'^{-1}*')')) +
  theme(strip.text = element_text(face="bold", size=8),
        strip.background = element_rect(fill='grey', colour='black',size=1))


# plot top 9 sites
monthly.pred %>% 
  group_by(Biome) %>% 
  # filter(ID %in% c("USBes","USBeo","USTw1","CASCC","DEZrk","CASCB","USMyb","RUCh2","BCBog")) %>% 
  ggplot(aes(Month, FCH4))+
  geom_point(size = 2, col = "grey") +
  scale_y_continuous(limits = c(0,500))+
  geom_point(aes(Month, FCH4P), col = 'orange', size = 2, alpha = 0.8)+
  facet_wrap(~Biome, ncol = 3) +
  theme_bw() +
  theme(panel.border = element_blank(), 
        axis.title=element_text(size=14), axis.text=element_text(size=14),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black")) +
  labs(x= 'Month', y = expression(CH[4]*' Flux (nmol m'^{-2}*' s'^{-1}*')')) +
  theme(strip.text = element_text(face="bold", size=8),
        strip.background = element_rect(fill='grey', colour='black',size=1))



# global R2 
ungroup(monthly.pred) %>% 
   # group_by(ID) %>% 
  # filter(!ID %in% c("MYMLM","USORv")) %>% 
  summarize(Rsquared = summary(lm(FCH4P ~ FCH4))$adj.r.squared,
            NSE = 1 - sum((FCH4 - FCH4P)^2) / sum((FCH4 - mean(FCH4))^2),
            Mean_res = mean(FCH4 - FCH4P),
            SD_res = sd(FCH4 - FCH4P),
            MedianO = median(FCH4),
            sdO = sd(FCH4),
            MedianP = median(FCH4P),
            sdP = sd(FCH4P),
            samples = n()) %>% 
  arrange(desc(NSE)) %>% View()
  write.csv(paste(model_output,"190530.csv",sep =""))





############
## Part 6 ##
############

#load rf model
rf_model <- readRDS(paste(model_output,"/V2.0/190502_rf_wetlands_monthly_all_bioclim.rds",sep=""))

vip(rf_model[[1]], bar = FALSE, horizontal = FALSE, size = 1.5)


# create partial dependency data
pd <- rf_model[[1]] %>% 
  partial(pred.var = c("TS", "GPP_DT"), train = train[folds_train[[1]],], plot.engine = "ggplot2")
pd.tsle <- rf_model[[1]] %>% 
  partial(pred.var = c("TS", "LE"), train = train[folds_train[[1]],], plot.engine = "ggplot2")
pd.lelw <- rf_model[[1]] %>% 
  partial(pred.var = c("LE", "LW_IN"), train = train[folds_train[[1]],], plot.engine = "ggplot2")

ice.ts <- rf_model[[1]] %>% 
  partial(pred.var = c("TS"), train = train[folds_train[[1]],], plot.engine = "ggplot2", ice = TRUE, center = TRUE)
ice.le <- rf_model[[1]] %>% 
  partial(pred.var = c("LE"), train = train[folds_train[[1]],], plot.engine = "ggplot2", ice = TRUE, center = TRUE)
ice.lw <- rf_model[[1]] %>% 
  partial(pred.var = c("LW_IN"), train = train[folds_train[[1]],], plot.engine = "ggplot2", ice = TRUE, center = TRUE)
ice.gpp <- rf_model[[1]] %>% 
  partial(pred.var = c("GPP_DT"), train = train[folds_train[[1]],], plot.engine = "ggplot2", ice = TRUE, center = TRUE)
ice.bio6 <- rf_model[[1]] %>% 
  partial(pred.var = c("bio6"), train = train[folds_train[[1]],], plot.engine = "ggplot2", ice = TRUE, center = TRUE)


# plot partial dependency data
plotPartial(pd.tsle, colorkey= TRUE) 

plotPartial(pd.lelw, levelplot = FALSE, zlab = "FCH4", colorkey = FALSE, rug = TRUE) 

plotPartial(pd, zlab = "FCH4", colorkey = FALSE, chull = TRUE, palette = 'magma')

plotPartial(ice.ts, alpha = 0.3, train = train, rug = TRUE)

ice.bio6 %>% 
  ggplot(aes(bio6, yhat)) +
  geom_line(aes(group = yhat.id), alpha = 0.2) +
  stat_summary(fun.y = mean, geom = "line", col= "green", size = 1) +
  theme_bw() +
  theme(panel.border = element_blank(), 
        axis.title=element_text(size=14), axis.text=element_text(size=14),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black")) +
  labs(x= expression('(GPP '*mu*'mol m'^{-2}*' s'^{-1}*')'), y = expression(CH[4]*' Flux (nmol m'^{-2}*' s'^{-1}*')')) +
  theme(strip.text = element_text(face="bold", size=8),
        strip.background = element_rect(fill='grey', colour='black',size=1)) 



### Part 7 ### Random Forest training by wetland class grouping
train <- read.csv("/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/V3.0/190509_monthly_train.csv")

# by wetland class
train_byclass <- list()
train_marsh <- train %>% filter(Class == "Marsh")
train_bog <- train %>% filter(Class == "Bog")
train_fen <- train %>% filter(Class == "Fen")
train_peatplateau <- train %>% filter(Class == "Peat plateau")
train_swamp <- train %>% filter(Class == "Swamp")
train_wettundra <- train %>% filter(Class == "Wet tundra")
train_byclass <- list(train_marsh, train_bog, train_fen, train_peatplateau, train_swamp, train_wettundra)

class <- c("Marsh", "Bog", "Fen","Peat plateau", "Swamp", "Wet tundra")
for (i in 1:6) {
  # get training and label data
  train_y <- train_byclass[[i]]$FCH4
  train_x <- train_byclass[[i]] %>% 
    select(predictors) %>% 
    select(-1,-2,-3,-5,-6)
  predictors.final <- names(train_x)
  
  ## set up lists (for rf)
  tgrid <- list()
  myControl <- list()
  
  ## Create tune-grid
  tgrid <- expand.grid(
    .mtry = c(7,14,21,28,35),
    .splitrule = "variance", 
    .min.node.size = c(2,10,50)
  )
  
  ## Create trainControl object
  myControl <- trainControl(
    method = "oob",
    classProbs = FALSE,
    verboseIter = TRUE,
    savePredictions = TRUE
  )
  
  ## train rf on folds
  rf_model <- train(
    x = train_x, 
    y = train_y,
    method = 'ranger',
    trControl = myControl,
    tuneGrid =tgrid,
    num.trees = 300,
    importance = 'permutation'
  )
  print(i)
  saveRDS(rf_model, paste(model_output,"/190510_rf_wetlands_monthly_all_preds_",class[i],".rds",sep=""))
}


rf_model <- list()
## read models
for (i in 1:6){
  rf_model[[i]] <- readRDS(paste(model_output,"/190510_rf_wetlands_monthly_all_preds_",class[i],".rds",sep=""))
}

########## LOOK AT VARIABLE IMPORTANCE

## look at variable importance, create table of all site rankings
variable.imp <- list()
var.imp.ranks <- list()
variable.imp.single <- list()
for (i in 1:6) {
  variable.imp[[i]] <- varImp(rf_model[[i]], scale = TRUE)
  
}
var.imp.names <- rownames(variable.imp[[1]]$importance)
for (i in 1:6) {
  var.imp.ranks[[i]] <- variable.imp[[i]]$importance$Overall
  variable.imp.single[[i]] <- cbind(var.imp.names, var.imp.ranks[[i]])
  variable.imp.single[[i]] <- variable.imp.single[[i]] %>% as_tibble() %>% mutate(V2 = as.numeric(V2))
  variable.imp.single[[i]] <- variable.imp.single[[i]] %>% arrange(desc(V2)) %>% select(var.imp.names)
}

variable.importance <- as_tibble(bind_cols(variable.imp.single))
names(variable.importance) <- as.character(class)

write.csv(variable.importance, paste(model_output,"/190510_rf_wetlands_byclass_varimp.csv",sep="") )



### Part 7b ### Random Forest training by wetland biome grouping
train <- read.csv("/Users/macbook/Box Sync/MethaneFluxnetSynthesisAnalysis/Data/Upscaling_Analysis/V3.0/190509_monthly_train.csv")
levels(factor(train$Biome))

# by wetland Biome
train_byBiome <- list()
train_Boreal <- train %>% filter(Biome == "Boreal")
train_Temperate <- train %>% filter(Biome == "Temperate")
train_Tropical <- train %>% filter(Biome == "Tropical")
train_Tundra <- train %>% filter(Biome == "Tundra")

train_byBiome <- list(train_Boreal, train_Temperate, train_Tropical, train_Tundra)

biome <- c("Boreal", "Temperate", "Tropical","Tundra")

for (i in 1:4) {
  # get training and label data
  train_y <- train_byBiome[[i]]$FCH4
  train_x <- train_byBiome[[i]] %>% 
    select(predictors.final)
  
  ## set up lists (for rf)
  tgrid <- list()
  myControl <- list()
  
  ## Create tune-grid
  tgrid <- expand.grid(
    .mtry = c(7,14,21,28,35),
    .splitrule = "variance", 
    .min.node.size = c(2,10,50)
  )
  
  ## Create trainControl object
  myControl <- trainControl(
    method = "oob",
    classProbs = FALSE,
    verboseIter = TRUE,
    savePredictions = TRUE
  )
  
  ## train rf on folds
  rf_model <- train(
    x = train_x, 
    y = train_y,
    method = 'ranger',
    trControl = myControl,
    tuneGrid =tgrid,
    num.trees = 300,
    importance = 'permutation'
  )
  print(i)
  saveRDS(rf_model, paste(model_output,"/190514_rf_wetlands_monthly_all_preds_",biome[i],".rds",sep=""))
}


rf_model <- list()
## read models
for (i in 1:4){
  rf_model[[i]] <- readRDS(paste(model_output,"/190514_rf_wetlands_monthly_all_preds_",biome[i],".rds",sep=""))
}

View(train)
predictors.final

train %>% 
  filter(ID == "USOWC")

########## LOOK AT VARIABLE IMPORTANCE

## look at variable importance, create table of all site rankings
variable.imp <- list()
var.imp.ranks <- list()
variable.imp.single <- list()
for (i in 1:4) {
  variable.imp[[i]] <- varImp(rf_model[[i]], scale = TRUE)
  
}
var.imp.names <- rownames(variable.imp[[1]]$importance)
for (i in 1:4) {
  var.imp.ranks[[i]] <- variable.imp[[i]]$importance$Overall
  variable.imp.single[[i]] <- cbind(var.imp.names, var.imp.ranks[[i]])
  variable.imp.single[[i]] <- variable.imp.single[[i]] %>% as_tibble() %>% mutate(V2 = as.numeric(V2))
  variable.imp.single[[i]] <- variable.imp.single[[i]] %>% arrange(desc(V2)) %>% select(var.imp.names)
}

variable.importance <- as_tibble(bind_cols(variable.imp.single))
names(variable.importance) <- as.character(biome)

write.csv(variable.importance, paste(model_output,"/190514_rf_wetlands_bybiome_varimp_1.csv",sep="") )



### Part 7c - look at WTD and VWC ranges  ###

train_y <- train$FCH4
train_x <- train %>% 
  select(predictors) %>% 
  select(-1,-2,-3,-5,-6)



## Look at the ranges in WTD and SWC
fluxes1 %>%
  # # filter(ID %in% c("CASCB","FILom","FISi1","FISi2","JPBBY",
  #                  "JPMse","JPSwl","KRCRC","MAERC","NZKop",
  #                  "SEDeg","SESto","USCRT","USHo1","USHRA",
  #                  "USHRC","USLos","USMyb","USOWC","USSnd",
  #                  "USSne","USSrr","USStJ","USTw1","USTw4",
  #                  "USTwt","USUaf","USWPT")) %>%
  filter(ID == "USHo1") %>% 
  ggplot(aes(DOY, FCH4, color = Class)) +
  geom_point() +
  scale_y_continuous() +
  facet_wrap(~ID+Year, ncol = 3) +
  geom_hline(yintercept = 0) +
  theme_bw() +
  theme(panel.border = element_blank(), 
        axis.title=element_text(size=14), axis.text=element_text(size=14),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black")) +
  labs(x= expression('DOY'), y = expression("WTD (m)")) +
  theme(strip.text = element_text(face="bold", size=8),
        strip.background = element_rect(fill='grey', colour='black',size=1))


### Part 8 - CART anaylsis ####

ch4fit <- rpart(log(FCH4) ~ PF + USTAR + SW_IN + LW_IN + NETRAD + RH + PA + TS + TA + VPD +
             WS + GPP_DT + RECO_DT + NEE + LE + H + EVI + LAI + SRWI + bio1 +
             bio2 + bio3 + bio4 + bio5 + bio6 + bio7 + bio8 + bio9 + bio10 +
             bio11 + bio12 + bio13 + bio14 + bio15 + bio16 + bio17 + bio18 + bio19,
      data = train)

ch4fit
printcp(ch4fit)
rsq.rpart(ch4fit)
summary(ch4fit, cp = 0.1)
plot(ch4fit, uniform = TRUE, compress = TRUE, margin = 0.05, branch = 0)
text(ch4fit,use.n = TRUE, all = TRUE, fancy = TRUE, cex = 0.7)

plot(predict(ch4fit), jitter(resid(ch4fit)))


