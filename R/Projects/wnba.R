library(wehoop)
library(dplyr)
library(ggplot2)

library(rpart)
library(rpart.plot)
library(randomForest)


# game <- wnba_boxscoreplayertrackv2('401276115')
player.box <- load_wnba_player_box(seasons = 2022)

pred.cols <- c(
  'minutes',
  'two_point_field_goals_attempted',
  'three_point_field_goals_attempted',
  'free_throws_attempted',
  'offensive_rebounds',
  'defensive_rebounds',
  'assists',
  'steals',
  'blocks',
  'turnovers',
  'fouls'
  )

# choose player, random forest predict team_winner?
aja.wilson <- player.box %>%
  mutate(two_point_field_goals_attempted = field_goals_attempted - three_point_field_goals_attempted) %>%
  filter(athlete_id == 3149391) %>%
  select(all_of(pred.cols), team_winner)
  
data.train <- aja.wilson %>%
  slice_sample(prop = 0.7)

data.test <- anti_join(aja.wilson, data.train)

# compare lin reg, r tree, random forest with just aja wilson
minleaf <- ceiling(nrow(data.train) * 0.05)
minleaf <- 5
# Create regression tree model.
rt <- rpart(formula = team_winner ~ .,
            data = data.train,
            method = 'anova',
            control = rpart.control(minbucket = minleaf))

# Plot regression tree.
rpart.plot(rt,
           type = 4,
           digits = 2,
           fallen.leaves = FALSE,
           gap = 0,
           under = TRUE)

# Print errors.
printcp(rt)

# Plot errors.
plotcp(rt)


