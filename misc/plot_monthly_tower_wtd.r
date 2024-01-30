library(dplyr)
library(here)
library(ggplot2)

# Reads towers 
df <- read.csv("../data/towers/BAMS_site_coordinates.csv", stringsAsFactors = F)

#df1 <- df[c("ID",  "Year", "Month", "DOY", "WTD", "Class", "Biome")]

dfc  <- df1 %>%
      filter(!is.na(WTD)) %>%
      group_by(ID, Month, Class) %>%
      summarise(WTDmin = min(WTD, na.rm=T),
                WTDmean = mean(WTD, na.rm=T),
                WTDmax = max(WTD, na.rm=T))


ggplot(dfc) +
  geom_point(aes(x=Month, y=WTDmean, color=ID), size=0.5) +
  geom_line(aes(x=Month, y=WTDmean, color=ID), size=0.5) +
  geom_ribbon(aes(x=Month, ymin=WTDmin, ymax=WTDmax, fill=ID), alpha=0.3) +
  geom_hline(yintercept=0) +
  facet_wrap(~Class, nrow=2) +
  theme_bw() +
  theme(legend.position = "none") +
  ggtitle("Monthly WTD (min, mean, max) ")





### save plot
ggsave("../output/figures/wtd_monthly_site.png",
       width=190, height=120, dpi=300, units='mm', type = "cairo-png")

dev.off()

