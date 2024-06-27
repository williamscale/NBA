library(tidyverse)
library(hexbin)
library(cowplot)
library(stringr)
source('./drawNBAcourt.R')

shots <- readRDS('./Data/shotchartdetail.RDS')

origin <- c(0, -43)
shots <- bind_rows(shots) %>%
  mutate_at(c('SHOT_MADE_FLAG', 'SHOT_DISTANCE', 'LOC_X', 'LOC_Y'),
            as.numeric) %>%
  mutate(loc.x = LOC_X / 10,
         loc.y = LOC_Y / 10 - 42.25,
         shot.result = case_when(SHOT_MADE_FLAG == 0 ~ 'MISS',
                                 TRUE ~ 'MAKE')) %>%
  mutate(distance = sqrt((loc.x - origin[1]) ^ 2 + (loc.y - origin[2]) ^ 2))

on.vw <- readRDS('./Data/shots_vw_on_2024.RDS') %>%
  mutate(on = 1)

on.zc <- readRDS('./Data/shots_zc_on_2024.RDS') %>%
  mutate(on = 1)

on.vw <- on.vw %>%
  mutate(on = factor(on),
         SHOT_MADE_FLAG = as.numeric(SHOT_MADE_FLAG),
         SHOT_DISTANCE = as.numeric(SHOT_DISTANCE),
         shot.result = case_when(SHOT_MADE_FLAG == 0 ~ 'MISS',
                                 TRUE ~ 'MAKE'))

on.zc <- on.zc %>%
  mutate(on = factor(on),
         SHOT_MADE_FLAG = as.numeric(SHOT_MADE_FLAG),
         SHOT_DISTANCE = as.numeric(SHOT_DISTANCE),
         shot.result = case_when(SHOT_MADE_FLAG == 0 ~ 'MISS',
                                 TRUE ~ 'MAKE'))

vw <- anti_join(on.vw, on.zc, by = c('GAME_ID', 'GAME_EVENT_ID'))
zc <- anti_join(on.zc, on.vw, by = c('GAME_ID', 'GAME_EVENT_ID'))
both <- inner_join(on.vw, on.zc, by = c('GAME_ID', 'GAME_EVENT_ID'),
                   suffix = c('', '.repeat')) %>%
  select(-ends_with('.repeat'))

nrow(vw) + nrow(zc) + nrow(both)
nrow(on.vw) + nrow(on.zc) - nrow(both)

dist.binned.all <- shots %>%
  mutate(distance.bin = cut(distance,
                            breaks = seq(0, 30, by = 1),
                            include.lowest = TRUE)) %>%
  group_by(distance.bin) %>%
  summarize(fga = n(),
            fgm = sum(SHOT_MADE_FLAG)) %>%
  mutate(distance.eff = fgm / fga,
         distance.prop = fga / sum(fga),
         bin.label = as.numeric(str_match(distance.bin, ',\\s*(.*?)\\s*]')[, 2]))

dist.binned.vw <- vw %>%
  mutate(distance.bin = cut(distance,
                            breaks = seq(0, 30, by = 1),
                            include.lowest = TRUE)) %>%
  group_by(distance.bin) %>%
  summarize(fga = n(),
            fgm = sum(SHOT_MADE_FLAG)) %>%
  mutate(distance.eff = fgm / fga,
         distance.prop = fga / sum(fga),
         bin.label = as.numeric(str_match(distance.bin, ',\\s*(.*?)\\s*]')[, 2]))

dist.binned.zc <- zc %>%
  mutate(distance.bin = cut(distance,
                            breaks = seq(0, 30, by = 1),
                            include.lowest = TRUE)) %>%
  group_by(distance.bin) %>%
  summarize(fga = n(),
            fgm = sum(SHOT_MADE_FLAG)) %>%
  mutate(distance.eff = fgm / fga,
         distance.prop = fga / sum(fga),
         bin.label = as.numeric(str_match(distance.bin, ',\\s*(.*?)\\s*]')[, 2]))

