# Author: Cale Williams
# Last Updated: 06/22/2022

# Import libraries.
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(cowplot)
library(hexbin)

# FUNCTION ----------------------------------------------------------------

shotchart.topn.plotter <- function(data.transformed, hexagons = 16, top.n = 30) {
  
  # if (nrow(data.transformed) < 25) {stop('Too few datapoints for relevant plot.')}
  # if (top.n < 2) {stop('Select a higher value.')}
  
  player <- data.transformed$PLAYER_NAME[1]
  
  fg.halfcourt <- data.transformed %>%
    filter(LOC_Y <= 0)
  
  fg.halfcourt.hex <- hexbin(x = fg.halfcourt$LOC_X,
                             y = fg.halfcourt$LOC_Y,
                             xbins = hexagons,
                             # shape = 1,
                             xbnds = c(-25, 25),
                             ybnds = c(-47, 0),
                             IDs = TRUE)
  # print(fg.halfcourt.hex@xbnds)
  hex <- data.frame(hcell2xy(fg.halfcourt.hex),
                    cell = fg.halfcourt.hex@cell,
                    count = fg.halfcourt.hex@count)

  fg.halfcourt$cell = fg.halfcourt.hex@cID

  top.hex <- fg.halfcourt %>%
    group_by(cell) %>%
    summarize(attempts = sum(SHOT_ATTEMPTED_FLAG),
              makes = sum(SHOT_MADE_FLAG)) %>%
    right_join(hex, by = 'cell') %>%
    slice_max(attempts,
              n = top.n,
              # prop = 0.2,
              with_ties = TRUE) %>%
    select(-c('count'))

  top.hex$eff <- top.hex$makes / top.hex$attempts
  # print(top.hex)
  eff.plot <- ggplot(top.hex,
                     aes(x = x, y = y)) +
    geom_hex(data = top.hex,
             aes(fill = eff),
             stat = 'identity',
             color = 'black', size = 1) +
    scale_fill_continuous(type = 'viridis') +
    labs(fill = 'FG%')


  topn.plot <- court.plotter.lines(fg.plot = eff.plot) +
    ggtitle(paste(player, '\nTop FGA Locations')) +
    theme_solarized_2() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          legend.position = c(0.78, 1.02),
          legend.background = element_rect(fill = '#eee8d5'),
          legend.direction = 'horizontal',
          legend.key.width = unit(0.5, 'inch'),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 20),
          plot.background = element_rect(fill = '#eee8d5'),
          plot.title = element_text(size = 20, face = 'bold'))

  return(topn.plot)

}

# TESTING -----------------------------------------------------------------

# setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Functions')
# 
# # Import functions.
# source('../Functions/drawNBAcourt.R')
# #
# # # Read in data.
# shots <- read.csv('./../Shotcharts/2021-22/Juancho-Hernangomez.2021-22.csv',
#                   header = TRUE)
# 
# #
# # # Transform shot locations.
# shots.t <- shotchart.transformer(data = shots,
#                                  col.x = 'LOC_X',
#                                  col.y = 'LOC_Y')
# 
# shotchart.topn.plotter(data.transformed = shots.t,
#                        hexagons = 16,
#                        top.n = 10)




