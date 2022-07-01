# Author: Cale Williams
# Last Updated: 07/01/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Import libraries.
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(cowplot)

# DATA PREPARATION --------------------------------------------------------

shotchart.bivariate.plotter <- function(data.transformed) {
  
  player <- data.transformed$PLAYER_NAME[1]
  
  fg.halfcourt <- data.transformed %>%
    filter(LOC_Y <= 0)
  
  # Bin court by delta.
  delta <- 2
  bin.x.breaks <- seq(-25, 25, by = delta)
  bin.y.breaks <- seq(-47, 0, by = delta)
  
  # Assign points to bin.
  fg.halfcourt.bin <- fg.halfcourt %>%
    mutate(bin.x = cut(LOC_X, breaks = bin.x.breaks),
           bin.y = cut(LOC_Y, breaks = bin.y.breaks)) %>%
    group_by(bin.x, bin.y)
  
  
  # Count made FGs in each bin.
  fg.bin.m <- aggregate(SHOT_MADE_FLAG ~ bin.x + bin.y,
                        data = fg.halfcourt.bin,
                        FUN = sum)
  
  # Count total FGs in each bin.
  fg.bin.a <- aggregate(SHOT_ATTEMPTED_FLAG ~ bin.x + bin.y,
                        data = fg.halfcourt.bin,
                        FUN = sum)
  
  # Combine and calculate FG% by bin.
  fg.eff <- merge(fg.bin.m, fg.bin.a, by = c('bin.x', 'bin.y'))
  fg.eff$bin.eff <- fg.eff$SHOT_MADE_FLAG / fg.eff$SHOT_ATTEMPTED_FLAG
  
  # Extract bin boundaries and add to dataframe.
  cx <- cbind(x.lower = as.numeric(sub('\\((.+),.*', '\\1', fg.eff$bin.x) ),
              x.upper = as.numeric(sub('[^,]*,([^]]*)\\]', '\\1', fg.eff$bin.x) ))
  cy <- cbind(y.lower = as.numeric(sub('\\((.+),.*', '\\1', fg.eff$bin.y) ),
              y.upper = as.numeric(sub('[^,]*,([^]]*)\\]', '\\1', fg.eff$bin.y) ))
  fg.eff <- cbind(fg.eff, cx, cy)
  
  # Calculate middle of bin.
  fg.eff$center.x <- rowMeans(fg.eff[, c('x.lower', 'x.upper')])
  fg.eff$center.y <- rowMeans(fg.eff[, c('y.lower', 'y.upper')])
  
  # Split FG% into < 40%, > 40% & < 60%, and > 60%. 
  quantiles.eff <- c(0, 0.40, 0.60, 1)
  
  # If a player has 1, 2, or 3 FGA...
  if (max(fg.eff$SHOT_ATTEMPTED_FLAG) == 1) {
    
    # Generate quantiles so that there are no ties.
    quantiles.rate = c(0, 0.25, 0.5, 1)
  } else if (max(fg.eff$SHOT_ATTEMPTED_FLAG) == 2) {
    quantiles.rate = c(0, 0.5, 1.5, 2)
  } else if (max(fg.eff$SHOT_ATTEMPTED_FLAG) == 3) {
    quantiles.rate = c(0, 1, 2, 3)
    
    # If the player has >= 4FGA...
  } else {
    
    # Generate quantiles.
    quantiles.rate <- fg.eff %>%
      pull(SHOT_ATTEMPTED_FLAG) %>%
        quantile(prob = seq(0, 1, length.out = 4))
  }
  
  # # I don't remember what this is for. Might not need it anymore.
  quantiles.rate[2:4] <- quantiles.rate[2:4] + seq_along(quantiles.rate[2:4]) * .Machine$double.eps
  
  # Assign colors to each outcome.
  bivariate_color_scale <- tibble('3 - 3' = '#2a5a5b',
                                  '2 - 3' = '#5a9178',
                                  '1 - 3' = '#73ae80',
                                  '3 - 2' = '#567994',
                                  '2 - 2' = '#90b2b3',
                                  '1 - 2' = '#b8d6be',
                                  '3 - 1' = '#6c83b5',
                                  '2 - 1' = '#b5c0da',
                                  '1 - 1' = '#e8e8e8') %>%
    gather('group', 'fill')

  # Associate bin with group/color. 
  fg.eff <- fg.eff %>%
    mutate(eff_quantiles = cut(bin.eff,
                               breaks = quantiles.eff,
                               include.lowest = TRUE),
           rate_quantiles = cut(SHOT_ATTEMPTED_FLAG,
                                breaks = quantiles.rate,
                                include.lowest = TRUE),
           group = paste(as.numeric(eff_quantiles), '-', as.numeric(rate_quantiles))) %>%
    left_join(bivariate_color_scale, by = "group")
  
  # Create data for legend.
  bivariate_color_scale %<>%
    separate(group, into = c('LOC_X', 'LOC_Y'), sep = ' - ') %>%
    mutate(LOC_X = as.integer(LOC_X),
           LOC_Y = as.integer(LOC_Y))

  # Create legend.
  legend <- ggplot() +
    geom_tile(data = bivariate_color_scale,
              mapping = aes(x = LOC_X,
                            y = LOC_Y,
                            fill = fill)) +
    scale_fill_identity() +
    labs(x = paste('Higher FG%', sprintf('\u2192')),
         y = paste('Higher Frequency', sprintf('\u2192'))) +
    theme_solarized_2() +
    theme(axis.title = element_text(size = 10),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = '#eee8d5')) +
    coord_fixed()
  
  eff.plot <- ggplot(fg.eff,
                     aes(x = center.x,
                         y = center.y,
                         height = delta,
                         width = delta)) +
    geom_tile(data = fg.eff,
              aes(fill = fill),
              color = 'black') +
    ggtitle(paste(player, '\nBivariate Shot Chart')) +
    scale_fill_identity()

  heatmap <- court.plotter.lines(eff.plot, line.size = 1.5) +
    theme_solarized_2() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = '#eee8d5'))
  
  bv.plot <- ggdraw() +
    draw_plot(heatmap) +
    draw_plot(legend, 0.10, 0.67, 0.22, 0.22)

  return(bv.plot)
  
}
  
  

# TESTING -----------------------------------------------------------------

# setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Functions')
# 
# # Read in data.
# shots <- read.csv('./../Shotcharts/2021-22/RegularSeason/P.J.-Tucker.2021-22.csv',
#                   header = TRUE)
# 
# # Import functions.
# source('../Functions/drawNBAcourt.R')
# 
# # Transform shot locations.
# shots.t <- shotchart.transformer(data = shots,
#                                  col.x = 'LOC_X',
#                                  col.y = 'LOC_Y')
# 
# shotchart.bivariate.plotter(shots.t)