dist.binned <- bind_rows(list(
  League = dist.binned.all,
  Wembanyama = dist.binned.vw,
  Collins = dist.binned.zc),
  .id = 'id')

ggplot(data = dist.binned %>% filter(bin.label <= 6),
       aes(x = bin.label,
           y = distance.prop,
           color = id,
           group = id)) +
  geom_line(size = 1) +
  geom_point() +
  scale_color_manual(values = c(League = 'black',
                                Wembanyama = '#EF426F',
                                Collins = '#00B2A9'),
                     name = NULL) +
  xlab('FGA Distance [ft]') +
  ylab('Proportion of FGA') +
  theme_cowplot()

dist.binned <- dist.binned %>%
  group_by(id) %>%
  mutate(cumprop = cumsum(distance.prop))

ggplot(data = dist.binned %>% filter(bin.label <= 6),
       aes(x = bin.label,
           y = cumprop,
           color = id,
           group = id)) +
  geom_line(size = 1) +
  geom_point() +
  scale_color_manual(values = c(League = 'black',
                                Wembanyama = '#EF426F',
                                Collins = '#00B2A9'),
                     name = NULL) +
  xlab('FGA Distance [ft]') +
  ylab('Cumulative Proportion of FGA') +
  theme_cowplot()

# Filter at-rim attempts. -------------------------------------------------

nrow(vw %>% filter(distance < 6)) / nrow(vw)
nrow(zc %>% filter(distance < 6)) / nrow(zc)
nrow(both %>% filter(distance < 6)) / nrow(both)

vw <- vw %>% filter(distance < 6)
zc <- zc %>% filter(distance < 6)
both <- both %>% filter(distance < 6)

dist.binned <- dist.binned %>% filter(bin.label <= 6)

ggplot(data = dist.binned,
       aes(x = bin.label,
           y = distance.eff,
           color = id,
           group = id)) +
  geom_line(size = 1) +
  geom_point() +
  scale_color_manual(values = c(League = 'black',
                                Wembanyama = '#EF426F',
                                Collins = '#00B2A9'),
                     name = NULL) +
  xlab('FGA Distance [ft]') +
  ylab('FG%') +
  theme_cowplot()

ggplot(data = bind_rows(vw %>% mutate(C = 'Wembanyama'),
                        zc %>% mutate(C = 'Collins')),
       aes(x = distance,
           fill = C,
           color = C)) +
  geom_density(alpha = 0.3,
               size = 1) +
  scale_fill_manual(values = c('Wembanyama' = '#EF426F',
                               'Collins' = '#00B2A9')) +
  scale_color_manual(values = c('Wembanyama' = '#EF426F',
                                'Collins' = '#00B2A9')) +
  xlab('Distance [ft]') +
  ylab('Density') +
  theme_cowplot()

dist.binned %>% group_by(id) %>% summarize(rim.makes = sum(fgm))
##########
# Create shot chart. ------------------------------------------------------

create.shotchart <- function(df, x.col, y.col, color, title) {
  shotchart <- ggplot(data = df,
                      aes(x = {{x.col}},
                          y = {{y.col}})) +
    geom_point(color = color,
               size = 1) +
    ggtitle(title) +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5))
  shotchart <- court.plotter.lines(fg.plot = shotchart)
  return(shotchart)
}

shotchart.vw <- create.shotchart(
  df = vw,
  x.col = loc.x,
  y.col = loc.y,
  color = '#EF426F',
  title = 'Wembanyama'
)
shotchart.zc <- create.shotchart(
  df = zc,
  x.col = loc.x,
  y.col = loc.y,
  color = '#00B2A9',
  title = 'Collins'
)

plot_grid(shotchart.vw, shotchart.zc, ncol = 2)

# Create hex shot chart. --------------------------------------------------

