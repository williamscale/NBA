# Author: Cale Williams
# Last Updated: 07/02/2022

# Import libraries.
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(cowplot)
library(hexbin)

# FUNCTION ----------------------------------------------------------------

## BY PLAYER --------------------------------------------------------------

shotchart.kde.plotter <- function(data.transformed) {
  
  player <- data.transformed$PLAYER_NAME[1]
  
  fg.halfcourt <- data.transformed %>%
    filter(LOC_Y <= 0)
  
  kde.plot <- ggplot(data = fg.halfcourt,
                     aes(x = LOC_X,
                         y = LOC_Y)) +
    geom_density_2d_filled(alpha = 1) +
    geom_density_2d(color = 'white')
  
  dens.plot <- court.plotter.lines(fg.plot = kde.plot) +
    ggtitle(paste(player, '\nFGA Density Plot')) +
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
          legend.position = 'none')
  
  return(dens.plot)

}

## BY TEAM ----------------------------------------------------------------

shotchart.team.kde.plotter <- function(data.transformed, team) {
  
  fg.halfcourt <- data.transformed %>%
    filter(LOC_Y <= 0,
           TEAM_NAME == team)
  
  team.id <- fg.halfcourt$TEAM_NAME[1]
  
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
          legend.position = 'none')
  
  return(dens.plot)
  
}

# TESTING -----------------------------------------------------------------

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Functions')

# Import functions.
source('../Functions/drawNBAcourt.R')


## shotchart.kde.plotter() ------------------------------------------------

# # Read in data.
# shots <- read.csv('./../Shotcharts/2021-22/RegularSeason/P.J.-Tucker.2021-22.csv',
#                   header = TRUE)
# 
# 
# # Transform shot locations.
# shots.t <- shotchart.transformer(data = shots,
#                                  col.x = 'LOC_X',
#                                  col.y = 'LOC_Y')
# 
# shotchart.kde.plotter(data.transformed = shots.t)


## shotchart.team.kde.plotter() -------------------------------------------

# load('./../Shotcharts/2021-22/RegularSeason/regularseason_2021-22.RData')
# 
# shotchart.team.kde.plotter(data.transformed = data,
#                            team = 'Chicago Bulls')


