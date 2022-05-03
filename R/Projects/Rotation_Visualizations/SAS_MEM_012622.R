# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

# Import libraries.
library(readxl)
library(dplyr)
library(stringr)

# Set working directory.
setwd('./MyProjects/NBA/R/Projects/Rotation_Visualizations/')

# Read in data.
sas.net.ratings <- read_excel('SAS_MEM_012622.xlsx',
                              sheet = 'SAS')

mem.net.ratings <- read_excel('SAS_MEM_012622.xlsx',
                              sheet = 'MEM')

lineups <- read_excel('SAS_MEM_012622.xlsx',
                      sheet = 'Lineups')

# Remove irrelevant columns.
lineups <- lineups %>%
  select(c(-1, -2))

# Trim white space.
lineups <- lineups %>%
  mutate(across(where(is.character), str_trim))

sas.net.ratings <- sas.net.ratings %>%
  mutate(across(where(is.character), str_trim))

mem.net.ratings <- mem.net.ratings %>%
  mutate(across(where(is.character), str_trim))

# Create dataframe for each team.
sas.lineups <- lineups[, c('Time', 'SAS1', 'SAS2', 'SAS3', 'SAS4', 'SAS5')]
mem.lineups <- lineups[, c('Time', 'MEM1', 'MEM2', 'MEM3', 'MEM4', 'MEM5')]

dup <- c()

for (i in 2:nrow(sas.lineups)) {
  
  if (sas.lineups[i, 'Time'] == sas.lineups[i - 1, 'Time']) {
    
    dup <- c(dup, i)
    
  }
  
}

keep <- c()

for (i in 1:(length(dup)-1)) {
  
  if ((dup[i + 1] - dup[i]) != 1) {
    
    keep <- c(keep, dup[i])
  }
  
}

sas.lineups.f <- sas.lineups[c(1, keep), ]

# dup <- c()
# 
# for (i in 2:nrow(mem.lineups)) {
#   
#   if (mem.lineups[i, 'Time'] == mem.lineups[i - 1, 'Time']) {
#     
#     dup <- c(dup, i)
#     
#   }
#   
# }
# 
# keep <- c()
# 
# for (i in 1:(length(dup)-1)) {
#   
#   if ((dup[i + 1] - dup[i]) != 1) {
#     
#     keep <- c(keep, dup[i])
#   }
#   
# }
# 
# mem.lineups.f <- mem.lineups[keep, ]




sas.net.rating.i <- c()

for (i in 1:nrow(sas.lineups.f)) {
  
  lineup.i <- sas.lineups.f %>%
    slice(i) %>%
    select(-1) %>%
    unlist(use.names = FALSE)
  
  print(i)
  
  for (j in 1:nrow(sas.net.ratings)) {
    
    lineup.j <- sas.net.ratings %>%
      slice(j) %>%
      select('Player 1': 'Player 5') %>%
      unlist(use.names = FALSE)
    
    if (length(intersect(lineup.i, lineup.j)) == 5) {
      
      net.rating.i <- sas.net.ratings %>%
        slice(j) %>%
        select('PTS') %>%
        unlist(use.names = FALSE)
      
      sas.net.rating.i <- c(sas.net.rating.i, net.rating.i)
      
      print("GOOD")
      
    }
    
  }
  
}

sas.lineups.f$NetRating <- sas.net.rating.i

x <- sas.lineups %>%
  slice(1) %>%
  select(-1) %>%
  unlist(use.names = FALSE)

y <- sas.net.ratings %>%
  slice(1) %>%
  select(1:5) %>%
  unlist(use.names = FALSE)




# sas.lineups$union <- paste(sas.lineups$SAS1)

for (i in 1:nrow(sas.lineups)) {
  
  lineup.i <- c(sas.lineups[i, 'SAS1'], sas.lineups[i, 'SAS2'],
                sas.lineups[i, 'SAS3'], sas.lineups[i, 'SAS4'],
                sas.lineups[i, 'SAS5'])
  
  print(lineup.i)
  
}

# cl <- c(sas.lineups$SAS1, sas.lineups$SAS2, sas.lineups$SAS3, sas.lineups$SAS4, sas.lineups$SAS5)
# cr <- c(sas.net.ratings$`Player 1`, sas.net.ratings$`Player 2`, sas.net.ratings$`Player 3`, sas.net.ratings$`Player 4`, sas.net.ratings$`Player 5`)