bin.hex <- function(df, x.col, y.col, bins.n) {
  
  hex <- hexbin(x = df[[x.col]],
                y = df[[y.col]],
                xbins = bins.n,
                xbnds = c(-25, 25),
                ybnds = c(-47, 0),
                IDs = TRUE)
  hex.df <- data.frame(hcell2xy(hex),
                       cell = hex@cell)
  hex.data <- df %>%
    mutate(cell = hex@cID) %>%
    left_join(hex.df, by = 'cell') %>%
    select(-c(x, y))
  
  cell <- hex.data %>%
    mutate_at(c('SHOT_ATTEMPTED_FLAG'), as.numeric) %>%
    group_by(cell) %>%
    summarize(attempts = sum(SHOT_ATTEMPTED_FLAG),
              makes = sum(SHOT_MADE_FLAG)) %>%
    mutate(eff = makes / attempts) %>%
    left_join(hex.df, by = 'cell')
  
  return(cell)
}

vw.cell <- bin.hex(
  df = vw,
  x.col = 'loc.x',
  y.col = 'loc.y',
  bins.n = 16
)

zc.cell <- bin.hex(
  df = zc,
  x.col = 'loc.x',
  y.col = 'loc.y',
  bins.n = 16
) 

create.hexshotchart <- function(df, x.col, y.col, fill.col, low.color,
                                high.color, legend.title, transformation,
                                title) {
  
  plot <- ggplot(data = df,
                 aes(x = {{x.col}},
                     y = {{y.col}}))+
    geom_hex(aes(fill = {{fill.col}}),
             stat = 'identity',
             color = 'white',
             size = 0.5) +
    scale_fill_gradient(low = low.color,
                        high = high.color,
                        name = legend.title,
                        trans = transformation) +
    ggtitle(title) +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5))
  
  shotchart <- court.plotter.lines(fg.plot = plot)
  
  return(shotchart)
  
}

hex.vw <- create.hexshotchart(
  df = vw.cell,
  x.col = x,
  y.col = y,
  fill.col = attempts,
  low.color = '#C4CED4',
  high.color = '#EF426F',
  legend.title = 'Count',
  transformation = 'log10',
  title = 'Wembanyama'
  )
hex.zc <- create.hexshotchart(
  df = zc.cell,
  x.col = x,
  y.col = y,
  fill.col = attempts,
  low.color = '#C4CED4',
  high.color = '#00B2A9',
  legend.title = 'Count',
  transformation = 'log10',
  title = 'Collins'
)

plot_grid(hex.vw, hex.zc, ncol = 2)

# Calculate difference in bins. -------------------------------------------

cells <- full_join(vw.cell, zc.cell, by = 'cell', suffix = c('.vw', '.zc'))

max(cells$x.vw - cells$x.zc, na.rm = TRUE)
max(cells$y.vw - cells$y.zc, na.rm = TRUE)

cells <- cells %>%
  mutate(x = pmax(x.vw, x.zc, na.rm = TRUE),
         y = pmax(y.vw, y.zc, na.rm = TRUE)) %>%
  select(-c(x.vw, y.vw, x.zc, y.zc))
  
cells <- cells %>%
  mutate(attempt.rate.vw = attempts.vw / sum(attempts.vw, na.rm = TRUE),
         attempt.rate.zc = attempts.zc / sum(attempts.zc, na.rm = TRUE)) %>%
  filter(attempts.vw >= 10 & attempts.zc >= 10)

# cells <- cells %>%
#   filter(attempt.rate.vw >= 0.01 | attempt.rate.zc >= 0.01) %>%
#   mutate(attempt.rate.diff = attempt.rate.vw - attempt.rate.zc)

xlim.rim <- c(-10, 10)
ylim.rim <- c(-45, -32)

