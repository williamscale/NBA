
draft.season <- function(season) {
  
  library(rvest)
  library(dplyr)
  library(tidyverse)
  
  # team_table Reference
  # 1: 
  # 2: 
  # 3: 
  # 4: 
  
  season.url <- paste('https://www.basketball-reference.com/draft/NBA_',
                      season,
                      '.html',
                      sep = '')

  
  page.data <- season.url %>%
    read_html() %>%
    html_table()
  
  draft.picks <- page.data[[1]]
  
  names(draft.picks) <- as.matrix(draft.picks[1, ])
  draft.picks <- draft.picks[-1, ]
  
  num.cols <- c(1:2, 6:ncol(draft.picks))
  
  draft.picks[, num.cols] <- sapply(draft.picks[, num.cols], as.numeric)
  
  draft.picks <- draft.picks %>%
    drop_na(Rk)
  
  return(draft.picks)
  
}

# TESTING -----------------------------------------------------------------

# x <- draft.season(season = '1980')

