library(lubridate)


### Get list of images at coordinate     ---------------------------------------
alos = read.csv("../data/alos/alos_all_rtchires.csv", stringsAsFactors = FALSE)


# clean up names
names(alos) <- gsub(x = names(alos), pattern = "\\.", replacement = "")

# convert to date format
alos$AcquisitionDate <- parseDatetime(alos$AcquisitionDate, fmt = "%Y-%m-%dT%H:%M:%E*S%Ez", tzstr = "UTC")

# alos$AcquisitionMonthYear <-  parseDatetime(alos$AcquisitionDate, fmt = "%Y-%m-%d")
alos$AcquisitionDateOnly <-  as.Date(format(alos$AcquisitionDate,  "%Y-%m-%d"))




alos_sum <- alos %>%
  
        # select some columns
        select(GranuleName, BeamMode, BeamModeDescription, Orbit, PathNumber, 
               FrameNumber, AcquisitionDate, AcquisitionDateOnly, 
               ProcessingDate, ProcessingLevel, StartTime) %>%
  # group by
  group_by(BeamMode, AcquisitionDateOnly, ProcessingLevel) %>%
  # get count
  summarize(n = n()) %>%
filter(BeamMode != "DSN")



###  Bar graph of observations    ---------------------------------------------- 

ggplot(alos_sum)+
  geom_bar(aes(x=as.Date(AcquisitionDateOnly), y=n, fill=BeamMode), stat="identity") +
  facet_wrap(~BeamMode, ncol=1) +
  theme_bw() + 
  scale_x_date(date_labels = "%Y", expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  theme(legend.position = "none") +
  xlab("") +
  ylab("Number of scenes")

### save plot
ggsave("../output/figures/alos_rtchires_scene_count.png",
       width=180, height=280, dpi=300, units='mm', type = "cairo-png")

dev.off()

