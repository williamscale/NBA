library(tidyverse)
library(hoopR)

# Player ID ---------------------------------------------------------------

mins <- nba_leaguedashplayerstats()[['LeagueDashPlayerStats']] %>%
  select(PLAYER_ID, MIN, BLK) %>%
  mutate(MIN = as.numeric(MIN),
         BLK = as.numeric(BLK))

height <- nba_leaguedashplayerbiostats()[['LeagueDashPlayerBioStats']] %>%
  mutate(PLAYER_HEIGHT_INCHES = as.numeric(PLAYER_HEIGHT_INCHES),
         GP = as.numeric(GP)) %>%
  select(PLAYER_ID, PLAYER_NAME, GP, PLAYER_HEIGHT_INCHES)

data <- full_join(mins, height, by = 'PLAYER_ID')
all.players <- data %>% pull(PLAYER_ID)

colSums(is.na(data))

bigs <- data %>%
  mutate(MIN.G = MIN / GP) %>%
  filter(PLAYER_HEIGHT_INCHES >= 82,
         GP >= 20,
         MIN.G >= 10)

vw.id <- '1641705'
zc.id <- '1628380'

saveRDS(bigs, file = './Data/bigs.RDS')

bigs <- bigs %>% pull(PLAYER_ID)
  
# Game ID -----------------------------------------------------------------

team.id <- '1610612759'

game.id <- nba_schedule(season = 2023) %>%
  filter(season_type_description == 'Regular Season') %>%
  select(game_date, game_id, home_team_id, away_team_id) %>%
  filter(home_team_id == team.id | away_team_id == team.id,
         game_date < Sys.Date()) %>%
  mutate(team = case_when(home_team_id == team.id ~ 'home',
                          TRUE ~ 'away'))
  
home.away <- game.id$team
game.id <- game.id$game_id

# Box Score Player Tracking -----------------------------------------------

player.tracking <- vector(mode = 'list')
for (i in 1:length(game.id)) {
  print(i)
  Sys.sleep(0.5)
  if (home.away[i] == 'home') {
    df.i <- nba_boxscoreplayertrackv3(
      game_id = game.id[i])[['home_team_player_player_track']]
    } else {
    df.i <- nba_boxscoreplayertrackv3(
      game_id = game.id[i])[['away_team_player_player_track']]
    }
  player.tracking[[game.id[i]]] <- df.i
}

player.tracking.df <- bind_rows(player.tracking)

saveRDS(player.tracking.df, file = './Data/tracking_spurs.RDS')

# Defending Shots ---------------------------------------------------------

defendingshots <- vector(mode = 'list')
for (i in bigs) {
  Sys.sleep(0.5)
  df.i <- nba_playerdashptshotdefend(player_id = i)[['DefendingShots']]
  defendingshots[[i]] <- df.i
}

saveRDS(defendingshots, file = './Data/defendingshots_bigs.RDS')

# Shot Distance Rebounding ------------------------------------------------

rebounding <- vector(mode = 'list')
for (i in bigs) {
  Sys.sleep(0.5)
  df.i <- nba_playerdashptreb(player_id = i)[['ShotDistanceRebounding']]
  rebounding[[i]] <- df.i
}

saveRDS(rebounding, file = './Data/rebounding_bigs.RDS')

# Shot Chart League-Wide --------------------------------------------------

shotchartdetail <- vector(mode = 'list')
for (i in all.players) {
  print(match(i, all.players) / length(all.players))
  Sys.sleep(0.5)
  df.i <- nba_shotchartdetail(player_id = i)[['Shot_Chart_Detail']]
  shotchartdetail[[i]] <- df.i
}

saveRDS(shotchartdetail, file = './Data/shotchartdetail.RDS')
