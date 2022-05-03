# Clear workspace and set seed.
# rm(list = ls())
# set.seed(55)

player_url_bballref <- function(player = 'ALL', last.init = NA) {

  setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Scrapers')

  # Import libraries.
  library(rvest)
  library(qpcR)
  library(stringr)
  library(dplyr)
  
  urls <- c()
  player_url <- c()
  player_name <- c()
  player_data <- c()
  
  if (player == 'ALL') {
    
    # Create vector of letters for players' last names.
    # No player has last name starting with X.
    alpha <- letters[-24]
    
    for (i in alpha) {
      
      url <- paste("https://www.basketball-reference.com/players/", i, "/",
                   sep = "")
      
      url_data <- read_html(url)
      
      player_name <- c(player_name, tail(url_data %>%
                                           html_nodes("th") %>%
                                           html_text(),
                                         n = -8))
      
      player_name <- str_replace(string = player_name,
                                 pattern = '\\*',
                                 replacement = '')
      
      player_data <- c(player_data, url_data %>%
                         html_nodes("td") %>%
                         html_text())
      
      yr_start <- player_data[seq(1,length(player_data), 7)]
      yr_end <- player_data[seq(2,length(player_data), 7)]
      
      all_url <- html_attr(html_nodes(url_data, "a"), "href")
      
      name_urls <- c()
      
      pattern <- "/players/."
      
      for (j in all_url) {
        
        if (grepl("#header", j)) {
          
          break
          
        } else if (grepl(pattern, j)) {
          
          name_urls <- c(name_urls, j)
          
        }
        
      }
      
      player_url <- c(player_url, name_urls)
      
    }
    
    player_url <- paste("https://www.basketball-reference.com", player_url,
                        sep = "")
    
    player_mat <- qpcR:::cbind.na(player_name, player_url, yr_start, yr_end)
    players <- as.data.frame(player_mat)
    
    return(players)
  
  } else {
    
    url <- paste("https://www.basketball-reference.com/players/", last.init,
                 "/", sep = "")
    
   
    
    url_data <- read_html(url)
    

    
    
    player_name <- c(player_name, tail(url_data %>%
                                         html_nodes("th") %>%
                                         html_text(),
                                       n = -8))
    

    player_name <- str_replace(string = player_name,
                               pattern = '\\*',
                               replacement = '')
    
    player_data <- c(player_data, url_data %>%
                       html_nodes("td") %>%
                       html_text())
    
    yr_start <- player_data[seq(1,length(player_data), 7)]
    yr_end <- player_data[seq(2,length(player_data), 7)]
    
    all_url <- html_attr(html_nodes(url_data, "a"), "href")

    name_urls <- c()
    
    pattern <- "/players/."
    
    for (j in all_url) {
      
      if (grepl("#header", j)) {
        
        break
        
      } else if (grepl(pattern, j)) {
        
        name_urls <- c(name_urls, j)
        
      }
      
    }
    
    player_url <- c(player_url, name_urls)

  
  
    player_url <- paste("https://www.basketball-reference.com", player_url,
                      sep = "")
  
    player_mat <- qpcR:::cbind.na(player_name, player_url, yr_start, yr_end)
    players <- as.data.frame(player_mat)
    
    players <- players %>%
      filter(player_name == player)
  
    return(players)
  
  }
    
    
}
    
  # if (player == 'ALL') {
  #   
  #   return(players)
  #   
  # } else {
  #     
  #   players <- players %>%
  #     filter(player_name == player)
  #   
  #   return(players)
  #     
  #   }
  


# TESTING -----------------------------------------------------------------

# x <- player_url_bballref(player = 'Jakob Poeltl', last.init = 'p')
