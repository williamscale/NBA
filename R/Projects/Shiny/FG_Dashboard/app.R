# FG Dashboard 2021-22
# Author: Cale Williams
# Last Updated: 06/27/2022


# Import libraries.
library(shiny)
library(bslib)
library(dplyr)
library(lubridate)
library(ggplot2)
library(plotly)
library(ggthemes)
library(htmlwidgets)

source('./drawNBAcourt.R')
source('./shotchart_bivariate.R')
source('./shotchart_topn_hex.R')
source('./shotchart_kde.R')
source('./shotchart_bivariate_team.R')
source('./shotchart_topn_hex_team.R')
source('./shotchart_kde_team.R')

# library(gpx)
# library(dplyr)
# library(ggplot2)
# library(ggthemes)
# library(sf)
# library(geosphere)
# library(shinythemes)
# library(lubridate)
# library(leaflet)
# library(purrr)
# library(slickR)
# library(plotly)
# library(htmlwidgets)
# library(lubridate)
# library(cowplot)
# library(tidyr)

# source('./drawNBAcourt.R')
# source('./shotchart_bivariate.R')
# source('./shotchart_topn_hex.R')
# source('./shotchart_kde.R')

# load('C:/Users/caler/Documents/MyProjects/NBA/R/Projects/FG_Dashboard/Data/data_raw_2021-22.RData')
# regular$season.type <- 'Regular Season'
# regular$season.url <- 'Regular%20Season'
# playin$season.type <- 'Play-In'
# playin$season.url <- 'PlayIn'
# playoffs$season.type <- 'Playoffs'
# playoffs$season.url <- 'Playoffs'
# 
# 
# data.raw <- rbind(regular, playin, playoffs)
# #
# data <- data.raw[data.raw$LOC_Y <= 0, ]
# data$PERIOD[data$PERIOD > 4] <- 'OT'
# 
# data$TEAM_NAME[data$TEAM_NAME == 'Los Angeles Lakers'] <- 'LA Lakers'
# team.codes <- data.frame(abb = c('ATL', 'BKN', 'BOS', 'CHA', 'CHI', 'CLE',
#                                  'DAL', 'DEN', 'DET', 'GSW', 'HOU', 'IND',
#                                  'LAC', 'LAL', 'MEM', 'MIA', 'MIL', 'MIN',
#                                  'NOP', 'NYK', 'OKC', 'ORL', 'PHI', 'PHX',
#                                  'POR', 'SAC', 'SAS', 'TOR', 'UTA', 'WAS'),
#                          full = c('Atlanta Hawks', 'Brooklyn Nets', 'Boston Celtics',
#                                   'Charlotte Hornets', 'Chicago Bulls', 'Cleveland Cavaliers',
#                                   'Dallas Mavericks', 'Denver Nuggets', 'Detroit Pistons',
#                                   'Golden State Warriors', 'Houston Rockets', 'Indiana Pacers',
#                                   'LA Clippers', 'LA Lakers', 'Memphis Grizzlies',
#                                   'Miami Heat', 'Milwaukee Bucks', 'Minnesota Timberwolves',
#                                   'New Orleans Pelicans', 'New York Knicks', 'Oklahoma City Thunder',
#                                   'Orlando Magic', 'Philadelphia 76ers', 'Phoenix Suns',
#                                   'Portland Trail Blazers', 'Sacramento Kings', 'San Antonio Spurs',
#                                   'Toronto Raptors', 'Utah Jazz', 'Washington Wizards'))
# #
# data <- left_join(data, team.codes, by = c('HTM' = 'abb'))
# data <- data %>%
#   rename(HTM.FULL = full)
# data$HOME.AWAY <- ifelse(data$TEAM_NAME == data$HTM.FULL, 'HOME', 'AWAY')
# #
# data$DATE <- mdy(paste(substr(data$GAME_DATE, 5, 6),
#                        substr(data$GAME_DATE, 7, 8),
#                        substr(data$GAME_DATE, 1, 4),
#                        sep = '/'))
# 
# data$OPP <- ifelse(data$HOME.AWAY == 'HOME', data$VTM, data$HTM)
# 
# data$TIME <- paste('Q', data$PERIOD, ' ',
#                    sprintf('%02d', data$MINUTES_REMAINING),
#                    ':', sprintf('%02d', data$SECONDS_REMAINING), sep = '')
# 
# data$URL <- paste('https://www.nba.com/stats/events/?CFID=&CFPARAMS=&ContextMeasure=FGA&EndPeriod=0&EndRange=28800&GameID=00',
#                   data$GAME_ID, '&PlayerID=', data$PLAYER_ID,
#                   '&RangeType=0&Season=2021-22&SeasonType=', data$season.url,
#                   '&StartPeriod=0&StartRange=0&TeamID=', data$TEAM_ID,
#                   '&flag=3&sct=plot&section=game&CF=SHOT_DISTANCE*E*',
#                   data$SHOT_DISTANCE, ':p*E*', data$PERIOD, sep = '')
# 
# data$COLOR <- ifelse(data$SHOT_MADE_FLAG == 1, '#2aa198', '#dc322f')

