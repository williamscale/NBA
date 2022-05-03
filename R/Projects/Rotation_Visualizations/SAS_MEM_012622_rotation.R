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
lineups <- read_excel('SAS_MEM_012622.xlsx',
                      sheet = 'Lineups')

# Remove irrelevant columns.
lineups <- lineups %>%
  select(c(-1, -2))

# Trim white space.
lineups <- lineups %>%
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



