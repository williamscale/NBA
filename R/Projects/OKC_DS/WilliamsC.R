# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('D:/Professional/Analytics/OKCThunder_DS&S_S23')

# Import libraries.
library(dplyr)

data.raw <- read.csv('shots_data.csv')

# Classify shots.
data <- data.raw %>%
  mutate(distance = sqrt(x^2 + y^2),
         zone = case_when(distance <= 22 ~ '2PT',
                          distance > 22 & y <= 7.8 ~ 'C3',
                          distance > 22 & y > 7.8 ~ 'NC3')) 

assertthat::are_equal(0, sum(is.na(data$zone)))

shotDist <- data %>%
  group_by(team, zone) %>%
  summarize(n = n(),
            made = sum(fgmade)) %>%
  group_by(team) %>%
  mutate(distribution = n / sum(n),
         eFG = case_when(zone != '2PT' ~ 1.5*made / n,
                         TRUE ~ made / n)) %>%
  select(-c(n, made))
