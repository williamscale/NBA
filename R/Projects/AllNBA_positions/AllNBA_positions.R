# Author: Cale Williams
# Last Updated: 01/02/2022

# ADMINISTRATIVE WORK -----------------------------------------------------

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

# Import libraries.
library(readxl)
library(dplyr)
library(stringr)

setwd('MyProjects/NBA/R/Projects/AllNBA_positions')

source('../../Scrapers/bballref_playerlinks.R')
source('../../Scrapers/bballref_player_pbp.R')

# PREPARE DATA ------------------------------------------------------------

# Get all players listed in basketball reference.
players <- player_bballref(player = 'ALL')

# Read in All-NBA team data.
allnba <- read_excel('AllNBA.xlsx',
                     col_names = FALSE)

# Change name of columns.
cols <- c('Season', 'Team', 'C', 'F1', 'F2', 'G1', 'G2')
names(allnba) <- cols

# Remove position from entries.
allnba$C <- str_sub(allnba$C, 1, nchar(allnba$C) - 2)
allnba$F1 <- str_sub(allnba$F1, 1, nchar(allnba$F1) - 2)
allnba$F2 <- str_sub(allnba$F2, 1, nchar(allnba$F2) - 2)
allnba$G1 <- str_sub(allnba$G1, 1, nchar(allnba$G1) - 2)
allnba$G2 <- str_sub(allnba$G2, 1, nchar(allnba$G2) - 2)

# Remove data in which positional proportion is unavailable.
allnba_positions <- allnba[allnba[, 'Season'] >= '1996-97', ]

# CENTER ------------------------------------------------------------------

# Combine datasets.
C_urls <- left_join(allnba_positions,
                    players,
                    by = c('C' = 'player_name')) %>%
  dplyr::select(C, Season, Team, player_url) %>%
  arrange(desc(Season), Team)
  
# Remove Patrick Ewing (son).
# https://www.basketball-reference.com/players/e/ewingpa02.html
C_urls <- C_urls[-75, ]

# FORWARDS ----------------------------------------------------------------

# Combine datasets.
F1_urls <- left_join(allnba_positions,
                     players,
                     by = c('F1' = 'player_name')) %>%
  dplyr::select(F1, Season, Team, player_url) %>%
  arrange(desc(Season), Team) %>%
  rename('F' = 'F1')

F2_urls <- left_join(allnba_positions,
                     players,
                     by = c('F2' = 'player_name')) %>%
  dplyr::select(F2, Season, Team, player_url) %>%
  arrange(desc(Season), Team) %>%
  rename('F' = 'F2')

# Remove David Lee.
# https://www.basketball-reference.com/players/l/leeda01.html
F2_urls <- F2_urls[-27, ]

# Combine datasets.
F_urls <- rbind(F1_urls, F2_urls) %>%
  arrange(desc(Season), Team)

# GUARDS ------------------------------------------------------------------

# Combine datasets.
G1_urls <- left_join(allnba_positions,
                     players,
                     by = c('G1' = 'player_name')) %>%
  dplyr::select(G1, Season, Team, player_url) %>%
  arrange(desc(Season), Team) %>%
  rename('G' = 'G1')

G2_urls <- left_join(allnba_positions,
                     players,
                     by = c('G2' = 'player_name')) %>%
  dplyr::select(G2, Season, Team, player_url) %>%
  arrange(desc(Season), Team) %>%
  rename('G' = 'G2')

# Combine datasets.
G_urls <- rbind(G1_urls, G2_urls) %>%
  arrange(desc(Season), Team)

# POSITION DATA -----------------------------------------------------------

G_pg <- c()
G_sg <- c()
G_sf <- c()
G_pf <- c()
G_c <- c()

F_pg <- c()
F_sg <- c()
F_sf <- c()
F_pf <- c()
F_c <- c()

C_pg <- c()
C_sg <- c()
C_sf <- c()
C_pf <- c()
C_c <- c()

for (i in 1:nrow(G_urls)) {
  
  G_year <- G_urls$Season[i]
  F_year <- F_urls$Season[i]
  
  G_data_i <- player_bballref_pbp(G_urls$player_url[i])
  F_data_i <- player_bballref_pbp(F_urls$player_url[i])
  
  G_row_i <- which(G_data_i$Season == G_year)[1]
  F_row_i <- which(F_data_i$Season == F_year)[1]
  
  G_pg <- c(G_pg, G_data_i[G_row_i, 8])
  G_sg <- c(G_sg, G_data_i[G_row_i, 9])
  G_sf <- c(G_sf, G_data_i[G_row_i, 10])
  G_pf <- c(G_pf, G_data_i[G_row_i, 11])
  G_c <- c(G_c, G_data_i[G_row_i, 12])
  F_pg <- c(F_pg, F_data_i[F_row_i, 8])
  F_sg <- c(F_sg, F_data_i[F_row_i, 9])
  F_sf <- c(F_sf, F_data_i[F_row_i, 10])
  F_pf <- c(F_pf, F_data_i[F_row_i, 11])
  F_c <- c(F_c, F_data_i[F_row_i, 12])
  
}

for (i in 1:nrow(C_urls)) {

  C_year <- C_urls$Season[i]

  C_data_i <- player_bballref_pbp(C_urls$player_url[i])

  C_row_i <- which(C_data_i$Season == C_year)[1]

  C_pg <- c(C_pg, C_data_i[C_row_i, 8])
  C_sg <- c(C_sg, C_data_i[C_row_i, 9])
  C_sf <- c(C_sf, C_data_i[C_row_i, 10])
  C_pf <- c(C_pf, C_data_i[C_row_i, 11])
  C_c <- c(C_c, C_data_i[C_row_i, 12])

}

G_urls$pg_perc <- G_pg
G_urls$sg_perc <- G_sg
G_urls$sf_perc <- G_sf
G_urls$pf_perc <- G_pf
G_urls$c_perc <- G_c

F_urls$pg_perc <- F_pg
F_urls$sg_perc <- F_sg
F_urls$sf_perc <- F_sf
F_urls$pf_perc <- F_pf
F_urls$c_perc <- F_c

C_urls$pg_perc <- C_pg
C_urls$sg_perc <- C_sg
C_urls$sf_perc <- C_sf
C_urls$pf_perc <- C_pf
C_urls$c_perc <- C_c



