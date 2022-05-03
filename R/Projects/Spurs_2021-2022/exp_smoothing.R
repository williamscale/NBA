# Author: Cale Williams
# Last Updated: 01/07/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

# Import libraries.
library(readxl)
library(dplyr)
library(stringr)
library(stats)
library(ggplot2)

setwd('MyProjects/NBA/R/Projects/Spurs_2021-2022')

source('../../Scrapers/bballref_playerlinks.R')
source('../../Scrapers/bballref_player.R')

# PREPARE DATA ------------------------------------------------------------

# Get all players listed in basketball reference.
players <- player_url_bballref(player = 'ALL')

MurrayDejounte <- players[players$player_name == 'Dejounte Murray', ]


