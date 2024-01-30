
#  PM    ---------------------------------------------

FW_low_pm = seq(0, 0.149, 0.001)
FW_low_pm_cal = 4.4267*FW_low^3 + 1.3447*FW_low^2 + 0.4114*FW_low

FW_high_pm = seq(0.15, 1, 0.001)
FW_high_pm_cal = -0.4683*FW_high^2 + 1.0182*FW_high - 0.0548


FW_pm = c(FW_low_pm, FW_high_pm)
FW_pm_cal = c(FW_low_pm_cal, FW_high_pm_cal)




# AM      ------------------------------
FW_low_am = seq(0, 0.149, 0.001)
FW_low_am_cal = -23.752*FW_low^3 + 7.7518*FW_low^2 + 0.1565*FW_low

FW_high_am = seq(0.15, 1, 0.001)
FW_high_am_cal = -0.4014*FW_high^2 + 0.9837*FW_high - 0.0422


FW_am = c(FW_low_am, FW_high_am)
FW_am_cal = c(FW_low_am_cal, FW_high_am_cal)





## plot  ----------------------------------------------------

library(ggplot2)

ggplot()+
  
  geom_line(aes(x=FW_pm, y=FW_pm_cal), color="red") + 
  geom_line(aes(x=FW_am, y=FW_am_cal), color="blue") +   
  
  geom_abline(intercept=0, slope=1) +
  scale_x_continuous(limits=c(0,1), expand = c(0,0)) +
  scale_y_continuous(limits=c(0,1), expand = c(0,0)) +
  
  xlab("Original AMSR-E/2 surface water fraction (Fw)") +
  ylab("Surface water fraction (Fw) calibrated against MOD44W") +

  coord_equal() +
  
  theme_bw()



### save plot
ggsave("../output/figures/du2017_amsre2_fw_calibration.png",
       width=190, height=120, dpi=300, units='mm', type = "cairo-png")

dev.off()

