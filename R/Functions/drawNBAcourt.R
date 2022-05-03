# Author: Cale Williams
# Last Updated: 01/26/2022
# Source: https://CRAN.R-project.org/package=BasketballAnalyzeR

# ADMINISTRATIVE WORK -----------------------------------------------------

# setwd('./MyProjects/NBA/R/Functions')

library(BasketballAnalyzeR)

shotchart.transformer <- function(data, col.x, col.y, nba.factor = 'Y',
                                  bar.shift = 'Y') {
  
  if (nba.factor == 'Y') {
    
    data[, col.x] <- data[, col.x] / (5 / 6 * 12)
    
    if (bar.shift == 'Y') {
      
      data[, col.y] <- data[, col.y] / (5 / 6 * 12) - 42.25
      
    } else {
      
      data[, col.y] <- dta[, col.y] / (5 / 6 * 12)
  
    }
    
  }
  
  return(data)
   
}

court.plotter <- function(fg.plot, full = FALSE, line.color = 'black',
                          line.size = 1.5, point.color = 'red',
                          point.size = 1) {
  
  shotchart <- drawNBAcourt(fg.plot, full = full, col = line.color,
                            size = line.size) +
    geom_point(color = point.color, size = point.size) +
    coord_fixed()
  
  return(shotchart)
  
}

court.plotter.lines <- function(fg.plot, full = FALSE, line.color = 'black',
                                line.size = 1.5, point.color = 'red',
                                point.size = 1) {
  
  shotchart <- drawNBAcourt(fg.plot, full = full, col = line.color,
                            size = line.size) +
    coord_fixed()
  
  return(shotchart)
  
}