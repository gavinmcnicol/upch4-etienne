# Input: raster stack
ts2monthdegsumflux <- function(x){
    
    # Monthly gcp flux
    x <-
        x %>% 
        as.data.frame(., xy=TRUE, na.rm=F) %>% 
        as_tibble()
    
    # Calculate average monthly flux
    x <- 
        x %>%
        # Exclude pixels all NA
        filter_at(vars(3:ncol(x)), any_vars(!is.na(.))) %>%
        # mutate( across(everything(), ~replace_na(.x, 0))) %>%
        # slice_sample(n=50000) %>% 
        # Pivot to long format
        pivot_longer(cols= 3:ncol(x), names_to = 'month', values_to='flux') %>% 
        
        mutate(month=rep(seq(1,12), nrow(.)/12)) %>% 
        # separate(month, sep='[.]', into=c('file','month'), convert = TRUE) %>% 
        group_by(x, y, month) %>% 
        summarise(flux=mean(flux, na.rm=T)) %>% 
        ungroup() %>% 
        # Summarize by 1deg latitude band
        # If the first digit that is dropped is exactly 5, R uses a rule that’s common in programming languages: Always round to the nearest even number. round(1.5) and round(2.5) both return 2, for example, and round(-4.5) returns -4.
        mutate(lat_rnd = round(y, 0)) %>% 
        # Remove columns
        dplyr::select(-c('x','y')) %>% 
        # Get sum of flux per 1deg band
        group_by(lat_rnd, month) %>% 
        summarise(sum_Tgmonth=sum(flux, na.rm=T)) %>% 
        ungroup() %>% 
        # Add month label
        mutate(month_name = substr(month.abb[month],1,1))
    
    return(x)
}


lat_breaks = c(-55, -40, -20, 0 , 20, 40, 60, 77)

# /----------------------------------------------------------------------------#
#/  Function making monthly-avg heatmap

make_flux_heatmap <- function(x, colnamestring){
    
    y <-
        ggplot(x) +
        geom_raster(aes(x=month, y=lat_rnd, fill=get(colnamestring))) +
        scale_x_continuous(expand=c(0,0), breaks=seq(1,12), labels=month.abb) +
        scale_y_continuous(expand=c(0,0), limits=c(-56, 78), breaks=lat_breaks) +  # used to be cropped at 85
        scale_fill_gradient(low="#fffcba", high="#ad0000", na.value="grey92") +
        
        # guides(fill = guide_colorbar(nbin=10, raster=F,
        #                              barheight= 0.6, barwidth=8,
        #                              frame.colour=c('black'), frame.linewidth=0.5,
        #                              ticks.colour='black',  direction='horizontal', position='top',
        #                              title = expression(paste("TgCH"[4]*" month"^-1*" degree"^-1)))) +
        
        guides(fill = guide_colorbar(nbin=10, raster=F,
                                     barheight= 8, barwidth=.8,
                                     frame.colour=c('black'), frame.linewidth=0.5,
                                     ticks.colour='black',  direction='vertical', position='right',
                                     title = expression(paste("TgCH"[4]*" month"^-1*" degree"^-1)))) +
        
        xlab('Months') + ylab('Latitude') +
        theme_bw() +
        theme(legend.position = 'top',
              axis.text = element_text(color='black'))
    
    return(y)
}



# /----------------------------------------------------------------------------#
#/   Make flux heat map with facet

make_flux_heatmap_facet <- function(x, colnamestring, facetnamestring){
    
    x<- x %>% 
        mutate(layer = get(colnamestring)) %>% 
        mutate(layer = ifelse(layer > maxcap, maxcap, layer))
    
    # maxval <- max(x$layer, na.rm=T)
    # print(maxval)
    
    y <-
        ggplot(x) +
        geom_raster(aes(x=month, y=lat_rnd, fill=layer)) +  # get(colnamestring)
        scale_x_continuous(expand=c(0,0), breaks=seq(1,12), labels=substr(month.abb,1,1)) +  #
        scale_y_continuous(expand=c(0,0), limits=c(-55, 77.000001), breaks=lat_breaks) + #pretty_breaks(n=8) # used to be cropped at 85
        # scale_fill_gradient(low="#fffcba", high="#ad0000", na.value="grey92") +
        scale_fill_gradientn(colours = c('grey90', rev(rainbow(8))))+ #, limits=c(0, maxval)) +
        # scale_fill_viridis(option="rocket") + 
        # theme_bw() +
        heatmap_theme +
        guides(fill = guide_colorbar(nbin=10, raster=F,
                                     barheight= 8, barwidth=.8,
                                     frame.colour=c('black'), frame.linewidth=0.5,
                                     ticks.colour='black',  direction='vertical', position='right',
                                     title = expression(paste("TgCH"[4]*" month"^-1*"\ndegree"^-1)))) +
        # guides(fill = guide_colorbar(nbin=10, raster=F,
        #                              barheight= 0.6, barwidth=12,
        #                              frame.colour=c('black'), frame.linewidth=0.5,
        #                              ticks.colour='black',  direction='horizontal', position='top',
        #                              title = expression(paste("TgCH"[4]*" month"^-1*" degree"^-1)))) +
        facet_wrap(~get(facetnamestring), nrow=1) +
        xlab('Months') +
        ylab('Latitude') +

        theme(legend.position = 'right',
              axis.text = element_text(color='black'))
    
    return(y)
}



