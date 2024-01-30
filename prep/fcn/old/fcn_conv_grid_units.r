# /--------------------------------------------------------------------------#
#/    Convert flux from nanomol m^2 sec^-1  to Tg month^-1                ----
#     1 nmol ch4  = 16.04246 g ch4   /  1e+9
#     1 nmol ch4  = 1e-21 Tg
#     1 m^2  -->  1e-6 km^2


### Arguments:
# pred = predicted grids
# Aw   = Area of wetland
conv_grid_units <- function(pred, Aw){

	# Multiply by wetland m^2 area (nmoles sec-1 m-2 -> nmoles sec-1)
	conv <- pred * Aw

	# Convert:  
	# 1 nanomolesCH4    ==  16.04 nanogram CH4 
	# 1 nanogram sec-1  ==  1e-21 Tg sec-1
	
	conv <- conv  * 16.04246 * 1e-21 
	
	# Convert:  Tg sec-1   -->  Tg month-1
	
	conv <- conv  * 2.628e+6

	return(conv)
	}


	# conv <- pred * Aw * 1e-21 * 16.04246 * 2.628e+6



### OLD VERSION - USED TO LOOP THROUGH LIST

# conv_grid_units <- function(pred, Aw){

# 	# make empty stack for output
# 	conv_stack <- stack()

# 	# /------------------------------------------------------------------------#
# 	#/     Loop through predicted grids in nmol                           ------
# 	#      Index i starts with first predictions in 2000

# 	for (i in 1:nlayers(pred)) {   

# 	#length(names(pred))){
#   	# Loop through RF models; applying them in parallel; 
#   	# conv_stack <- foreach(i = 1:length(names(pred)),  #nlayers(pred), # 
#   	#                    .combine=stack, .init=conv_stack, .packages="raster") %dopar%{

# 		# Multiply by wetland m^2 area (nmoles sec-1 m-2 -> nmoles sec-1)
# 		conv <- pred[[i]]  * Aw[[i]]  # * 10^6
		
# 		# Convert:  nmoles sec-1  -->   Tg sec-1 
# 		# 16.04 molesCH4 == 1 gCH4
# 		conv <- conv  * 1e-21 * 16.04246
		
# 		# Convert:  Tg sec-1   -->  Tg month-1
# 		conv <- conv  * 2.628e+6

# 		conv_stack <- stack(conv_stack, conv)
# 		}

# 	return(conv_stack)
# }



# f <- '../data/swampsglwd/v2/gcp-ch4_wetlands_2000-2017_05deg.nc' 

# # read wet fraction as raster brick & convert to wetland area
# Aw <- brick(f, varname="Fw") * pixarea_m2

# #   Get pixel area (m^2)                                             -----
# pixarea_m2 <- area(pred[[1]]) * 10^6

# # Make mask certain wetland area 
# Fw_mask <- Fw[[1+i]]

# 	# /------------------------------------------------------------------------#
# 	#/     Loop through predicted grids in nmol                           ------
# 	#      Index i starts with first predictions in 2000

# 	for (i in 1:length(names(pred))){

# 		# Multiply by wetland area (m2): 
# 		# nmoles sec-1 m-2   -->  nmoles sec-1

# 		conv <- pred[[i]]  * Aw[[i]]  # * 10^6
		
# 		# Convert:  nmoles sec-1  -->   Tg sec-1 
# 		# 16.04 molesCH4 == 1 gCH4
# 		conv <- conv  * 1e-21 *  16.04246
		
# 		# Convert:  Tg sec-1   -->  Tg month-1
# 		conv <- conv  * 2.628e+6

# 		# mask with wetmap
# 		#temp_masked <- mask(output_stack[[i]], Fw_mask)

# 		# Transfer names
# 		# names(conv) <- names(pred[[i]])

# 		# Add output grid to stack
# 		#if (exist(conv_stack)) { conv_stack <- stack(conv_stack, conv) } else { conv_stack <- conv }
# 		conv_stack <- stack(conv_stack, conv)

# 		}
# 	return(conv_stack)
# }