hex.eff.vw <- create.hexshotchart(
  df = cells,
  x.col = x,
  y.col = y,
  fill.col = eff.vw,
  low.color = '#C4CED4',
  high.color = '#EF426F',
  legend.title = 'FG%',
  transformation = 'identity',
  title = 'Wembanyama') +
  stat_bin_hex(label = round(cells$eff.vw, 2), geom = 'text') +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)
hex.eff.zc <- create.hexshotchart(
  df = cells,
  x.col = x,
  y.col = y,
  fill.col = eff.zc,
  low.color = '#C4CED4',
  high.color = '#00B2A9',
  legend.title = 'FG%',
  transformation = 'identity',
  title = 'Collins') +
  stat_bin_hex(label = round(cells$eff.zc, 2), geom = 'text', vjust = 0.5) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim) + geom_point(aes(x = x, y = y))

plot_grid(hex.eff.vw, hex.eff.zc, ncol = 2)




hex.rate.diff <- create.hexshotchart(
  df = cells,
  x.col = x,
  y.col = y,
  fill.col = attempt.rate.diff,
  low.color = '#EF426F',
  high.color = '#EF426F',
  legend.title = 'Rate',
  transformation = 'identity',
  title = 'FGA Rate'
) + scale_fill_viridis_b()

hex.rate.diff

###

cells <- cells %>%
  mutate(max.attempt.rate = pmax(attempt.rate.vw,
                                 attempt.rate.zc,
                                 attempt.rate.both,
                                 na.rm = TRUE)) %>%
  mutate(max.c = case_when(max.attempt.rate == attempt.rate.vw ~ 'Wembanyama',
                           max.attempt.rate == attempt.rate.zc ~ 'Collins',
                           TRUE ~ 'Wembanyama + Collins'))

c.color <- data.frame(
  c = c('Wembanyama', 'Collins', 'Wembanyama + Collins'),
  col = c('#EF426F', '#00B2A9', '#FF8200')
  )

cells <- cells %>%
  left_join(c.color, by = c('max.c' = 'c'))

max.c <- ggplot(data = cells,
                aes(x = x,
                    y = y)) +
  geom_hex(aes(fill = col),
           stat = 'identity',
           color = 'white',
           size = 0.5) +
  scale_fill_identity(guide = 'legend',
                      labels = cells$max.c,
                      breaks = cells$col,
                      name = 'Center') +
  ggtitle('Leading Defending Center by Zone',
          subtitle = 'Highest Opponent FGA Rate') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

max.c <- court.plotter.lines(fg.plot = max.c)
max.c

max.c.example <- ggplot(data = cells,
                        aes(x = x,
                            y = y)) +
  geom_hex(aes(fill = col,
               alpha = ifelse(cell == 108, 1, 0.2)),
           stat = 'identity',
           color = 'white',
           size = 0.5) +
  scale_alpha_identity() +
  scale_fill_identity(guide = 'legend',
                      labels = cells$max.c,
                      breaks = cells$col,
                      name = 'Center') +
  ggtitle('Leading Defending Center by Zone',
          subtitle = 'Highest Opponent FGA Rate') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

max.c.example <- court.plotter.lines(fg.plot = max.c.example)
max.c.example

# Filter close shots. -----------------------------------------------------

vw <- vw %>% filter(distance <= 10)
zc <- zc %>% filter(distance <= 10)
both <- both %>% filter(distance <= 10)

# Create hex shot chart. --------------------------------------------------

n.bins <- 12
vw.hex <- hexbin(x = vw$loc.x,
                 y = vw$loc.y,
                 xbins = n.bins,
                 xbnds = c(-25, 25),
                 ybnds = c(-47, 0),
                 IDs = TRUE)
zc.hex <- hexbin(x = zc$loc.x,
                 y = zc$loc.y,
                 xbins = n.bins,
                 xbnds = c(-25, 25),
                 ybnds = c(-47, 0),
                 IDs = TRUE)
