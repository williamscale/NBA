library(tidyverse)
library(hoopR)

# data <- nba_data_pbp(game_id = '0022300061')
# mins <- ifelse(max(data$period) == 4, 48, (max(data$period) - 4) * 5 + 48)
# # pf <- data %>%
# #   filter(grepl('Foul: Shooting', description)) %>%
# #   # filter(grepl('Foul', description))
# #   # filter(event_type == 6)
# #   # filter(event_action_type == 2)
# #   # select(-c('league', 'locX', 'locY', 'opt1', 'opt2'))
# #   mutate(ref = str_sub(substr(description,
# #                               unlist(gregexpr('\\([A-Z]', description)),
# #                               str_length(description)),
# #                        start = 2,
# #                        end = -2))
# 
# pf %>% group_by(ref) %>% summarize(n.per = n() / mins)

game.id <- nba_schedule(season = 2023) %>%
  filter(season_type_description == 'Regular Season',
         game_date <= '2024-02-29') %>%
  select(game_id, home_team_tricode, away_team_tricode)

fouls <- vector(mode = 'list')

for (i in game.id$game_id) {
  print(i)
  data.i <- nba_data_pbp(game_id = i)
  mins.i <- ifelse(max(data.i$period) == 4,
                   48,
                   (max(data.i$period) - 4) * 5 + 48)
  
  pf.i <- data.i %>%
    filter(grepl('Foul: Shooting', description)) %>%
    mutate(team = substr(description, 2, 4),
           ref = str_sub(substr(description,
                                unlist(gregexpr('\\([A-Z]', description)),
                                str_length(description)),
                         start = 2,
                         end = -2)) %>%
    group_by(ref, team) %>%
    summarize(n = n(),
              game.id = i,
              mins = mins.i)
  
  fouls[[i]] <- pf.i
  
}

fouls <- bind_rows(fouls)

fouls <- fouls %>%
  left_join(game.id, by = c('game.id' = 'game_id'))

saveRDS(fouls, './MyProjects/NBA/R/Projects/FTA_Prediction/Data/shootingfouls_2023.RDS')

fouls.summary <- fouls %>%
  group_by(ref) %>%
  summarize(mins = sum(mins),
            fouls = sum(n),
            games = n()) %>%
  mutate(fouls.per.min = fouls / mins) %>%
  filter(games >= 15)
  
hist(fouls.summary$fouls.per.min)
mean(fouls.summary$fouls.per.min)

fouls.summary %>% filter(ref %in% c('J Williams', 'J Butler', 'M Dagher'))