load('./Data/data_2021-22.RData')

# data.raw$ROUND <- NA
# 
# # First round
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'PHX') | (data.raw$VTM == 'PHX')) &
#                  ((data.raw$HTM == 'NOP') | (data.raw$VTM == 'NOP'))] <- 'Round 1'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'MEM') | (data.raw$VTM == 'MEM')) &
#                  ((data.raw$HTM == 'MIN') | (data.raw$VTM == 'MIN'))] <- 'Round 1'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'GSW') | (data.raw$VTM == 'GSW')) &
#                  ((data.raw$HTM == 'DEN') | (data.raw$VTM == 'DEN'))] <- 'Round 1'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'DAL') | (data.raw$VTM == 'DAL')) &
#                  ((data.raw$HTM == 'UTA') | (data.raw$VTM == 'UTA'))] <- 'Round 1'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'MIA') | (data.raw$VTM == 'MIA')) &
#                  ((data.raw$HTM == 'ATL') | (data.raw$VTM == 'ATL'))] <- 'Round 1'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'BOS') | (data.raw$VTM == 'BOS')) &
#                  ((data.raw$HTM == 'BKN') | (data.raw$VTM == 'BKN'))] <- 'Round 1'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'MIL') | (data.raw$VTM == 'MIL')) &
#                  ((data.raw$HTM == 'CHI') | (data.raw$VTM == 'CHI'))] <- 'Round 1'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'PHI') | (data.raw$VTM == 'PHI')) &
#                  ((data.raw$HTM == 'TOR') | (data.raw$VTM == 'TOR'))] <- 'Round 1'
# 
# # Conference Semis
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'PHX') | (data.raw$VTM == 'PHX')) &
#                  ((data.raw$HTM == 'DAL') | (data.raw$VTM == 'DAL'))] <- 'Round 2'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'GSW') | (data.raw$VTM == 'GSW')) &
#                  ((data.raw$HTM == 'MEM') | (data.raw$VTM == 'MEM'))] <- 'Round 2'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'MIA') | (data.raw$VTM == 'MIA')) &
#                  ((data.raw$HTM == 'PHI') | (data.raw$VTM == 'PHI'))] <- 'Round 2'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'MIL') | (data.raw$VTM == 'MIL')) &
#                  ((data.raw$HTM == 'BOS') | (data.raw$VTM == 'BOS'))] <- 'Round 2'
# 
# # Conference Finals
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'GSW') | (data.raw$VTM == 'GSW')) &
#                  ((data.raw$HTM == 'DAL') | (data.raw$VTM == 'DAL'))] <- 'Conference Finals'
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'MIA') | (data.raw$VTM == 'MIA')) &
#                  ((data.raw$HTM == 'BOS') | (data.raw$VTM == 'BOS'))] <- 'Conference Finals'
# 
# # Finals
# data.raw$ROUND[(data.raw$season.type == 'Playoffs') &
#                  ((data.raw$HTM == 'GSW') | (data.raw$VTM == 'GSW')) &
#                  ((data.raw$HTM == 'BOS') | (data.raw$VTM == 'BOS'))] <- 'Finals'

# UI ----------------------------------------------------------------------

