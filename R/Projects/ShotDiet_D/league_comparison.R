library(tidyverse)
library(cowplot)
library(stringr)

# Read data ---------------------------------------------------------------

players <- readRDS('./Data/bigs.RDS')
defendingshots <- readRDS('./Data/defendingshots_bigs.RDS')
rebounding <- readRDS('./Data/rebounding_bigs.RDS')

# Join data ---------------------------------------------------------------

pal <- data.frame(
  PLAYER_NAME = c('Wembanyama', 'Collins'),
  PLAYER_ID = c('1641705', '1628380')
)

players <- players %>%
  left_join(pal, by = 'PLAYER_ID') %>%
  rename('PLAYER_NAME' = PLAYER_NAME.x,
         'PLOT_LABEL' = PLAYER_NAME.y)

defendingshots.rim <- lapply(
  defendingshots,
  function(x) x %>% filter(DEFENSE_CATEGORY == 'Less Than 6 Ft'))

defendingshots.rim <- bind_rows(defendingshots.rim) %>%
  select(-c(DEFENSE_CATEGORY, G)) %>%
  rename('PLAYER_ID' = CLOSE_DEF_playerId) %>%
  mutate(across(!PLAYER_ID, as.numeric))

data <- left_join(
  defendingshots.rim %>% select(-GP),
  players,
  by = 'PLAYER_ID') %>%
  mutate(D_FGA.MIN = D_FGA / MIN,
         BLK.RATE = BLK / D_FGA)

rebounding <- lapply(
  rebounding,
  function(x) x %>% filter(SHOT_DIST_RANGE == '0-6 Feet'))

rebounding <- bind_rows(rebounding) %>%
  select(-c(PLAYER_NAME_LAST_FIRST, SORT_ORDER, SHOT_DIST_RANGE)) %>%
  mutate(across(!PLAYER_ID, as.numeric))

data <- left_join(
  data,
  rebounding %>% select(-G),
  by = 'PLAYER_ID') %>%
  mutate(DREB.RATE = DREB / (D_FGA - D_FGM))

rm(defendingshots, defendingshots.rim, pal, players, rebounding)
gc()

# Rim Defense -------------------------------------------------------------

ggplot(data = data,
       aes(x = D_FGA,
           y = D_FG_PCT,
           color = PLOT_LABEL,
           label = PLOT_LABEL,
           size = ifelse(is.na(PLOT_LABEL), 1.5, 2.5),
           alpha = ifelse(is.na(PLOT_LABEL), 1, 1))) +
  geom_point() +
  geom_text(hjust = 0.5,
            vjust = -0.8,
            size = 4) +
  scale_size_identity() +
  scale_alpha_identity() +
  xlab('Defended FGA') +
  ylab('Defended FG%') +
  ggtitle('Defended Rim FGA Among Bigs',
          subtitle = 'Shot Distance < 6ft') +
  theme_cowplot() +
  theme(legend.position = 'none')

ggplot(data = data,
       aes(x = D_FGA.MIN,
           y = D_FG_PCT,
           color = PLOT_LABEL,
           label = PLOT_LABEL,
           size = ifelse(is.na(PLOT_LABEL), 1.5, 2.5),
           alpha = ifelse(is.na(PLOT_LABEL), 1, 1))) +
  geom_point() +
  geom_text(hjust = 0.5,
            vjust = -0.8,
            size = 5) +
  scale_size_identity() +
  scale_alpha_identity() +
  xlab('Defended FGA Per Min') +
  ylab('Defended FG%') +
  ggtitle('Defended Rim FGA Among Bigs',
          subtitle = 'Shot Distance < 6ft') +
  theme_cowplot() +
  theme(legend.position = 'none')

ggplot(data = data,
       aes(x = D_FGA,
           y = BLK,
           color = PLOT_LABEL,
           label = PLOT_LABEL,
           size = ifelse(is.na(PLOT_LABEL), 1.5, 2.5),
           alpha = ifelse(is.na(PLOT_LABEL), 1, 1))) +
  geom_point() +
  geom_text(hjust = 0.5,
            vjust = 1.2,
            size = 5) +
  scale_size_identity() +
  scale_alpha_identity() +
  xlab('Defended FGA') +
  ylab('Blocks') +
  ggtitle('Blocks Among Bigs',
          subtitle = 'Shot Distance < 6ft') +
  theme_cowplot() +
  theme(legend.position = 'none')

# Defensive Rebounding ----------------------------------------------------

ggplot(data = data,
       aes(x = D_FGA-D_FGM,
           y = DREB,
           color = PLOT_LABEL,
           label = PLOT_LABEL,
           size = ifelse(is.na(PLOT_LABEL), 1.5, 2.5),
           alpha = ifelse(is.na(PLOT_LABEL), 1, 1))) +
  geom_point() +
  geom_text(hjust = 0.5,
            vjust = 1.2,
            size = 5) +
  scale_size_identity() +
  scale_alpha_identity() +
  xlab('Defended FGA Misses') +
  ylab('Rim DRB') +
  ggtitle('Finishing Possessions',
          subtitle = 'Shot Distance < 6ft') +
  theme_cowplot() +
  theme(legend.position = 'none')

ggplot(data = data,
       aes(x = D_FG_PCT,
           y = DREB.RATE,
           color = PLOT_LABEL,
           label = PLOT_LABEL,
           size = ifelse(is.na(PLOT_LABEL), 1.5, 2.5),
           alpha = ifelse(is.na(PLOT_LABEL), 1, 1))) +
  geom_point() +
  geom_text(hjust = 0.5,
            vjust = 1.2,
            size = 5) +
  scale_size_identity() +
  scale_alpha_identity() +
  xlab('DFG%') +
  ylab('DREB%') +
  ggtitle('Finishing Possessions',
          subtitle = 'Shot Distance < 6ft') +
  theme_cowplot() +
  theme(legend.position = 'none')

# Summary -----------------------------------------------------------------

data <- data %>%
  mutate(rim.makes.min = case_when(PLOT_LABEL == 'Wembanyama' ~ 736 / MIN,
                                   PLOT_LABEL == 'Collins' ~ 488 / MIN,
                                   TRUE ~ NA),
         rim.makes.fga = case_when(PLOT_LABEL == 'Wembanyama' ~ 736 / (4088 + 839),
                                   PLOT_LABEL == 'Collins' ~ 488 / (2958 + 839),
                                   TRUE ~ NA))

x <- data %>%
  select(PLOT_LABEL, rim.makes.min, rim.makes.fga, D_FG_PCT, BLK.RATE,
         DREB.RATE) %>%
  filter(!is.na(PLOT_LABEL))
