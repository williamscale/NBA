# Author: Cale Williams
# Last Updated: 01/02/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('MyProjects/NBA/R/Projects/OKCThunder_DS&S')

# DATA PREPARATION --------------------------------------------------------

# Read in raw data.
data <- read.csv('shots_data.csv')

# Calculate shot distance.
data$distance <- sqrt(data$x ^ 2 + data$y ^ 2)

shot_2PT <- c()
shot_NC3 <- c()
shot_C3 <- c()

# Classify shots.
# There is probably a much more efficient method.
for (i in 1:nrow(data)) {
  
  if (data$x[i] <= 22 && data$x[i] >= -22 && data$y[i] <= 7.8) {
    
    shot_2PT <- c(shot_2PT, 1)
    shot_NC3 <- c(shot_NC3, 0)
    shot_C3 <- c(shot_C3, 0)
    
  } else if (data$x[i] < -22 || data$x[i] > 22 && data$y[i] <= 7.8) {
    
    shot_2PT <- c(shot_2PT, 0)
    shot_NC3 <- c(shot_NC3, 0)
    shot_C3 <- c(shot_C3, 1)
    
  } else if (data$y[i] > 7.8 && data$distance[i] > 23.75) {
    
    shot_2PT <- c(shot_2PT, 0)
    shot_NC3 <- c(shot_NC3, 1)
    shot_C3 <- c(shot_C3, 0) 
    
  } else if (data$x[i] < -22 || data$x[i] > 22 && data$y[i] >= 7.8 && data$distance[i] <= 23.75) {
    
    shot_2PT <- c(shot_2PT, 0)
    shot_NC3 <- c(shot_NC3, 1)
    shot_C3 <- c(shot_C3, 0)
    
  } else {
    
    shot_2PT <- c(shot_2PT, 1)
    shot_NC3 <- c(shot_NC3, 0)
    shot_C3 <- c(shot_C3, 0)
    
  }
    
}

data$shot_2PT <- shot_2PT
data$shot_NC3 <- shot_NC3
data$shot_C3 <- shot_C3

# Split data by team.
A <- data[data$team == 'Team A', ]
B <- data[data$team == 'Team B', ]

A_shot_2PT_dist <- sum(A$shot_2PT) / nrow(A)
A_shot_NC3_dist <- sum(A$shot_NC3) / nrow(A)
A_shot_C3_dist <- sum(A$shot_C3) / nrow(A)

B_shot_2PT_dist <- sum(B$shot_2PT) / nrow(B)
B_shot_NC3_dist <- sum(B$shot_NC3) / nrow(B)
B_shot_C3_dist <- sum(B$shot_C3) / nrow(B)

A_2PT <- A[A$shot_2PT == 1, ]
A_NC3 <- A[A$shot_NC3 == 1, ]
A_C3 <- A[A$shot_C3 == 1, ]

B_2PT <- B[B$shot_2PT == 1, ]
B_NC3 <- B[B$shot_NC3 == 1, ]
B_C3 <- B[B$shot_C3 == 1, ]

A_eFG_2PT <- sum(A_2PT$fgmade) / nrow(A_2PT)
B_eFG_2PT <- sum(B_2PT$fgmade) / nrow(B_2PT)

A_eFG_NC3 <- 1.5 * sum(A_NC3$fgmade) / nrow(A_NC3)
B_eFG_NC3 <- 1.5 * sum(B_NC3$fgmade) / nrow(B_NC3)

A_eFG_C3 <- 1.5 * sum(A_C3$fgmade) / nrow(A_C3)
B_eFG_C3 <- 1.5 * sum(B_C3$fgmade) / nrow(B_C3)

