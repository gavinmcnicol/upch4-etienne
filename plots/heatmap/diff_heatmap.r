


# /----------------------------------------------------------------------------#
#/  Make heatmap

make_diff_heatmap <- function(x){

    diff_heatmap <-
        ggplot(x) +
        geom_tile(aes_string(x=month, y=lat_rnd, fill= flux)) +
        xlab('Month') +
        ylab('Latitude (1deg bands)') +
        line_plot_theme + 
        # theme_bw() +
        scale_fill_gradient2(low = scales::muted('blue'),  mid = 'grey95', high = scales::muted('red'),
                              na.value = 'white', midpoint = 0) +
        scale_x_continuous(breaks=seq(1,12), labels=month.abb, expand=c(0,0)) +
        scale_y_continuous(expand=c(0,0)) +
        
        theme(legend.title = element_text()) +
        guides(fill = guide_colorbar(#override.aes = list(size = 0.3),    
            nbin=10, raster=F, barheight = 4, barwidth=.5,
            frame.colour=c('black'), frame.linewidth=0.5,
            ticks.colour='black',  direction='vertical',
            title = expression(paste("Difference\nmg(CH"[4]*") m"^-2*" day"^-1))))
        
    diff_heatmap

    }