# /----------------------------------------------------------------------------#
#/   Make flux heat map with facet

# install.packages("viridis")
library(viridis)
make_perc_heatmap_facet <- function(x, colnamestring, facetnamestring){
    
    
    x<- x %>% 
        mutate(layer = get(colnamestring)) %>% 
        mutate(layer = ifelse(layer > maxcap, maxcap, layer))
    
    y <-
        ggplot(x) +
        geom_raster(aes(x=month, y=lat_rnd, fill=layer)) +  # get(colnamestring)
        scale_x_continuous(expand=c(0,0), breaks=seq(1,12), labels=substr(month.abb,1,1)) +  #
        scale_y_continuous(expand=c(0,0), limits=c(-55, 77.000001), breaks=lat_breaks) +  # used to be cropped at 85
        # scale_fill_gradient(low="#fffcba", high="#ad0000", na.value="grey92") +
        # scale_fill_gradientn(colours = c('grey90', rev(rainbow(8)))) +
        scale_fill_viridis(option="rocket", direction=-1) + 
        # theme_bw() +
        heatmap_theme +
        # guides(fill = guide_colorbar(nbin=10, raster=F,
        #                              barheight= 0.6, barwidth=12,
        #                              frame.colour=c('black'), frame.linewidth=0.5,
        #                              ticks.colour='black',  direction='horizontal', position='top',
        #                              title = expression(paste("Percent (%) of annual CH"[4]*" flux")))) +
        
        guides(fill = guide_colorbar(nbin=10, raster=F,
                                     barheight= 8, barwidth=.8,
                                     frame.colour=c('black'), frame.linewidth=0.5,
                                     ticks.colour='black',  direction='vertical', position='right',
                                     title = expression(paste("Percent (%) of\nannualCH"[4]*" flux")))) +
        
        facet_wrap(~get(facetnamestring), nrow=1) +
        xlab('Months') +
        ylab('Latitude') +
        
        theme(legend.position = 'right',
              axis.text = element_text(color='black'))
    
    return(y)
}

# /----------------------------------------------------------------------------#
#/   Make flux heat map with facet

make_diff_heatmap_facet <- function(x, colnamestring, facetnamestring){
    
    x<- x %>% 
        mutate(layer = get(colnamestring)) %>% 
        mutate(layer = ifelse(layer > maxcap, maxcap, layer))
    
    y <-
        ggplot(x) +
        geom_raster(aes(x=month, y=lat_rnd, fill=layer)) +  # get(colnamestring)
        scale_x_continuous(expand=c(0,0), breaks=seq(1,12), labels=substr(month.abb,1,1)) +  #
        scale_y_continuous(expand=c(0,0), limits=c(-55, 77.000001), breaks=lat_breaks) +  # used to be cropped at 85
        heatmap_theme +
        
        scale_fill_gradient2(low = scales::muted('blue'),
                              mid = 'grey95',
                              high = scales::muted('red'),
                              na.value = 'white',
                              midpoint = 0,
                             limits=c(-1, .5)) +
        
        guides(fill = guide_colorbar(nbin=10, raster=F,
                                     barheight= 8, barwidth=.8,
                                     frame.colour=c('black'), frame.linewidth=0.5,
                                     ticks.colour='black',  direction='vertical', position='right',
                                     title = expression(paste("Difference in\npercent (%) of\nannual CH"[4]*" flux\nfrom WAD2M upscaling")))) +
        # guides(fill = guide_colorbar(nbin=10, raster=F,
        #                              barheight= 0.6, barwidth=12,
        #                              frame.colour=c('black'), frame.linewidth=0.5,
        #                              ticks.colour='black',  direction='horizontal', position='top',
        #                              title = expression(paste("Difference in percent (%) of annual CH"[4]*" flux")))) +
        
        facet_wrap(~get(facetnamestring), nrow=1) +
        xlab('Months') +
        ylab('Latitude') +
        
        theme(legend.position = c(0.9, 0.5),#'right',
              axis.text = element_text(color='black'))
    
    return(y)
}

