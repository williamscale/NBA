
summarize.season <- function(season) {
  
  library(rvest)
  library(dplyr)
  
  # team_table Reference
  # 1: 
  # 2: 
  # 3: 
  # 4: 
  
  season.url <- paste('https://www.basketball-reference.com/leagues/NBA_',
                      season,
                      '.html',
                      sep = '')
  
  page.data <- season.url %>%
    read_html() %>%
    html_table()
  
  e.standings <- page.data[[1]]
  w.standings <- page.data[[2]]
  
  if (as.numeric(season) < 2016) {
    
    e.standings <- e.standings[!is.na(as.numeric(as.character(e.standings$W))), ]
    w.standings <- w.standings[!is.na(as.numeric(as.character(w.standings$W))), ]
    
    colnames(e.standings)[1] <- 'Team'
    colnames(w.standings)[1] <- 'Team'
    
    standings <- rbind(e.standings, w.standings)
    
    totals <- page.data[[5]]
    totals.opp <- page.data[[6]]
    
    totals <- totals[totals$Team != 'League Average', ]
    totals.opp <- totals.opp[totals.opp$Team != 'League Average', ]
    
  } else {
    
    colnames(e.standings)[1] <- 'Team'
    colnames(w.standings)[1] <- 'Team'
    
    standings <- rbind(e.standings, w.standings)
    
    totals <- page.data[[7]]
    totals.opp <- page.data[[8]]
    
    totals <- totals[totals$Team != 'League Average', ]
    totals.opp <- totals.opp[totals.opp$Team != 'League Average', ]
    
  }
  
  colnames(totals.opp)[-2] <- paste(colnames(totals.opp)[-2], 'OPP', sep = '.')
  season.summary <- merge(standings, totals, by = 'Team')
  
  season.summary <- merge(season.summary, totals.opp, by = 'Team')
  
  # season.summary <- season.summary %>%
  #   select(-c(GB, Rk, Rk.OPP))
    
  return(season.summary)
  
}

# TESTING -----------------------------------------------------------------

# x <- summarize.season(season = '2022')

