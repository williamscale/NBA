# Author: Cale Williams
# Last Updated: 02/13/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Projects/KeldonJohnson_ShotDistribution')

# Import libraries.
library(ggplot2)
library(ggthemes)
library(readxl)
library(dplyr)
library(tidyr)
library(scales)

# Read in data.
data <- read_excel('kjohnson_3fga.xlsx')

colnames(data) <- c('g', 'fgm', 'fga', 'fg3m', 'fg3a')

# Create new variables.
data$fg2a <- data$fga - data$fg3a
data$fg2m <- data$fgm - data$fg3m

# PROPORTION OF FGA -------------------------------------------------------

data.prop <- data
data.prop$FG2MAKE <- cumsum(data.prop$fg2m) / cumsum(data.prop$fga)
data.prop$FG2MISS <- (cumsum(data.prop$fg2a) - cumsum(data.prop$fg2m)) / cumsum(data.prop$fga)
data.prop$FG3MAKE <- cumsum(data.prop$fg3m) / cumsum(data.prop$fga)
data.prop$FG3MISS <- (cumsum(data.prop$fg3a) - cumsum(data.prop$fg3m)) / cumsum(data.prop$fga)

# Verify math is correct.
data.prop$check1 <- rowSums(data.prop[, 8:11])
assertthat::are_equal(max(data.prop$check1), 1)
assertthat::are_equal(min(data.prop$check1), 1)

# Delete unnecessary column.
data.prop <- data.prop %>%
  select(-check1)

data.prop <- pivot_longer(data = data.prop,
                          cols = c('FG2MAKE', 'FG2MISS', 'FG3MAKE', 'FG3MISS'),
                          names_to = 'Shot.Class',
                          values_to = 'Proportion')

ggplot(data = data.prop,
       aes(x = g,
           y = Proportion,
           fill = Shot.Class)) +
  geom_area(color = 'black') +
  xlab('Game') +
  ylab('Average Proportion of FGA') +
  scale_fill_manual(values = c('#EF426F', '#00B2A9', '#FF8200', '#8A8D8F')) +
  theme_solarized_2()

# RAW FGA -----------------------------------------------------------------

data.fga <- data
data.fga$FGA.CUMMEAN <- cumsum(data.fga$fga) / data.fga$g
data.fga$FG3A.CUMMEAN <- cumsum(data.fga$fg3a) / data.fga$g

data.fga <- pivot_longer(data = data.fga,
                         cols = c('FGA.CUMMEAN', 'FG3A.CUMMEAN'),
                         names_to = 'FG Class',
                         values_to = 'Total')

ggplot(data = data.fga,
       aes(x = g, y = Total)) +
  geom_line(aes(color = `FG Class`),
            size = 2) +
  scale_color_manual(values = c('#EF426F', '#00B2A9')) +
  ylim(0, 17) +
  xlab('Game') +
  ylab('Average FGA') +
  theme_solarized_2() +
  theme(legend.position = 'bottom')


ggplot(data = data,
       aes(x = g,
           y = fg3a)) +
  geom_point() +
  geom_smooth(color = '#EF426F',
              size = 1.5) +
  xlab('Game') +
  ylab('FG3A') +
  scale_y_continuous(breaks = pretty_breaks()) +
  theme_solarized_2()
