# Author: Cale Williams
# Last Updated: 02/15/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Shotcharts')

# Import libraries.
library(dplyr)
library(ggplot2)
library(ggthemes)
# library(hexbin)

# Import function.
source('../Functions/drawNBAcourt.R')

# DATA PREPARATION --------------------------------------------------------

# Read in data.
shots <- read.csv('Jakob-Poeltl.2021-22.csv',
                  header = TRUE)

# Transform shot locations.
shots.t <- shotchart.transformer(data = shots,
                                 col.x = 'LOC_X',
                                 col.y = 'LOC_Y')

fg.m <- shots.t %>%
  filter(SHOT_MADE_FLAG == 1)

fg.a <- shots.t %>%
  filter(SHOT_MADE_FLAG == 0)

title.template <- 'Jakob Poeltl 2021-22'

# CREATE SHOTCHART --------------------------------------------------------

fg.all.shotchart <- ggplot(data = fg.m,
                           aes(x = LOC_X,
                               y = LOC_Y)) +
  geom_point(data = fg.a,
             color = '#EF426F',
             shape = 4,
             size = 1.5)

court.plotter(fg.plot = fg.all.shotchart,
              point.color = '#00B2A9',
              point.size = 1.5) +
  ggtitle('Jakob Poeltl 2021-22, FG') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# CREATE HEATMAP ----------------------------------------------------------

# Create hexbin plot of attempted field goals.
# Remove bins with 5 <= count <= 50.
fg.all.heatmap <- ggplot(shots.t,
                         aes(x = LOC_X,
                             y = LOC_Y),
                         fill = ..count..) +
  geom_hex(bins = 20) +
  scale_fill_continuous(lim = c(5, 180),
                        na.value = NA,
                        type = 'viridis')

court.plotter.lines(fg.plot = fg.all.heatmap) +
  ggtitle('Jakob Poeltl 2021-22\nMost Common FGA Locations') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# CREATE DENSITY PLOT -----------------------------------------------------

fg.all.density <- ggplot(shots.t,
                         aes(x = LOC_X,
                             y = LOC_Y)) +
  stat_density_2d(aes(fill = ..level..),
                  geom = 'polygon')

court.plotter.lines(fg.plot = fg.all.density) +
  ggtitle('Keldon Johnson 2021-22 Games 1-26\nMost Common FGA Locations') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
