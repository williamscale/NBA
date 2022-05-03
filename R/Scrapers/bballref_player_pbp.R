# Clear workspace and set seed.
# rm(list = ls())
# set.seed(55)

player_bballref_pbp <- function(player_url) {
  
  library(rvest)
  
  player_pbp <- player_url %>%
    read_html %>%
    html_nodes(xpath = '//comment()') %>%
    html_text() %>%
    paste(collapse='') %>%
    read_html() %>% 
    html_node("#pbp") %>% 
    html_table()
  
  colnames(player_pbp)[1] <- 'Season'
  
  return (player_pbp)
  
}