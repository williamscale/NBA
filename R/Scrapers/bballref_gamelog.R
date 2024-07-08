# setwd('./MyProjects/NBA/R/Scrapers')

player_gamelog <- function(player, season, last.init) {
  
  setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Scrapers')
  source('bballref_playerlinks.R')
  
  
  library(rvest)
  library(stringi)
  library(ggplot2)
  library(plotly)
  library(ggthemes)
  library(dplyr)

  players <- player_url_bballref(player = player, last.init = last.init)

  season <- season
  
  gamelog.url <- paste(substr(x = players$player_url,
                              start = 1,
                              stop = nchar(players$player_url) - 5),
                       '/gamelog/',
                       season,
                       sep = '')
  
  gamelog <- gamelog.url %>%
    read_html() %>%
    html_table() %>%
    .[[8]]
  
  gamelog <- gamelog[gamelog$Rk != 'Rk', ]
  
  gamelog.gp <- gamelog[!is.na(as.numeric(as.character(gamelog$G))), ]

  # gamelog.gp$G <- as.numeric(gamelog.gp$G)
  # gamelog.gp$PTS <- as.numeric(gamelog.gp$PTS)
  # gamelog.gp$TRB <- as.numeric(gamelog.gp$TRB)
  # 
  # pts.g <- mean(gamelog.gp$PTS)
  # trb.g <- mean(gamelog.gp$TRB)
  # 
  # ggplot(data = gamelog.gp,
  #        aes(x = G,
  #            y = TRB)) +
  #   geom_line() +
  #   geom_hline(yintercept = trb.g) +
  #   theme_solarized_2()
  
  return(gamelog)
}

# TESTING -----------------------------------------------------------------

# x <- player_gamelog(player = 'Keldon Johnson', season = '2022', last.init = 'j')
