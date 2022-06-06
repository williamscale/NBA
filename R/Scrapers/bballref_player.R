
player.bballref <- function(player.url, player.table = 1) {
  
  library(rvest)
  
  # player_table Reference
  # 1: Per Game, Regular Season
  # 2: Per Game, Playoffs (unless they never made playoffs)
  # 3: Totals, Regular Season
  # 4: Totals, Playoffs
  # 5: Advanced, Regular Season
  # 6: Advanced, Playoffs
  
  player.stats <- player.url %>%
    read_html() %>%
    html_table()
  # %>%
  #   .[[player_table]]
  
  if ((length(player.stats) == 3) & ((player.table == 2) | (player.table == 4) | (player.table == 4))) {

    print('Player did not make playoffs.')

  } else if ((length(player.stats) == 3) & (player.table == 3)) {

    player.stats <- player.stats %>%
      .[[2]]

  } else if ((length(player.stats) == 3) & (player.table == 5)) {

    player.stats <- player.stats %>%
      .[[3]]

  } else {

    player.stats <- player.stats %>%
      .[[player.table]]
  }
  
  return (player.stats)
  
}



# TESTING -----------------------------------------------------------------

# x <- player.bballref('https://www.basketball-reference.com/players/m/murrade01.html', 5)
# x
# x[5, 1]
# x$Season
# x[1, 'G']
