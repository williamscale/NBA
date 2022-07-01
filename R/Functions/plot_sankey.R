# Author: Cale Williams
# Last Updated: 07/01/2022

# Import libraries.
library(readxl)
library(tidyr)
library(dplyr)
library(reshape2)
library(ggsankey)
library(ggplot2)
library(stringr)
library(plotly)
library(forcats)
library(ggthemes)

# FUNCTION ----------------------------------------------------------------

sankey.plotter <- function(dataset, player = 'Murray, Dejounte', top.n = 5) {
  
  player.id <- strsplit(player, split = ',')[[1]][1]
  
  data.raw <- dataset
  
  data <- data.raw %>%
    filter(TEAM == 'SAS') %>%
    rename('PASS.FROM' = `PASS FROM`, 'PASS.TO' = `PASS TO`,
           'FG2M' = `2FGM`, 'FG2A' = `2FGA`,
           'FG3M' = `3FGM`, 'FG3A' = `3FGA`) 
  
  # Fix name discrepancy.
  data[data == 'Primo, Joshua'] <- 'Primo, Josh'
  
  # pass.from <- data %>%
  #   group_by(PASS.FROM) %>%
  #   summarize(passes = sum(PASS)) %>%
  #   arrange(desc(passes))
  # print(pass.from)
  
  player.summary <- data %>%
    filter(PASS.FROM == player) %>%
    separate(PASS.FROM, into = c('PASS.FROM', 'FIRST'), sep = ',') %>%
    select(-FIRST) %>%
    separate(PASS.TO, into = c('PASS.TO', 'FIRST'), sep = ',') %>%
    select(-c(FIRST, `FREQ M%`, `FG%`, `2FG%`, `3FG%`)) %>%
    mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
    distinct(COMBO, .keep_all = TRUE) %>%
    filter(COMBO != 'Murray.Murray')
  
  top.PASS.TO <- player.summary %>%
    slice_max(PASS, n = top.n) %>%
    pull(PASS.TO)
  
  player.summary <- player.summary %>%
    mutate(COMBO = replace(COMBO, !PASS.TO %in% top.PASS.TO, paste(player.id, '.Other', sep = ''))) %>%
    mutate(PASS.TO = replace(PASS.TO, COMBO == paste(player.id, '.Other', sep = ''), 'Other')) %>%
    group_by(COMBO) %>%
    summarize(across(where(is.numeric), sum)) %>%
    separate(COMBO, into = c('PASS.FROM', 'PASS.TO'), sep = '[.]', remove = FALSE)
  
  
  # player.summary <- data %>%
  #   filter(PASS.FROM == player) %>%
  #   separate(PASS.FROM, into = c('PASS.FROM', 'FIRST'), sep = ',') %>%
  #   select(-FIRST) %>%
  #   separate(PASS.TO, into = c('PASS.TO', 'FIRST'), sep = ',') %>%
  #   select(-c(FIRST, `FREQ M%`, `FG%`, `2FG%`, `3FG%`)) %>%
  #   mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
  #   distinct(COMBO, .keep_all = TRUE) %>%
  #   filter(COMBO != 'Murray.Murray') %>%
  #   mutate(COMBO = replace(COMBO, PASS < 300, paste(player.id, '.Other', sep = ''))) %>%
  #   mutate(PASS.TO = replace(PASS.TO, COMBO == paste(player.id, '.Other', sep = ''), 'Other')) %>%
  #   group_by(COMBO) %>%
  #   summarize(across(where(is.numeric), sum)) %>%
  #   separate(COMBO, into = c('PASS.FROM', 'PASS.TO'), sep = '[.]', remove = FALSE)
  
  player.expanded <- player.summary %>%
    rename('PASS.n' = PASS, 'AST.n' = AST, 'FGM.n' = FGM, 'FGA.n' = FGA,
           'FG2M.n' = FG2M, 'FG2A.n' = FG2A, 'FG3M.n' = FG3M, 'FG3A.n' = FG3A)
  player.expanded <- player.expanded[rep(row.names(player.expanded), 5), ] %>%
    group_by(PASS.TO) %>%
    mutate(COUNTER = row_number()) %>%
    mutate(OUTCOME = case_when(
      (COUNTER == 1) ~ ('FG2.Miss'),
      (COUNTER == 2) ~ ('FG2.Make'),
      (COUNTER == 3) ~ ('FG3.Miss'),
      (COUNTER == 4) ~ ('FG3.Make'),
      (COUNTER == 5) ~ ('No.FGA'))) %>%
    mutate(VALUE = case_when(
      (COUNTER == 1) ~ (FG2A.n - FG2M.n),
      (COUNTER == 2) ~ (FG2M.n),
      (COUNTER == 3) ~ (FG3A.n - FG3M.n),
      (COUNTER == 4) ~ (FG3M.n),
      (COUNTER == 5) ~ (PASS.n - FGA.n))) %>%
    arrange(PASS.TO, OUTCOME)
  
  player.expanded <- player.expanded[rep(seq(nrow(player.expanded)), player.expanded$VALUE), ]
  
  player.sankey <- data.frame(x = c('PASS.FROM', 'PASS.TO', 'OUTCOME'),
                              node = rep(c(NA), 3),
                              next_x = c('PASS.TO', 'OUTCOME', NA),
                              next_node = rep(c(NA), 3))
  player.sankey <- player.sankey[rep(seq_len(nrow(player.sankey)), nrow(player.expanded)), ]
  
  player.expanded.fit <- rbind(player.expanded, player.expanded, player.expanded)
  
  for (i in 1:nrow(player.sankey)) {
    
    if (player.sankey[i, 'x'] == 'PASS.FROM') {
      player.sankey[i, 'node'] = player.id
      player.sankey[i, 'next_node'] = player.expanded.fit[i, 'PASS.TO']
    } else if (player.sankey[i, 'x'] == 'PASS.TO') {
      player.sankey[i, 'node'] = player.expanded.fit[i, 'PASS.TO']
      player.sankey[i, 'next_node'] = player.expanded.fit[i, 'OUTCOME']
    } else {
      player.sankey[i, 'node'] = player.expanded.fit[i, 'OUTCOME']
    }
    
  }
  
  
  # murray.sankey$x <- fct_relevel(as.factor(murray.sankey$x), c('PASS.FROM', 'PASS.TO', 'OUTCOME'))
  # murray.sankey$next_x <- fct_relevel(fct_expand(as.factor(murray.sankey$next_x), 'PASS.FROM'), c('PASS.FROM', 'PASS.TO', 'OUTCOME'))
  
  player.sankey$x <- factor(player.sankey$x,
                            levels =  c('PASS.FROM', 'PASS.TO', 'OUTCOME'))
  player.sankey$next_x <- factor(player.sankey$next_x,
                                 levels =  c('PASS.FROM', 'PASS.TO', 'OUTCOME'))
  
  player.sankey <- tibble(player.sankey)
  
  # unique(player.sankey$x)
  # unique(player.sankey$next_x)
  
  player.sankey.count <- player.sankey %>%
    group_by(node) %>%
    tally()
  
  flow <- merge(player.sankey, player.sankey.count, by.x = 'node', by.y = 'node', all.x = TRUE)
  
  flow.plot <- ggplot(flow,
         aes(x = x,
             next_x = next_x,
             node = node,
             next_node = next_node,
             fill = factor(node),
             label = paste(node, ' n = ', n))) +
    geom_sankey(flow.alpha = 1) +
    geom_sankey_label(color = 'white',
                      hjust = 0.8,
                      size = 5) +
    ggtitle(paste(player.id, '\'s Passes', sep = '')) +
    theme_solarized_2() +
    scale_fill_viridis_d() +
    theme(axis.title = element_blank(),
          axis.text.x = element_text(size = 20, face = 'bold'),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          legend.position = 'none',
          plot.title = element_text(size = 30))
  
  return(flow.plot)
  
}

