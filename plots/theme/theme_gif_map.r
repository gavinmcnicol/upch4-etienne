
# /----------------------------------------------------------------------------#
#/ prep gif plottin theme                                                 ------

gif_map_theme <- 
     theme_minimal() +
          theme(
          text = element_text(size=7, colour='black'),
          # plot.title = element_text(hjust = 0.5, vjust=-1, face="bold", size = 6),
          
          legend.key.size = unit(c(4, 4), "mm"),
          # legend.position="left", #c(0.1, 0.4),
          # legend.title=element_text(size=6),
          # legend.text=element_text(size=5),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank())




map_theme <- function(base_size=7){
    theme_minimal() +
        
        theme(#legend.position=c(0.1, 0.4),
            legend.title = element_text(size=7),
            legend.text = element_text(size=6.5),
            plot.title = element_text(size=8, hjust = 0.5, vjust=0),
            plot.subtitle = element_text(size=7, hjust = 0.5, vjust=0),
            axis.line = element_blank(),
            axis.text = element_blank(),
            axis.title = element_blank(),
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank()) }


