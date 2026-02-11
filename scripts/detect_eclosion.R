# This file contains custom functions to detect eclosion time
# See `eclosion_detection.Rmd` for details

library(zoo)
library(dplyr)

comp_roll_med <- function(data, k = 5, width = 24 * 6){
  out <- data %>%
    group_by(id) %>%
    mutate(
      # Rolling median
      roll_median = rollmedian(Median, k = k, fill =NA,  align = "center"),
      # Rolling median before
      med_before = rollapply(roll_median, width = width, FUN = mean, 
                             align = "right", fill = NA, partial = FALSE),
      # Rolling median after
      med_after = rollapply(roll_median, width = width, FUN = mean, 
                            align = "left", fill = NA, partial = FALSE),
      # Difference between before and after
      diff_medians = med_after - med_before
    ) %>%
    filter(!is.na(roll_median)) %>%
    ungroup()
  return(out)
}


get_ecl_time_each <- function(data, width = 24 * 6){
  t_switch_heuristic <- data[which.min(data$diff_medians),]$datetime
  data_pre <- subset(data, datetime < t_switch_heuristic)
  data_post <- subset(data, datetime >= t_switch_heuristic)
  data_pre <- data_pre[max(1, nrow(data_pre) - width):nrow(data_pre),]
  data_post <- data_post[1:min(nrow(data_post), width),]
  if(nrow(data_pre) < width | nrow(data_post) < width){
    return(NA)
  }
  return(ifelse(median(data_pre$roll_median) > median(data_post$roll_median) & wilcox.test(data_pre$roll_median, data_post$roll_median)$p.value < 0.01 , t_switch_heuristic, NA))
}



get_ecl_time <- function(data, width = 24 * 6, tz = "Etc/GMT-1"){
  out <- data.frame(id = unique(data$id), ecl_time = sapply(unique(data$id),
                                                function(id){
                                                  d_sub <- data[data$id == id,]
                                                  return(get_ecl_time_each(d_sub))
                                                })
  )
  out$ecl_time <- as.POSIXct(out$ecl_time, tz = tz)
  return(out)
}




