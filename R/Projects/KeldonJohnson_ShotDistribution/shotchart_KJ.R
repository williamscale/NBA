# Author: Cale Williams
# Last Updated: 01/28/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Projects/KeldonJohnson_ShotDistribution')

# Import libraries.
library(dplyr)
library(ggplot2)
library(ggthemes)
library(hexbin)

# Import function.
source('../../Functions/drawNBAcourt.R')

# DATA PREPARATION --------------------------------------------------------

# Read in data.
shots <- read.csv('Keldon-Johnson.2021-22.csv',
                  header = TRUE)

# Transform shot locations.
shots.t <- shotchart.transformer(data = shots,
                                 col.x = 'LOC_X',
                                 col.y = 'LOC_Y')

fg.m <- shots.t %>%
  filter(SHOT_MADE_FLAG == 1)

fg.a <- shots.t %>%
  filter(SHOT_MADE_FLAG == 0)

# PLOT --------------------------------------------------------------------

# Plot all field goals.
fg.plotter <- ggplot(data = fg.m,
                   aes(x = LOC_X,
                       y = LOC_Y)) +
  geom_point(data = fg.a,
             color = '#EF426F',
             shape = 4,
             size = 1.5)

court.plotter(fg.plot = fg.plotter,
              point.color = '#00B2A9',
              point.size = 1.5) +
  ggtitle('Keldon Johnson 2021-22, FG') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# Plot first heatmap.
heaterbin1 <- ggplot(shots.t[1:310, ],
                     aes(x = LOC_X,
                         y = LOC_Y),
                     fill = ..count..) +
  geom_hex(bins = 20) +
  scale_fill_continuous(lim = c(3, 25),
                        na.value = NA,
                        type = 'viridis')

court.plotter.lines(fg.plot = heaterbin1) +
  ggtitle('Keldon Johnson 2021-22 Games 1-26 \nMost Common FGA Locations') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# Plot second heatmap.
heaterbin2 <- ggplot(shots.t[311:nrow(shots.t), ],
                     aes(x = LOC_X,
                         y = LOC_Y),
                     fill = ..count..) +
  geom_hex(bins = 20) +
  scale_fill_continuous(lim = c(3, 25),
                        na.value = NA,
                        type = 'viridis')

court.plotter.lines(fg.plot = heaterbin2) +
  ggtitle('Keldon Johnson 2021-22 Games 27-53 \nMost Common FGA Locations') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
