# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Projects/Spurs_Trends')

source('../../Scrapers/bballref_playerlinks.R')
source('../../Scrapers/bballref_gamelog.R')

library(dplyr)
library(tidyr)
library(reshape)
library(gridExtra)
library(ggthemes)
library(grid)

# DATA PREPARATION --------------------------------------------------------


season = '2022'

spurs <- c('Keldon Johnson', 'Lonnie Walker IV', 'Drew Eubanks',
           'Dejounte Murray', 'Derrick White', 'Devin Vassell',
           'Jakob Poeltl', 'Tre Jones', 'Keita Bates-Diop',
           'Doug McDermott', 'Jock Landale', 'Joshua Primo')

last.inits <- c('j', 'w', 'e', 'm', 'w', 'v', 'p', 'j', 'b', 'm', 'l', 'p')

g <- seq(from = 1, to = 52, by = 1)
mp <- data.frame(Rk = g)

for (i in 1:length(spurs)) {
  
  mp.i <- player_gamelog(player = spurs[i], season = season, last.init = last.inits[i])[, c('Rk', 'MP')]

  mp.i$MP[mp.i$MP == 'Inactive' | mp.i$MP == 'Did Not Play'] <- 0
  
  mp.i <- separate(data = mp.i,
           col = MP,
           into = c('M', 'S'),
           sep = ':')
  
  mp.i$MP <- as.numeric(mp.i$M) + as.numeric(mp.i$S) / 60
  mp.i <- mp.i[, c('Rk', 'MP')]
  mp.i <- mp.i %>%
    mutate(Rk = as.numeric(Rk))

  
  mp <- mp %>%
    full_join(mp.i,
              by = 'Rk')
  
}

colnames(mp) <- c('Rk', spurs)

mp.melt <- melt(mp,
                id.vars = c('Rk'),
                variable_name = 'Player')



kj <- ggplot(data = mp,
       aes(x = Rk,
           y = `Keldon Johnson`)) +
  geom_point() +
  ggtitle('Keldon Johnson') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

lw <- ggplot(data = mp,
       aes(x = Rk,
           y = `Lonnie Walker IV`)) +
  geom_point() +
  ggtitle('Lonnie Walker IV') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

de <- ggplot(data = mp,
       aes(x = Rk,
           y = `Drew Eubanks`)) +
  geom_point() +
  ggtitle('Drew Eubanks') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

dm <- ggplot(data = mp,
       aes(x = Rk,
           y = `Dejounte Murray`)) +
  geom_point() +
  ggtitle('Dejounte Murray') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

dw <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Derrick White`)) +
  geom_point() +
  ggtitle('Derrick White') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

dv <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Devin Vassell`)) +
  geom_point() +
  ggtitle('Devin Vassell') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

jp <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Jakob Poeltl`)) +
  geom_point() +
  ggtitle('Jakob Poeltl') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

tj <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Tre Jones`)) +
  geom_point() +
  ggtitle('Tre Jones') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

kbd <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Keita Bates-Diop`)) +
  geom_point() +
  ggtitle('Keita Bates-Diop') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

dmc <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Doug McDermott`)) +
  geom_point() +
  ggtitle('Doug McDermott') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

jl <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Jock Landale`)) +
  geom_point() +
  ggtitle('Jock Landale') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

jpr <- ggplot(data = mp,
             aes(x = Rk,
                 y = `Joshua Primo`)) +
  geom_point() +
  ggtitle('Joshua Primo') +
  geom_smooth(se = FALSE) +
  theme_solarized_2() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

grid.arrange(kj, lw, de, dm, dw, dv, jp, tj, kbd, dmc, jl, jpr,
             ncol = 4,
             top = textGrob('Spurs Rotation 2021-22 \nData from Basketball-Reference \n@cale_williams'),
             bottom = textGrob('Game'),
             left = textGrob('Minutes Played',
                             rot = 90))

# # bigs
# grid.arrange(jp, de, jl, ncol = 1)
# 
# # wings
# grid.arrange(kj, dv, dmc, kbd, ncol = 1)
# 
# # guards
# grid.arrange(dm, dw, lw, tj, jpr, ncol = 1)