both.hex <- hexbin(x = both$loc.x,
                   y = both$loc.y,
                   xbins = n.bins,
                   xbnds = c(-25, 25),
                   ybnds = c(-47, 0),
                   IDs = TRUE)

vw.hex.df <- data.frame(hcell2xy(vw.hex),
                        cell = vw.hex@cell)
zc.hex.df <- data.frame(hcell2xy(zc.hex),
                        cell = zc.hex@cell)
both.hex.df <- data.frame(hcell2xy(both.hex),
                          cell = both.hex@cell)

vw.hex.data <- vw %>%
  mutate(cell = vw.hex@cID) %>%
  left_join(vw.hex.df, by = 'cell') %>%
  select(-c(x, y))
zc.hex.data <- zc %>%
  mutate(cell = zc.hex@cID) %>%
  left_join(zc.hex.df, by = 'cell') %>%
  select(-c(x, y))
both.hex.data <- both %>%
  mutate(cell = both.hex@cID) %>%
  left_join(both.hex.df, by = 'cell') %>%
  select(-c(x, y))

vw.cell <- vw.hex.data %>%
  mutate_at(c('SHOT_ATTEMPTED_FLAG'), as.numeric) %>%
  group_by(cell) %>%
  summarize(attempts = sum(SHOT_ATTEMPTED_FLAG),
            makes = sum(SHOT_MADE_FLAG)) %>%
  mutate(eff = makes / attempts) %>%
  left_join(vw.hex.df, by = 'cell')
zc.cell <- zc.hex.data %>%
  mutate_at(c('SHOT_ATTEMPTED_FLAG'), as.numeric) %>%
  group_by(cell) %>%
  summarize(attempts = sum(SHOT_ATTEMPTED_FLAG),
            makes = sum(SHOT_MADE_FLAG)) %>%
  mutate(eff = makes / attempts) %>%
  left_join(zc.hex.df, by = 'cell')
both.cell <- both.hex.data %>%
  mutate_at(c('SHOT_ATTEMPTED_FLAG'), as.numeric) %>%
  group_by(cell) %>%
  summarize(attempts = sum(SHOT_ATTEMPTED_FLAG),
            makes = sum(SHOT_MADE_FLAG)) %>%
  mutate(eff = makes / attempts) %>%
  left_join(both.hex.df, by = 'cell')

hex.vw <- ggplot(
  vw.cell,
  aes(x = x,
      y = y))+
  geom_hex(aes(fill = attempts),
           stat = 'identity',
           color = 'white',
           size = 0.5) +
  scale_fill_viridis_d()+
  ggtitle('Wembanyama') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5))
hex.zc <- ggplot(
  zc.cell,
  aes(x = x,
      y = y))+
  geom_hex(aes(fill = attempts),
           stat = 'identity',
           color = 'white',
           size = 0.5) +
  scale_fill_gradient(low = '#C4CED4',
                      high = '#00B2A9',
                      name = 'Count',
                      trans = 'log10') +
  ggtitle('Collins') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5))
hex.both <- ggplot(
  both.cell,
  aes(x = x,
      y = y))+
  geom_hex(aes(fill = attempts),
           stat = 'identity',
           color = 'white',
           size = 0.5) +
  scale_fill_gradient(low = '#C4CED4',
                      high = '#FF8200',
                      name = 'Count',
                      trans = 'log10') +
  ggtitle('Wembanyama + Collins') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5))

xlim.rim <- c(-10, 10)
ylim.rim <- c(-45, -32)
hex.vw <- court.plotter.lines(fg.plot = hex.vw) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)
hex.zc <- court.plotter.lines(fg.plot = hex.zc) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)
hex.both <- court.plotter.lines(fg.plot = hex.both) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)

plot_grid(hex.vw, hex.zc, hex.both,
          ncol = 3)

# Create density plot. ----------------------------------------------------

