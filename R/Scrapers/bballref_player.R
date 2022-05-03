
player_bballref <- function(player_url, player_table = 1) {
  
  library(rvest)
  
  # player_table Reference
  # 1: Per Game, Regular Season
  # 2: Per Game, Playoffs
  # 3: Totals, Regular Season
  # 4: Totals, Playoffs
  # 5: Advanced, Regular Season
  # 6: Advanced, Playoffs
  
  player_pergame <- player_url %>%
    read_html() %>%
    html_table() %>%
    .[[player_table]]
  
  return (player_pergame)
  
}

# TESTING -----------------------------------------------------------------

x <- player_bballref('https://www.basketball-reference.com/players/a/antetgi01.html', 1)
x$Season
x[1, 'G']
