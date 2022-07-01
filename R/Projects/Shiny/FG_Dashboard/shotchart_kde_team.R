# Author: Cale Williams
# Last Updated: 06/23/2022

# Import libraries.
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(cowplot)
library(hexbin)

# FUNCTION ----------------------------------------------------------------

shotchart.kde.team.plotter <- function(data.transformed) {
  
  # if (nrow(data.transformed) < 25) {stop('Too few datapoints for relevant plot.')}
  
  player <- data.transformed$PLAYER_NAME[1]
  team <- data.transformed$TEAM_NAME[1]
  
  fg.halfcourt <- data.transformed %>%
    filter(LOC_Y <= 0)
  
  kde.plot <- ggplot(data = fg.halfcourt,
                     aes(x = LOC_X,
                         y = LOC_Y)) +
    geom_density_2d_filled(alpha = 1) +
    geom_density_2d(color = 'white')
  
  dens.plot <- court.plotter.lines(fg.plot = kde.plot) +
    ggtitle(paste(team, '\nFGA Density Plot')) +
    theme_solarized_2() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = '#eee8d5'),
          legend.position = 'none',
          plot.title = element_text(size = 20, face = 'bold'))
  
  return(dens.plot)

}

# TESTING -----------------------------------------------------------------

# setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Functions')
# 
# # Import functions.
# source('../Functions/drawNBAcourt.R')
# #
# # # Read in data.
# shots <- read.csv('./../Shotcharts/2021-22/Dejounte-Murray.2021-22.csv',
#                   header = TRUE)
# 
# #
# # # Transform shot locations.
# shots.t <- shotchart.transformer(data = shots,
#                                  col.x = 'LOC_X',
#                                  col.y = 'LOC_Y')
# 
# shotchart.kde.plotter(data.transformed = shots.t)