ui <- navbarPage(
  
  title = 'NBA Shot Dashboard 2021-22',
  theme = bs_theme(version = 4,
                   bootswatch = 'solar'),
  
  tabPanel('By Player',
           sidebarLayout(
             sidebarPanel(
               p('Data from NBA.com/stats'),
               # Select season type.
               selectInput(inputId = 'season.bp',
                           label = 'Season Type',
                           choices = as.list(unique(data$season.type)),
                           multiple = TRUE,
                           selected = 'Regular Season'),
               
               # Select team to choose player from.
               # Currently not using this in filter, just in filtering selectInput.
               selectInput(inputId = 'team.bp',
                           label = 'Team',
                           choices = as.list(sort(unique(data$TEAM_NAME)))),
               
               # Select player.
               selectInput(inputId = 'player.bp',
                           label = 'Player',
                           choices = as.list(sort(unique(data$PLAYER_NAME)))),
               
               # Select date range.
               dateRangeInput(inputId = 'daterange.bp',
                              label = 'Date Range',
                              start = '2021-10-19',
                              end = '2022-06-16',
                              min = '2021-10-19',
                              max = '2022-06-16',
                              format = 'mm/dd/yy'),

               selectInput(inputId = 'home.away.bp',
                           label = 'Home/Away',
                           choices = as.list(c('ALL', 'HOME', 'AWAY'))),
               selectInput(inputId = 'opponent.bp',
                           label = 'Opponent',
                           choices = c('ALL', sort(unique(data$OPP)))),
               selectInput(inputId = 'period.bp',
                           label = 'Period',
                           choices = as.list(c('ALL', sort(unique(data$PERIOD))))),
               
               
               p(em('Excludes heaves')),
               width = 2),
             
             mainPanel(textOutput('PlayerName'),
                       br(),
                       fluidRow(column(width = 4,
                                       p(strong('2P%:'),
                                         textOutput('EFFICIENCY2.bp', inline = TRUE),
                                         '(', textOutput('FGM2.bp', inline = TRUE), '/', textOutput('FGA2.bp', inline = TRUE), ')'
                                         # style = 'display: inline; text-align: left; font-size: 20px'
                                         )),
                                column(width = 4,
                                       p(strong('3P%:'),
                                         textOutput('EFFICIENCY3.bp', inline = TRUE),
                                         '(', textOutput('FGM3.bp', inline = TRUE), '/', textOutput('FGA3.bp', inline = TRUE), ')'
                                         # style = 'display: inline; text-align: left; font-size: 20px'
                                         )),
                                column(width = 4,
                                       p(strong('eFG%:'),
                                         textOutput('EFG.bp', inline = TRUE)
                                         
                                         # style = 'display: inline; text-align: left; font-size: 20px'
                                         ))),
                       fluidRow(column(width = 12,
                                       plotlyOutput('PlayerShotchart', height = '1000px', width = '1000px'))),
                       br(),
                       fluidRow(column(width = 12,
                                       plotOutput('PlayerShotchartBi', height = '1000px', width = '1000px'))),
                       br(),
                       fluidRow(column(width = 12,
                                       plotOutput('PlayerShotchartTopN', height = '1000px', width = '1000px'))),
                       br(),
                       fluidRow(column(width = 12,
                                       plotOutput('PlayerShotchartDens', height = '1000px', width = '1000px'))),
                       tags$style('#PlayerName{font-size: 40px; font-style: bold}',
                                  '#FGM2.bp{display: inline}',
                                  '#FGA2.bp{display: inline}',
                                  '#FGM3.bp{display: inline}',
                                  '#FGA3.bp{display: inline}',
                                  '#EFFICIENCY2.bp{display: inline}',
                                  '#EFFICIENCY3.bp{display: inline}',
                                  '#EFG.bp{display: inline}')))),
  
  tabPanel('By Team',
           sidebarLayout(
             sidebarPanel(
               p('Data from NBA.com/stats'),
               # Select season type.
               selectInput(inputId = 'season.bt',
                           label = 'Season Type',
                           choices = as.list(unique(data$season.type)),
                           multiple = TRUE,
                           selected = 'Regular Season'),
               
               # Select team.
               selectInput(inputId = 'team.bt',
                           label = 'Team',
                           choices = as.list(sort(unique(data$TEAM_NAME)))),
               
               # Select date range.
               dateRangeInput(inputId = 'daterange.bt',
                              label = 'Date Range',
                              start = '2021-10-19',
                              end = '2022-06-16',
                              min = '2021-10-19',
                              max = '2022-06-16',
                              format = 'mm/dd/yy'),
               
               selectInput(inputId = 'home.away.bt',
                           label = 'Home/Away',
                           choices = as.list(c('ALL', 'HOME', 'AWAY'))),
               selectInput(inputId = 'opponent.bt',
                           label = 'Opponent',
                           choices = c('ALL', sort(unique(data$OPP)))),
               selectInput(inputId = 'period.bt',
                           label = 'Period',
                           choices = as.list(c('ALL', sort(unique(data$PERIOD))))),
               
               p(em('Excludes heaves.')),
               
               width = 2),
             mainPanel(textOutput('TeamName'),
                       br(),
                       fluidRow(column(width = 4,
                                       p(strong('2P%:'),
                                         textOutput('EFFICIENCY2.bt', inline = TRUE),
                                         '(', textOutput('FGM2.bt', inline = TRUE), '/', textOutput('FGA2.bt', inline = TRUE), ')'
                                         # style = 'display: inline; text-align: left; font-size: 20px'
                                       )),
                                column(width = 4,
                                       p(strong('3P%:'),
                                         textOutput('EFFICIENCY3.bt', inline = TRUE),
                                         '(', textOutput('FGM3.bt', inline = TRUE), '/', textOutput('FGA3.bt', inline = TRUE), ')'
                                         # style = 'display: inline; text-align: left; font-size: 20px'
                                       )),
                                column(width = 4,
                                       p(strong('eFG%:'),
                                         textOutput('EFG.bt', inline = TRUE)
                                         
                                         # style = 'display: inline; text-align: left; font-size: 20px'
                                       ))),
                       fluidRow(column(width = 12,
                                       plotlyOutput('TeamShotchart', height = '1000px', width = '1000px'))),
                       br(),
                       fluidRow(column(width = 12,
                                       plotOutput('TeamShotchartBi', height = '1000px', width = '1000px'))),
                       br(),
                       fluidRow(column(width = 12,
                                       plotOutput('TeamShotchartTopN', height = '1000px', width = '1000px'))),
                       br(),
                       fluidRow(column(width = 12,
                                       plotOutput('TeamShotchartDens', height = '1000px', width = '1000px'))),
                       tags$style('#TeamName{font-size: 40px; font-style: bold}',
                                  '#FGM2.bt{display: inline}',
                                  '#FGA2.bt{display: inline}',
                                  '#FGM3.bt{display: inline}',
                                  '#FGA3.bt{display: inline}',
                                  '#EFFICIENCY2.bt{display: inline}',
                                  '#EFFICIENCY3.bt{display: inline}',
                                  '#EFG.bt{display: inline}')
                       ))))
  

