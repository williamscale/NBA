# Author: Cale Williams
# Last Updated: 01/28/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Shotcharts')

# Import libraries.
library(dplyr)
library(ggplot2)
library(ggthemes)
library(gridExtra)

# Import function.
source('../Functions/drawNBAcourt.R')

# DATA PREPARATION --------------------------------------------------------

# Read in data.
shots <- read.csv('Doug-McDermott.2021-22.csv',
                  header = TRUE)

# Transform shot locations.
shots.t <- shotchart.transformer(data = shots,
                                 col.x = 'LOC_X',
                                 col.y = 'LOC_Y')

fg.m <- shots.t %>%
  filter(SHOT_MADE_FLAG == 1)

fg.a <- shots.t %>%
  filter(SHOT_MADE_FLAG == 0)


fg.m.p <- ggplot(data = fg.m,
                 aes(x = LOC_X,
                     y = LOC_Y))

fg.a.p <- ggplot(data = fg.a,
                 aes(x = LOC_X,
                     y = LOC_Y))

fg.p <- ggplot(data = shots.t,
               aes(x = LOC_X,
                   y = LOC_Y,
                   z = SHOT_MADE_FLAG)) +
  coord_fixed()

heat <- fg.p +
  stat_summary_2d(bins = 10,
                  fun = 'mean')

# made
made <- court.plotter(fg.plot = fg.m.p,
              point.color = 'darkgreen') +
  ggtitle('Doug McDermott 2021-22') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# missed
missed <- court.plotter(fg.plot = fg.a.p,
              point.color = 'red') +
  ggtitle('Doug McDermott 2021-22') +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

grid.arrange(heat, made, missed, ncol = 3)

# 
# court.plotter(fg.plot = fg.m.p,
#               point.color = '#00B2A9') +
#   ggtitle('Doug McDermott 2021-22') +
#   theme_solarized_2() +
#   theme(axis.title.x = element_blank(),
#         axis.title.y = element_blank(),
#         axis.text.x = element_blank(),
#         axis.text.y = element_blank(),
#         axis.ticks.x = element_blank(),
#         axis.ticks.y = element_blank(),
#         panel.grid.major = element_blank(),
#         panel.grid.minor = element_blank())






