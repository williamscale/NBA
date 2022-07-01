# Author: Cale Williams
# Last Updated: 01/28/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Shotcharts')

# Import libraries.
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(cowplot)

# Import function.
source('../Functions/drawNBAcourt.R')

# DATA PREPARATION --------------------------------------------------------

# Read in data.
shots <- read.csv('./2021-22/Keldon-Johnson.2021-22.csv',
                  header = TRUE)

# Transform shot locations.
shots.t <- shotchart.transformer(data = shots,
                                 col.x = 'LOC_X',
                                 col.y = 'LOC_Y')

fg.m <- shots.t %>%
  filter(SHOT_MADE_FLAG == 1)

fg.a <- shots.t %>%
  filter(SHOT_MADE_FLAG == 0)

fg.halfcourt <- shots.t %>%
  filter(LOC_Y <= 0)

# Change to custom cuts? to have corner 3s be separate basically
# no because bins should be equal
delta <- 2
bin.x.breaks <- seq(-25, 25, by = delta)
bin.y.breaks <- seq(-47, 0, by = delta)
# bin.x.centers <- bin.x.breaks[-1] - delta / 2
# bin.y.centers <- bin.y.breaks[-1] - delta / 2

fg.halfcourt.bin <- fg.halfcourt %>%
  mutate(bin.x = cut(LOC_X, breaks = bin.x.breaks),
         bin.y = cut(LOC_Y, breaks = bin.y.breaks)) %>%
  group_by(bin.x, bin.y)

fg.bin.m <- aggregate(SHOT_MADE_FLAG ~ bin.x + bin.y,
                    data = fg.halfcourt.bin,
                    FUN = sum)

fg.bin.a <- aggregate(SHOT_ATTEMPTED_FLAG ~ bin.x + bin.y,
                      data = fg.halfcourt.bin,
                      FUN = sum)

fg.eff <- merge(fg.bin.m, fg.bin.a, by = c('bin.x', 'bin.y'))


fg.eff$bin.eff <- fg.eff$SHOT_MADE_FLAG / fg.eff$SHOT_ATTEMPTED_FLAG

cx <- cbind(x.lower = as.numeric( sub("\\((.+),.*", "\\1", fg.eff$bin.x) ),
      x.upper = as.numeric( sub("[^,]*,([^]]*)\\]", "\\1", fg.eff$bin.x) ))
cy <- cbind(y.lower = as.numeric( sub("\\((.+),.*", "\\1", fg.eff$bin.y) ),
            y.upper = as.numeric( sub("[^,]*,([^]]*)\\]", "\\1", fg.eff$bin.y) ))
fg.eff <- cbind(fg.eff, cx, cy)
fg.eff$center.x <- rowMeans(fg.eff[, c('x.lower', 'x.upper')])
fg.eff$center.y <- rowMeans(fg.eff[, c('y.lower', 'y.upper')])

#########################################
# maybe make these bins make sense
quantiles.eff <- fg.eff %>%
  pull(bin.eff) %>%
  quantile(probs = seq(0, 1, length.out = 4))
quantiles.rate <- fg.eff %>%
  pull(SHOT_ATTEMPTED_FLAG) %>%
  quantile(probs = seq(0, 1, length.out = 4))

bivariate_color_scale <- tibble(
  "3 - 3" = "#3F2949", # high inequality, high income
  "2 - 3" = "#435786",
  "1 - 3" = "#4885C1", # low inequality, high income
  "3 - 2" = "#77324C",
  "2 - 2" = "#806A8A", # medium inequality, medium income
  "1 - 2" = "#89A1C8",
  "3 - 1" = "#AE3A4E", # high inequality, low income
  "2 - 1" = "#BC7C8F",
  "1 - 1" = "#CABED0" # low inequality, low income
) %>%
  gather("group", "fill")

fg.eff <- fg.eff %>%
  mutate(
    eff_quantiles = cut(
      bin.eff,
      breaks = quantiles.eff,
      include.lowest = TRUE
    ),
    rate_quantiles = cut(
      SHOT_ATTEMPTED_FLAG,
      breaks = quantiles.rate,
      include.lowest = TRUE
    ),
    # by pasting the factors together as numbers we match the groups defined
    # in the tibble bivariate_color_scale
    group = paste(
      as.numeric(eff_quantiles), "-",
      as.numeric(rate_quantiles)
    )
  ) %>%
  # we now join the actual hex values per "group"
  # so each municipality knows its hex value based on the his gini and avg
  # income value
  left_join(bivariate_color_scale, by = "group")


bivariate_color_scale %<>%
  separate(group, into = c("LOC_X", "LOC_Y"), sep = " - ") %>%
  mutate(LOC_X = as.integer(LOC_X),
         LOC_Y = as.integer(LOC_Y))

legend <- ggplot() +
  geom_tile(
    data = bivariate_color_scale,
    mapping = aes(
      x = LOC_X,
      y = LOC_Y,
      fill = fill)
  ) +
  scale_fill_identity() +
  labs(x = "Higher FG% ??????",
       y = "Higher Rate ??????") +
  # theme_map() +
  # make font small enough
  theme(
    axis.title = element_text(size = 6)
  ) +
  # quadratic tiles
  coord_fixed()

############################################

eff.plot <- ggplot(fg.eff, aes(x = center.x, y = center.y))

heatmap <- court.plotter.lines(eff.plot) +
  geom_tile(data = fg.eff,
            # aes(fill = bin.eff),
            aes(fill = fill),
            alpha = 0.7) +
  scale_fill_identity() +
  # scale_fill_gradientn(colors = c('#268bd2', 'white', '#dc322f'),
  #                      breaks = seq(0, 1, by = 0.2)) +
  theme_classic() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())



ggdraw() +
  draw_plot(heatmap, 0, 0, 1, 1) +
  draw_plot(legend, 0.55, 0.65, 0.3, 0.3)