sankey.interactive.plotter <- function(dataset, player = 'Murray, Dejounte', top.n = 5) {
  
  player.id <- strsplit(player, split = ',')[[1]][1]
  
  data.raw <- dataset
  
  data <- data.raw %>%
    filter(TEAM == 'SAS') %>%
    rename('PASS.FROM' = `PASS FROM`, 'PASS.TO' = `PASS TO`,
           'FG2M' = `2FGM`, 'FG2A' = `2FGA`,
           'FG3M' = `3FGM`, 'FG3A' = `3FGA`) 
  
  # Fix name discrepancy.
  data[data == 'Primo, Joshua'] <- 'Primo, Josh'
  
  player.summary <- data %>%
    filter(PASS.FROM == player) %>%
    separate(PASS.FROM, into = c('PASS.FROM', 'FIRST'), sep = ',') %>%
    select(-FIRST) %>%
    separate(PASS.TO, into = c('PASS.TO', 'FIRST'), sep = ',') %>%
    select(-c(FIRST, `FREQ M%`, `FG%`, `2FG%`, `3FG%`)) %>%
    mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
    distinct(COMBO, .keep_all = TRUE) %>%
    filter(COMBO != 'Murray.Murray')
  
  top.PASS.TO <- player.summary %>%
    slice_max(PASS, n = top.n) %>%
    pull(PASS.TO)
  
  player.summary <- player.summary %>%
    mutate(COMBO = replace(COMBO, !PASS.TO %in% top.PASS.TO, paste(player.id, '.Other', sep = ''))) %>%
    mutate(PASS.TO = replace(PASS.TO, COMBO == paste(player.id, '.Other', sep = ''), 'Other')) %>%
    group_by(COMBO) %>%
    summarize(across(where(is.numeric), sum)) %>%
    separate(COMBO, into = c('PASS.FROM', 'PASS.TO'), sep = '[.]', remove = FALSE)
  
  player.summary$FG2Miss <- player.summary$FG2A - player.summary$FG2M
  player.summary$FG3Miss <- player.summary$FG3A - player.summary$FG3M
  player.summary$NoFGA <- player.summary$PASS - player.summary$FGA
  
  outcomes <- c('FG2Make', 'FG2Miss', 'FG3Make', 'FG3Miss', 'NoFGA')
  nodes <- list(label = c(player.id, unique(player.summary$PASS.TO), outcomes))
  
  source.PASS.FROM <- rep(0, nrow(player.summary))
  source.PASS.TO <- rep(seq(1, nrow(player.summary)), length(outcomes))
  # target.OUTCOME <- rep(seq(nrow(player.summary) + 1, nrow(player.summary) + length(outcomes)), nrow(player.summary))
  target.OUTCOME <- rep(seq(nrow(player.summary) + 1, nrow(player.summary) + length(outcomes)), each = nrow(player.summary))
  
  links <- list(source = c(source.PASS.FROM, source.PASS.TO),
                target = c(seq(1, nrow(player.summary)), target.OUTCOME),
                value = c(player.summary$PASS, player.summary$FG2M, player.summary$FG2Miss, player.summary$FG3M, player.summary$FG3Miss, player.summary$NoFGA))
  
  links.df <- as.data.frame(links)
  
  flow.plot <- plot_ly(
    type = "sankey",
    orientation = "h",
    node = nodes,
    link = links)
  
  return(flow.plot)
  
}

# TESTING -----------------------------------------------------------------

# setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Functions')
# 
# # Read in data.
# pass.data <- read_excel('./../Projects/Passing/data_2021-22.xlsx')

# sankey.plotter(data = pass.data,
#                player = 'Murray, Dejounte',
#                top.n = 5)

# sankey.interactive.plotter(data = pass.data,
#                player = 'Murray, Dejounte',
#                top.n = 5)
