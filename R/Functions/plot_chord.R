# Author: Cale Williams
# Last Updated: 06/30/2022

# Import libraries.
library(readxl)
library(tidyr)
library(dplyr)
library(chorddiag)
library(reshape2)
library(ggplot2)
library(Matrix)

chord.plotter <- function(dataset, stat = 'PASS', pass.filter = 500, ast.filter = 30) {
  
  
  data <- dataset %>%
    filter(TEAM == 'SAS') %>%
    rename('PASS.FROM' = `PASS FROM`, 'PASS.TO' = `PASS TO`) %>%
    # select(-c(3:4, 9, 12, 15))
    select(-c(TEAM, 4, `FG%`, `2FG%`, `3FG%`))
  
  # Fix name discrepancy.
  data[data == 'Primo, Joshua'] <- 'Primo, Josh'
  
  if (stat == 'PASS') {
    
    other.from.pass <- data %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      distinct(COMBO, .keep_all = TRUE) %>%
      group_by(PASS.FROM) %>%
      summarize(PASS.FROM.QTY = sum(PASS)) %>%
      filter(PASS.FROM.QTY < pass.filter) %>%
      select(PASS.FROM) %>%
      rename('OTHER.PLAYER' = PASS.FROM)

    other.to.pass <- data %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      distinct(COMBO, .keep_all = TRUE) %>%
      group_by(PASS.TO) %>%
      summarize(PASS.TO.QTY = sum(PASS)) %>%
      filter(PASS.TO.QTY < pass.filter) %>%
      select(PASS.TO) %>%
      rename('OTHER.PLAYER' = PASS.TO )
    
    other.pass <- rbind(other.from.pass, other.to.pass) %>%
      distinct()
    other.pass <- other.pass[['OTHER.PLAYER']]
    
    # other.from.pass <- data %>%
    #   group_by(PASS.FROM) %>%
    #   summarize(PASS.FROM.QTY = sum(PASS)) %>%
    #   filter(PASS.FROM.QTY < pass.filter) %>%
    #   select(PASS.FROM)
    # 
    # other.to.pass <- data %>%
    #   group_by(PASS.TO) %>%
    #   summarize(PASS.TO.QTY = sum(PASS)) %>%
    #   filter(PASS.TO.QTY < pass.filter) %>%
    #   select(PASS.TO)
    
    # other.pass <- inner_join(other.from.pass, other.to.pass, by = c('PASS.FROM' = 'PASS.TO'))[['PASS.FROM']]
    
    passes <- data %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      distinct(COMBO, .keep_all = TRUE) %>%
      mutate(OTHER.FLAG = case_when(
        ((!PASS.FROM %in% other.pass) & (!PASS.TO %in% other.pass)) ~ ('A'),
        ((!PASS.FROM %in% other.pass) & (PASS.TO %in% other.pass)) ~ ('B'),
        ((PASS.FROM %in% other.pass) & (!PASS.TO %in% other.pass)) ~ ('C'),
        ((PASS.FROM %in% other.pass) & (PASS.TO %in% other.pass)) ~ ('D')))
    
    passes.A <- passes[passes$OTHER.FLAG == 'A', ] %>%
      select(-c(OTHER.FLAG, COMBO))
    passes.other.B <- passes[passes$OTHER.FLAG == 'B', ] %>%
      group_by(PASS.FROM) %>%
      summarize_if(is.numeric, sum) %>%
      mutate(PASS.TO = 'OTHER')
    passes.other.C <- passes[passes$OTHER.FLAG == 'C', ] %>%
      group_by(PASS.TO) %>%
      summarize_if(is.numeric, sum) %>%
      mutate(PASS.FROM = 'OTHER')
    passes.other.D <- passes[passes$OTHER.FLAG == 'D', ] %>%
      summarize_if(is.numeric, sum) %>%
      mutate(PASS.FROM = 'OTHER') %>%
      mutate(PASS.TO = 'OTHER')
    
    pass <- rbind(passes.A, passes.other.B, passes.other.C, passes.other.D) %>%
      separate(PASS.FROM, into = c('PASS.FROM', 'FIRST'), sep = ',') %>%
      select(-FIRST) %>%
      separate(PASS.TO, into = c('PASS.TO', 'FIRST'), sep = ',') %>%
      select(-FIRST) %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      filter(COMBO != 'Murray.Murray')
    
    pass.chord <- pass %>%
      select(c(1:3)) %>%
      group_by(PASS.FROM) %>%
      mutate(ID.FROM = cur_group_id()) %>%
      ungroup() %>%
      group_by(PASS.TO) %>%
      mutate(ID.TO = cur_group_id())
    
    pass.chord.mat <- as.matrix(sparseMatrix(i = pass.chord$ID.FROM,
                                             j = pass.chord$ID.TO,
                                             x = pass.chord$PASS))
    
    ID.map.pass <- pass.chord %>%
      ungroup() %>%
      select(PASS.FROM, ID.FROM) %>%
      distinct(PASS.FROM, .keep_all = TRUE) %>%
      arrange(ID.FROM)
    
    rownames(pass.chord.mat) <- ID.map.pass$PASS.FROM
    colnames(pass.chord.mat) <- ID.map.pass$PASS.FROM
    
    chord.plot <- chorddiag(pass.chord.mat,
              showTicks = FALSE,
              margin = 120,
              groupedgeColor = 'black',
              tooltipNames = NULL)
    
  } else if (stat == 'ASSIST') {
    
    other.from.ast <- data %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      distinct(COMBO, .keep_all = TRUE) %>%
      group_by(PASS.FROM) %>%
      summarize(AST.FROM.QTY = sum(AST)) %>%
      filter(AST.FROM.QTY < ast.filter) %>%
      select(PASS.FROM) %>%
      rename('OTHER.PLAYER' = PASS.FROM)

    other.to.ast <- data %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      distinct(COMBO, .keep_all = TRUE) %>%
      group_by(PASS.TO) %>%
      summarize(AST.TO.QTY = sum(AST)) %>%
      filter(AST.TO.QTY < ast.filter) %>%
      select(PASS.TO) %>%
      rename('OTHER.PLAYER' = PASS.TO )
    
    other.ast <- rbind(other.from.ast, other.to.ast) %>%
      distinct()
    other.ast <- other.ast[['OTHER.PLAYER']]

    asts <- data %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      distinct(COMBO, .keep_all = TRUE) %>%
      mutate(OTHER.FLAG = case_when(
        ((!PASS.FROM %in% other.ast) & (!PASS.TO %in% other.ast)) ~ ('A'),
        ((!PASS.FROM %in% other.ast) & (PASS.TO %in% other.ast)) ~ ('B'),
        ((PASS.FROM %in% other.ast) & (!PASS.TO %in% other.ast)) ~ ('C'),
        ((PASS.FROM %in% other.ast) & (PASS.TO %in% other.ast)) ~ ('D')))
    
    asts.A <- asts[asts$OTHER.FLAG == 'A', ] %>%
      select(-c(OTHER.FLAG, COMBO))
    asts.other.B <- asts[asts$OTHER.FLAG == 'B', ] %>%
      group_by(PASS.FROM) %>%
      summarize_if(is.numeric, sum) %>%
      mutate(PASS.TO = 'OTHER')
    asts.other.C <- asts[asts$OTHER.FLAG == 'C', ] %>%
      group_by(PASS.TO) %>%
      summarize_if(is.numeric, sum) %>%
      mutate(PASS.FROM = 'OTHER')
    asts.other.D <- asts[asts$OTHER.FLAG == 'D', ] %>%
      summarize_if(is.numeric, sum) %>%
      mutate(PASS.FROM = 'OTHER') %>%
      mutate(PASS.TO = 'OTHER')
    
    ast <- rbind(asts.A, asts.other.B, asts.other.C, asts.other.D) %>%
      separate(PASS.FROM, into = c('PASS.FROM', 'FIRST'), sep = ',') %>%
      select(-FIRST) %>%
      separate(PASS.TO, into = c('PASS.TO', 'FIRST'), sep = ',') %>%
      select(-FIRST) %>%
      mutate(COMBO = paste(PASS.FROM, PASS.TO, sep = '.')) %>%
      filter(COMBO != 'Murray.Murray')
    
    ast.chord <- ast %>%
      select(c(1:2, 4)) %>%
      group_by(PASS.FROM) %>%
      mutate(ID.FROM = cur_group_id()) %>%
      ungroup() %>%
      group_by(PASS.TO) %>%
      mutate(ID.TO = cur_group_id())
    
    ast.chord.mat <- as.matrix(sparseMatrix(i = ast.chord$ID.FROM,
                                            j = ast.chord$ID.TO,
                                            x = ast.chord$AST))
    
    ID.map.ast <- ast.chord %>%
      ungroup() %>%
      select(PASS.FROM, ID.FROM) %>%
      distinct(PASS.FROM, .keep_all = TRUE) %>%
      arrange(ID.FROM)
    
    rownames(ast.chord.mat) <- ID.map.ast$PASS.FROM
    colnames(ast.chord.mat) <- ID.map.ast$PASS.FROM
    
    chord.plot <- chorddiag(ast.chord.mat,
              showTicks = FALSE,
              margin = 120,
              groupedgeColor = 'black',
              tooltipNames = NULL)
    
  } else {
    print('Invalid stat selected.')
  }
  

  return(chord.plot)
  
}



# TESTING -----------------------------------------------------------------

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Functions')

# Read in data.
pass.data <- read_excel('./../Projects/Passing/data_2021-22.xlsx')

chord.plotter(data = pass.data,
              stat = 'PASS',
              pass.filter = 1000,
              ast.filter = 75)
