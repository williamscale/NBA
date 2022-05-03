# Author: Cale Williams
# Last Updated: 01/07/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('MyProjects/NBA/R/Projects')

library(ggplot2)

# DATA PREPARATION --------------------------------------------------------

# Read in raw data.
data <- read.csv('shots_data.csv')

# Calculate shot distance.
data$distance <- sqrt(data$x ^ 2 + data$y ^ 2)

# SPLIT SHOTS BY ZONE -----------------------------------------------------

# Define corner 3 x and y bounds.
c3_x <- 22
c3_y <- 7.8

# Create dataframe of corner 3 shots.
c3 <- data[(data$x < -c3_x & data$y <= c3_y) | (data$x > c3_x & data$y <= c3_y), ]

# Define non-corner 3 shot distance bound.
nc3_d <- 23.75

# Calculate y-value of non-corner 3 to corner 3 intercept.
c_intercept <- sqrt(nc3_d ** 2 - c3_x ** 2)

# Create dataframe of non-corner 3 shots.
nc3 <- data[(data$x < -c3_x & data$y < c_intercept & data$y > c3_y) |
              (data$x > c3_x & data$y < c_intercept & data$y > c3_y) |
              (data$y >= c_intercept & data$distance > nc3_d), ]

# Create vector of indices of all 3s.
idx3 <- as.numeric(append(rownames(c3), rownames(nc3)))

# Create dataframe of 2s.
pt2 <- data[-idx3, ]

# Verify lengths.
assertthat::are_equal(nrow(data), sum(nrow(c3), nrow(nc3), nrow(pt2)))

# CALCULATE EFG% ----------------------------------------------------------

A_c3_eFG <- 1.5 * sum(c3[c3$team == 'Team A', 'fgmade']) / nrow(c3[c3$team == 'Team A', ])
B_c3_eFG <- 1.5 * sum(c3[c3$team == 'Team B', 'fgmade']) / nrow(c3[c3$team == 'Team B', ])

A_nc3_eFG <- 1.5 * sum(nc3[nc3$team == 'Team A', 'fgmade']) / nrow(nc3[nc3$team == 'Team A', ])
B_nc3_eFG <- 1.5 * sum(nc3[nc3$team == 'Team B', 'fgmade']) / nrow(nc3[nc3$team == 'Team B', ])

A_pt2_eFG <- sum(pt2[pt2$team == 'Team A', 'fgmade']) / nrow(pt2[pt2$team == 'Team A', ])
B_pt2_eFG <- sum(pt2[pt2$team == 'Team B', 'fgmade']) / nrow(pt2[pt2$team == 'Team B', ])

# PLOT SHOTS --------------------------------------------------------------

ggplot(NULL, aes(x, y)) +
  geom_point(data = c3) +
  geom_point(data = nc3, color = 'blue') +
  geom_point(data = pt2, color = 'red')

