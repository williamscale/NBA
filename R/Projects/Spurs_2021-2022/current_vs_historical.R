# Author: Cale Williams
# Last Updated: 02/04/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Projects/Spurs_2021-2022')

library(ggplot2)
library(ggthemes)

# Import function.
source('../../Scrapers/bballref_season_summary.R')

# DATA PREPARATION --------------------------------------------------------

# Input Spurs data.
spurs <- data.frame(w = c(22), l = c(36), wp = c(22/58), pt.dif = c(0),
                    pt.dif.g = c(0/54))

# Read in data.
pt.dif <- read.csv('1969-70_2018-19_0_58_within.csv',
                   header = TRUE)

record <- read.csv('1969-70_2020-21_22-36.csv',
                   header = TRUE)

colnames(pt.dif)[ncol(pt.dif)] <- 'Team.Year'

ggplot(data = pt.dif,
       aes(x = seq(1, nrow(pt.dif)),
           y = Win.Pct)) +
  geom_point() +
  geom_point(data = spurs,
             aes(x = c(0),
                 y = wp),
             color = '#00B2A9',
             size = 3) +
  annotate('text',
           x = 2.2,
           y = 0.38,
           label = '2021-22 Spurs',
           color = '#00B2A9') +
  xlab('Teams w/ Point Differential of -5 to +5 After 58 Games') +
  ylab('Final Win Percentage') +
  theme_solarized_2()

ggplot(data = pt.dif,
       aes(x = reorder(Team.Year, Win.Pct),
           y = Win.Pct)) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  xlab('Teams w/ Point Differential of-5 to +5 After 58 Games') +
  ylab('Final Win Percentage') +
  theme_solarized_2() +
  geom_bar(data = spurs,
           aes(y = wp)) 

# HISTORICAL DATA ---------------------------------------------------------

team <- c()
season <- c()
wins <- c()
losses <- c()
pts <- c()
pts.opp <- c()

seasons <- as.character(seq(1980, 2020))

# standings
for (i in seasons) {
  
  season.summary.i <- summarize.season(i)
  
  season.i <- rep(i, times = nrow(season.summary.i))
  season <- c(season, season.i)
  
  team <- c(team, season.summary.i[['Team']])
  wins <- c(wins, season.summary.i[['W']])
  losses <- c(losses, season.summary.i[['L']])
  pts <- c(pts, season.summary.i[['PTS']])
  pts.opp <- c(pts.opp, season.summary.i[['PTS.OPP']])

}

wins <- as.numeric(wins)
losses <- as.numeric(losses)

data <- data.frame(season, team, wins, losses, pts, pts.opp)
data$G <- data$wins + data$losses
data$WP <- data$wins / data$G
data$diff <- data$pts - data$pts.opp
data$diff.G <- data$diff / data$G

# BUILD MODEL -------------------------------------------------------------

m <- lm(WP ~ diff.G,
        data = data)

summary(m)

# CHECK ASSUMPTIONS -------------------------------------------------------

# Check linearity.
ggplot(data = data,
       aes(x = diff.G,
           y = WP)) +
  geom_point() +
  geom_smooth(method = 'lm',
              formula = y ~ x,
              color = '#EF426F') +
  geom_point(data = spurs,
             aes(x = pt.dif.g,
                 y = wp),
             color = '#00B2A9',
             size = 3) +
  annotate('text',
           x = -10,
           y = 0.6,
           label = 'y = 0.03x + 0.5',
           color = '#EF426F') +
  annotate('text',
           x = spurs$pt.dif.g + 3,
           y = spurs$wp,
           label = '2021-22 Spurs',
           color = '#00B2A9') +
  xlab('Point Differential Per Game') +
  ylab('Win Percentage') +
  theme_solarized_2()

# Check homoscedasticity.
ggplot(data = data,
       aes(x = m$fitted.values,
           y = m$residuals)) +
  geom_point() +
  xlab('Fitted Values') +
  ylab('Residuals') +
  geom_hline(yintercept = 0,
             size = 1) +
  theme_solarized_2()

# Check normality.
ggplot(data = data,
       aes(x = diff.G)) +
  geom_histogram(bins = 30) +
  xlab('Point Differential') +
  theme_solarized_2()

ggplot(data = data,
       aes(sample = diff.G)) +
  stat_qq() +
  stat_qq_line() +
  theme_solarized_2()

