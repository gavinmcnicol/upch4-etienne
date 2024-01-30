#  Process data to generate a latitudinal barplot of upscaling vs GCP vs CarbonTracker 

# /-------------------------------------------------
#/  Caclulate per latitude
mgCH4m2day.to.TgCH4month <- function(x){ x * 1e-6 * 30 }


# Apply unit conv &  Scale by wetland area
mgCH4m2day.to.TgCH4month.and.scaling <- function(instack){ 
	stack_TgCH4month <- calc(instack, fun=nmolCH4m2sec.to.TgCH4month)
	stack_TgCH4month <- overlay(stack_TgCH4month, Aw_m2, fun=function(s, Aw_m2) s * Aw_m2)
	return(stack_TgCH4month) }


# Convert 1deg grids to Tg per month
ml_1_TgMonth  <- mgCH4m2day.to.TgCH4month(ml1)
gcp_1_TgMonth <- mgCH4m2day.to.TgCH4month(gcp1)
ct_1_TgMonth  <- mgCH4m2day.to.TgCH4month(ct)
