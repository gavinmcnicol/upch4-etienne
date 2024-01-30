
# /----------------------------------------------------------------------------#
#/ prep gif plottin theme                                                 ------

gif_map_theme <- function(base_size=10){
  theme_minimal() +
    
    theme(plot.title = element_text(hjust = 0.5, face="bold", size = 14),
          
          legend.key.size = unit(c(0.6,0.5), "mm"),
          legend.position="left", #c(0.1, 0.4),
          legend.title=element_text(size=10),
          legend.text=element_text(size=10),
          
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank()) }