dens.vw <- ggplot(vw,
                  aes(x = loc.x,
                      y = loc.y)) +
  stat_density_2d(aes(fill = ..level..),
                  geom = 'polygon') +
  scale_fill_gradient(low = '#C4CED4',
                      high = '#EF426F',
                      guide = 'none') +
  ggtitle('Wembanyama') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5))
dens.zc <- ggplot(zc,
                  aes(x = loc.x,
                      y = loc.y)) +
  stat_density_2d(aes(fill = ..level..),
                  geom = 'polygon') +
  scale_fill_gradient(low = '#C4CED4',
                      high = '#00B2A9',
                      guide = 'none') +
  ggtitle('Collins') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5))
dens.both <- ggplot(both,
                    aes(x = loc.x,
                        y = loc.y)) +
  stat_density_2d(aes(fill = ..level..),
                  geom = 'polygon') +
  scale_fill_gradient(low = '#C4CED4',
                      high = '#FF8200',
                      guide = 'none') +
  ggtitle('Wembanyama + Collins') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5))

dens.vw <- court.plotter.lines(fg.plot = dens.vw) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)
dens.zc <- court.plotter.lines(fg.plot = dens.zc) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)
dens.both <- court.plotter.lines(fg.plot = dens.both) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)

plot_grid(dens.vw, dens.zc, dens.both,
          ncol = 3)

# Clean up environment. ---------------------------------------------------

rm(list = setdiff(ls(), c('both', 'both.cell', 'on.vw', 'on.zc', 'vw',
                          'vw.cell', 'zc', 'zc.cell', 'court.plotter.lines',
                          'xlim.rim', 'ylim.rim')))

# Calculate difference in bins. -------------------------------------------

cells <- full_join(vw.cell, zc.cell, by = 'cell', suffix = c('', '.zc')) %>%
  full_join(both.cell, by = 'cell', suffix = c('.vw', '.both'))

max(cells$x.vw - cells$x.zc, na.rm = TRUE)
max(cells$x.vw - cells$x.both, na.rm = TRUE)
max(cells$y.vw - cells$y.zc, na.rm = TRUE)
max(cells$y.vw - cells$y.both, na.rm = TRUE)

cells <- cells %>%
  select(-c(x.vw, y.vw, x.zc, y.zc)) %>%
  rename('x' = x.both,
         'y' = y.both)

cells <- cells %>%
  mutate(attempt.rate.vw = attempts.vw / sum(attempts.vw, na.rm = TRUE),
         attempt.rate.zc = attempts.zc / sum(attempts.zc, na.rm = TRUE),
         attempt.rate.both = attempts.both / sum(attempts.both, na.rm = TRUE))

cells <- cells %>%
  mutate(max.attempt.rate = pmax(attempt.rate.vw,
                                 attempt.rate.zc,
                                 attempt.rate.both,
                                 na.rm = TRUE)) %>%
  mutate(max.c = case_when(max.attempt.rate == attempt.rate.vw ~ 'Wembanyama',
                           max.attempt.rate == attempt.rate.zc ~ 'Collins',
                           TRUE ~ 'Wembanyama + Collins'))

c.color <- data.frame(
  c = c('Wembanyama', 'Collins', 'Wembanyama + Collins'),
  col = c('#EF426F', '#00B2A9', '#FF8200')
)

cells <- cells %>%
  left_join(c.color, by = c('max.c' = 'c'))

max.c <- ggplot(data = cells,
                aes(x = x,
                    y = y)) +
  geom_hex(aes(fill = col),
           stat = 'identity',
           color = 'white',
           size = 0.5) +
  scale_fill_identity(guide = 'legend',
                      labels = cells$max.c,
                      breaks = cells$col,
                      name = 'Center') +
  ggtitle('Leading Defending Center by Zone',
          subtitle = 'Highest Opponent FGA Rate') +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

max.c <- court.plotter.lines(fg.plot = max.c) +
  coord_fixed(xlim = xlim.rim, ylim = ylim.rim)
max.c
