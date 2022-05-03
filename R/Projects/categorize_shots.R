# Author: Cale Williams
# Last Updated: 01/28/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('./MyProjects/NBA/R/Shotcharts')

# Import libraries.
library(dplyr)
library(ggplot2)
library(ggthemes)

# Import function.
source('../Functions/drawNBAcourt.R')

# DATA PREPARATION --------------------------------------------------------

# Read in data.
shots <- read.csv('Dejounte-Murray.2021-22.csv',
                  header = TRUE)

# CATEGORIZE SHOTS --------------------------------------------------------     

# Create categories.
layups.cat <- c('Layup Shot', 'Driving Finger Roll Layup Shot',
                'Running Finger Roll Layup Shot', 'Driving Layup Shot',
                'Running Layup Shot', 'Tip Layup Shot',
                'Putback Layup Shot', 'Driving Reverse Layup Shot',
                'Cutting Layup Shot', 'Running Reverse Layup Shot',
                'Finger Roll Layup Shot', 'Reverse Layup Shot')

jumpshots.cat <- c('Jump Shot', 'Pullup Jump shot', 'Fadeaway Jump Shot',
                   'Turnaround Jump Shot', 'Step Back Jump shot',
                   'Floating Jump shot', 'Jump Bank Shot',
                   'Driving Floating Jump Shot', 'Running Jump Shot',
                   'Driving Floating Bank Jump Shot',
                   'Running Pull-Up Jump Shot',
                   'Turnaround Fadeaway Bank Jump Shot',
                   'Turnaround Fadeaway shot', 'Step Back Bank Jump Shot')      

hooks.cat <- c('Driving Hook Shot', 'Turnaround Hook Shot')

dunks.cat <- c('Driving Dunk Shot', 'Running Dunk Shot',
               'Cutting Dunk Shot', 'Running Alley Oop Dunk Shot')

# Verify all are accounted for.
assertthat::are_equal(length(unique(shots$ACTION_TYPE)),
                      sum(length(layups.cat), length(jumpshots.cat),
                          length(hooks.cat), length(dunks.cat)))

layups <- shots[shots$ACTION_TYPE %in% layups.cat, ]
jumpshots <- shots[shots$ACTION_TYPE %in% jumpshots.cat, ]
hooks <- shots[shots$ACTION_TYPE %in% hooks.cat, ]
dunks <- shots[shots$ACTION_TYPE %in% dunks.cat, ]

assertthat::are_equal(sum(nrow(layups), nrow(jumpshots), nrow(hooks),
                          nrow(dunks)), nrow(shots))



waffle::waffle(df$category)

var <- jumpshots$ACTION_TYPE[1:100]
nrows <- 10
df <- expand.grid(y = 1:nrows, x = 1:nrows)
categ_table <- round(table(var) * ((nrows*nrows)/(length(var))))
categ_table
#>   2seater    compact    midsize    minivan     pickup subcompact        suv 
#>         2         20         18          5         14         15         26 

df$category <- factor(rep(names(categ_table), categ_table))  
# NOTE: if sum(categ_table) is not 100 (i.e. nrows^2), it will need adjustment to make the sum to 100.

## Plot
ggplot(df, aes(x = x, y = y, fill = category)) + 
  geom_tile(color = "black", size = 0.5) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0), trans = 'reverse') +
  scale_fill_brewer(palette = "Set3") + 
  theme(panel.border = element_rect(size = 2),
        plot.title = element_text(size = rel(1.2)),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_blank(),
        legend.position = "right")