# Server ------------------------------------------------------------------

server <- function(input, output) {
  
  # BY PLAYER
  # Update choices in team.bp to include only applicable teams based on season.bp.
  # Maybe shouldn't do this by player because of the Derrick Whites.
  # observeEvent(input$season.bp, {
  #   req(input$season.bp)
  #   updateSelectInput(session = getDefaultReactiveDomain(), 'team.bp',
  #                     choices = as.list(sort(unique(data$TEAM_NAME[data$season.type %in% input$season.bp]))))
  # })
  
  # Make team filter optional. Put a note with example (ie Derrick White).
  # Update choices in player.bp to include only applicable player based on team.bp and season.bp.
  observeEvent(input$team.bp, {
    req(input$team.bp)
    updateSelectInput(session = getDefaultReactiveDomain(), 'player.bp',
                      choices = as.list(sort(unique(data$PLAYER_NAME[data$TEAM_NAME %in% input$team.bp & data$season.type %in% input$season.bp]))))
  })
  
  # observeEvent(input$daterange.bp, {
  #   req(input$daterange.bp)
  #   updateSelectInput(session = getDefaultReactiveDomain(), 'player.bp',
  #                     choices = as.list(sort(unique(data$PLAYER_NAME[data$TEAM_NAME %in% input$team.bp & data$season.type %in% input$season.bp]))))
  # })
  
  output$PlayerName <-
    renderText({
      
      input$player.bp
      
    })
  
  
  player.dataset <- reactive({

    player.filtered <- data %>%

      # Filter by season type,
      filter(season.type %in% input$season.bp,
             
             # player name (what about players with same name?)
             PLAYER_NAME == input$player.bp,
             
             # date,
             DATE >= input$daterange.bp[1] & DATE <= input$daterange.bp[2],
             
             # home/away,
             if (input$home.away.bp != 'ALL')
               {HOME.AWAY == input$home.away.bp}
             else
               {HOME.AWAY %in% c('HOME', 'AWAY')},
             
             # opponent,
             if (input$opponent.bp != 'ALL')
               {OPP == input$opponent.bp}
             else
               {OPP %in% c(unique(data$OPP))},
             
             # and period.
             if (input$period.bp != 'ALL')
               {PERIOD == input$period.bp}
             else
               {PERIOD %in% c('1', '2', '3', '4', 'OT')})
    
    return(player.filtered)})
  
  output$FGM2.bp <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal' & player.dataset()[[22]] == 1])
    })
  
  output$FGA2.bp <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal'])
    })
  
  output$EFFICIENCY2.bp <-
    renderText({
      
      round(length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal' & player.dataset()[[22]] == 1]) / length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal']),
            digits = 3)
      
    })
  
  output$FGM3.bp <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal' & player.dataset()[[22]] == 1])
    })
  
  output$FGA3.bp <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal'])
    })
  
  output$EFFICIENCY3.bp <-
    renderText({
      
      round(length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal' & player.dataset()[[22]] == 1]) / length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal']),
            digits = 3)
      
    })
  
  output$EFG.bp <-
    renderText({
      round((sum(player.dataset()[[22]]) + 0.5 * length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal' & player.dataset()[[22]] == 1])) / length(player.dataset()[[22]]),
            digits = 3)
    })
  
  output$PlayerShotchart <- renderPlotly({
    
    player.shotchart <- ggplot(data = player.dataset(),
                               aes(x = LOC_X,
                                   y = LOC_Y)) +
      geom_point(aes(text1 = DATE,
                     text2 = OPP,
                     text3 = ACTION_TYPE,
                     text4 = TIME,
                     customdata = URL,
                     color = COLOR),
                 alpha = 0.7) +
      scale_color_identity() +
      annotate(geom = 'text',
               x = 22, y = c(-1.5, -3),
               label = c('MISS', 'MAKE'),
               color = c('#dc322f', '#2aa198')) +
      # scale_color_manual(values = c('#EF426F', '#00B2A9')) +
      theme_solarized_2() +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.x = element_blank(),
            axis.ticks.y = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.background = element_rect(fill = '#eee8d5'),
            legend.position = 'none'
      )
    
    player.plot <- ggplotly(court.plotter.lines(fg.plot = player.shotchart,
                                                line.color = '#000000',
                                                line.size = 1),
                            height = 1000, width = 1000,
                            tooltip = c('text1', 'text2', 'text3', 'text4')) 
    
    onRender(player.plot, "
     function(el, x) {
     el.on('plotly_click', function(d) {
     var url = d.points[0].customdata;
     //url
     window.open(url);
     });
     }
     ")
    
  })
  
  output$PlayerShotchartBi <- renderPlot({
    validate(
      need(nrow(player.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    
    shotchart.bivariate.plotter(player.dataset())},
    height = 1000, width = 1000, bg='#fdf6e3', execOnResize=F)
  
  
  output$PlayerShotchartTopN <- renderPlot({
    validate(
      need(nrow(player.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    shotchart.topn.plotter(player.dataset(),
                           hexagons = 16,
                           top.n = 25)},
    height = 1000, width = 1000, bg='#fdf6e3', execOnResize=F)
  
  output$PlayerShotchartDens <- renderPlot({
    validate(
      need(nrow(player.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    shotchart.kde.plotter(player.dataset())},
    height = 1000, width = 1000, bg='#fdf6e3', execOnResize=F)
  
  # BY TEAM
  # Update choices in team.bt to include only applicable teams based on season.bt.
  observeEvent(input$season.bt, {
    req(input$season.bt)
    updateSelectInput(session = getDefaultReactiveDomain(), 'team.bt',
                      choices = as.list(sort(unique(data$TEAM_NAME[data$season.type %in% input$season.bt]))))
  })
  
  output$TeamName <-
    renderText({
      
      input$team.bt
      
    })
  
  team.dataset <- reactive({
    
    team.filtered <- data %>%
      
      # Filter by season type,
      filter(season.type %in% input$season.bt,
             
             # player name (what about players with same name?)
             # PLAYER_NAME == input$player.bp,
             TEAM_NAME == input$team.bt,
             
             # date,
             DATE >= input$daterange.bt[1] & DATE <= input$daterange.bt[2],
             
             # home/away,
             if (input$home.away.bt != 'ALL')
             {HOME.AWAY == input$home.away.bt}
             else
             {HOME.AWAY %in% c('HOME', 'AWAY')},
             
             # opponent,
             if (input$opponent.bt != 'ALL')
             {OPP == input$opponent.bt}
             else
             {OPP %in% c(unique(data$OPP))},
             
             # and period.
             if (input$period.bt != 'ALL')
             {PERIOD == input$period.bt}
             else
             {PERIOD %in% c('1', '2', '3', '4', 'OT')})
    
    return(team.filtered)})
  
  output$FGM2.bt <-
    renderText({
      length(team.dataset()[[14]][team.dataset()[[14]] == '2PT Field Goal' & team.dataset()[[22]] == 1])
    })
  
  output$FGA2.bt <-
    renderText({
      length(team.dataset()[[14]][team.dataset()[[14]] == '2PT Field Goal'])
    })
  
  output$EFFICIENCY2.bt <-
    renderText({
      
      round(length(team.dataset()[[14]][team.dataset()[[14]] == '2PT Field Goal' & team.dataset()[[22]] == 1]) / length(team.dataset()[[14]][team.dataset()[[14]] == '2PT Field Goal']),
            digits = 3)
      
    })
  
  output$FGM3.bt <-
    renderText({
      length(team.dataset()[[14]][team.dataset()[[14]] == '3PT Field Goal' & team.dataset()[[22]] == 1])
    })
  
  output$FGA3.bt <-
    renderText({
      length(team.dataset()[[14]][team.dataset()[[14]] == '3PT Field Goal'])
    })
  
  output$EFFICIENCY3.bt <-
    renderText({
      
      round(length(team.dataset()[[14]][team.dataset()[[14]] == '3PT Field Goal' & team.dataset()[[22]] == 1]) / length(team.dataset()[[14]][team.dataset()[[14]] == '3PT Field Goal']),
            digits = 3)
      
    })
  
  output$EFG.bt <-
    renderText({
      round((sum(team.dataset()[[22]]) + 0.5 * length(team.dataset()[[14]][team.dataset()[[14]] == '3PT Field Goal' & team.dataset()[[22]] == 1])) / length(team.dataset()[[22]]),
            digits = 3)
    })
  
  output$TeamShotchart <- renderPlotly({

    team.shotchart <- ggplot(data = team.dataset(),
                               aes(x = LOC_X,
                                   y = LOC_Y)) +
      geom_point(aes(text1 = PLAYER_NAME,
                     text2 = DATE,
                     text3 = OPP,
                     text4 = ACTION_TYPE,
                     text5 = TIME,
                     customdata = URL,
                     color = COLOR),
                 alpha = 0.7) +
      scale_color_identity() +
      annotate(geom = 'text',
               x = 22, y = c(-1.5, -3),
               label = c('MISS', 'MAKE'),
               color = c('#dc322f', '#2aa198')) +
      # scale_color_manual(values = c('#EF426F', '#00B2A9')) +
      theme_solarized_2() +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.x = element_blank(),
            axis.ticks.y = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.background = element_rect(fill = '#eee8d5'),
            legend.position = 'none'
      )

    team.plot <- ggplotly(court.plotter.lines(fg.plot = team.shotchart,
                                                line.color = '#000000',
                                                line.size = 1),
                            height = 1000, width = 1000,
                            tooltip = c('text1', 'text2', 'text3', 'text4', 'text5'))

    onRender(team.plot, "
     function(el, x) {
     el.on('plotly_click', function(d) {
     var url = d.points[0].customdata;
     //url
     window.open(url);
     });
     }
     ")

  })
  
  output$TeamShotchartBi <- renderPlot({
    validate(
      need(nrow(team.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    
    shotchart.bivariate.team.plotter(team.dataset())},
    height = 1000, width = 1000, bg='#fdf6e3', execOnResize=F)
  
  
  output$TeamShotchartTopN <- renderPlot({
    validate(
      need(nrow(team.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    shotchart.topn.team.plotter(team.dataset(),
                           hexagons = 30,
                           top.n = 50)},
    height = 1000, width = 1000, bg='#fdf6e3', execOnResize=F)
  
  output$TeamShotchartDens <- renderPlot({
    validate(
      need(nrow(team.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    shotchart.kde.team.plotter(team.dataset())},
    height = 1000, width = 1000, bg='#fdf6e3', execOnResize=F)
  

  
  
  
  
}

shinyApp(ui = ui, server = server)
