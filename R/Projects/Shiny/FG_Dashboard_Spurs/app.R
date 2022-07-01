# San Antonio Spurs FG Dashboard 2021-22
# Author: Cale Williams
# Last Updated: 06/23/2022

# To Do:
# KDE

# Import libraries.
library(shiny)
library(bslib)
library(gpx)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(sf)
library(geosphere)
library(shinythemes)
library(lubridate)
library(leaflet)
library(purrr)
library(slickR)
library(plotly)
library(htmlwidgets)
library(lubridate)
# library(cowplot)
# library(tidyr)

source('./drawNBAcourt.R')
source('./shotchart_bivariate.R')
source('./shotchart_topn_hex.R')
source('./shotchart_kde.R')

# DATA PREPARATION --------------------------------------------------------

# files.path <- 'C:/Users/caler/Documents/MyProjects/NBA/R/Shotcharts/2021-22/'
# files <- list.files(path = files.path)
# files <- files[! files %in%  c('Anthony-Lamb.2021-22.csv', 'Jaylen-Morris.2021-22.csv',
#                   'Juancho-Hernangomez.2021-22.csv', 'Romeo-Langford.2021-22.csv',
#                   'Tomas-Satoransky.2021-22.csv')]
# data.raw <- data.frame()
# 
# for (i in 1:length(files)) {
#   
#   data.raw.i <- read.csv(paste(files.path, files[i], sep = ''))
#   data.raw <- rbind(data.raw, data.raw.i)
#   
# }
# 
# data <- data.raw[data.raw$TEAM_NAME == 'San Antonio Spurs', ]
# rownames(data) <- 1:nrow(data)
# 
# data <- shotchart.transformer(data = data,
#                               col.x = 'LOC_X',
#                               col.y = 'LOC_Y')
# data <- data[data$LOC_Y <= 0, ]
# 
# data$PERIOD[data$PERIOD > 4] <- 'OT'
# data$HOME.AWAY <- ifelse(data$HTM == 'SAS', 'HOME', 'AWAY')
# data$DATE <- mdy(paste(substr(data$GAME_DATE, 5, 6),
#                          substr(data$GAME_DATE, 7, 8),
#                          substr(data$GAME_DATE, 1, 4),
#                          sep = '/'))
# 
# data$OPP <- ifelse(data$HTM == 'SAS', data$VTM, data$HTM)
# 
# data$TIME <- paste('Q', data$PERIOD, ' ',
#                    sprintf('%02d', data$MINUTES_REMAINING),
#                    ':', sprintf('%02d', data$SECONDS_REMAINING), sep = '')
# 
# data$URL <- paste('https://www.nba.com/stats/events/?CFID=&CFPARAMS=&ContextMeasure=FGA&EndPeriod=0&EndRange=28800&GameID=00',
#                   data$GAME_ID, '&PlayerID=', data$PLAYER_ID,
#                   '&RangeType=0&Season=2021-22&SeasonType=Regular%20Season&StartPeriod=0&StartRange=0&TeamID=',
#                   data$TEAM_ID, '&flag=3&sct=plot&section=game', sep = '')
# 
# # maybe shot distance will help dial in link
# # data$URL.QTR <- paste(data$URL, '&CF=p*E*', data$PERIOD, sep = '')
# data$URL.QTR <- paste(data$URL, '&CF=SHOT_DISTANCE*E*',
#                       data$SHOT_DISTANCE,
#                       ':p*E*', data$PERIOD, sep = '')
# 
# data$COLOR <- ifelse(data$SHOT_MADE_FLAG == 1, '#00B2A9', '#EF426F')
# 
# rm(list = c('data.raw', 'data.raw.i', 'files', 'files.path', 'i'))

load('./Data/spurs_2022_data.RData')

# User Interface ----------------------------------------------------------

ui <- navbarPage(

  title = '2021-22 San Antonio Spurs Shot Dashboard',
  theme = bs_theme(version = 4,
                   bootswatch = 'slate'),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = 'player',
                  label = 'Player',
                  choices = as.list(unique(data$PLAYER_NAME))),
      dateInput(inputId = 'date.start',
                label = 'Date Start',
                value = '10/20/21',
                format = 'mm/dd/yy'),
      dateInput(inputId = 'date.end',
                label = 'Date End',
                value = '04/13/22',
                format = 'mm/dd/yy'),
      selectInput(inputId = 'home.away',
                  label = 'Home/Away',
                  choices = as.list(c('ALL', 'HOME', 'AWAY'))),
      selectInput(inputId = 'opponent',
                  label = 'Opponent',
                  choices = c('ALL', sort(unique(data$OPP)))),
      selectInput(inputId = 'period',
                  label = 'Period',
                  choices = as.list(c('ALL', sort(unique(data$PERIOD))))),
      width = 2),
    mainPanel(
      textOutput('PlayerName'),
      br(),
      fluidRow(column(width = 2,
                      p(strong('2P%:'),
                        textOutput('EFFICIENCY2'),
                        '(', textOutput('FGM2'), '/', textOutput('FGA2'), ')',
                        style = 'display: inline; text-align: left; font-size: 20px')),
               column(width = 2,
                      p(strong('3P%:'),
                        textOutput('EFFICIENCY3'),
                        '(', textOutput('FGM3'), '/', textOutput('FGA3'), ')',
                        style = 'display: inline; text-align: left; font-size: 20px')),
               column(width = 2,
                      p(strong('eFG%:'),
                        textOutput('EFG'),
                        style = 'display: inline; text-align: left; font-size: 20px'))),
      fluidRow(column(width = 6,
                      plotlyOutput('PlayerShotchart', height = '800px', width = '800px'))),
      br(),
      fluidRow(column(width = 6,
                      plotOutput('ShotchartBi', height = '800px', width = '800px'))),
      br(),
      fluidRow(column(width = 6,
                      plotOutput('ShotchartTopN', height = '800px', width = '800px'))),
      br(),
      fluidRow(column(width = 6,
                      plotOutput('ShotchartDens', height = '800px', width = '800px'))),
      
      tags$style('#PlayerName{font-size: 40px; font-style: bold}',
                          '#FGM2{display: inline}',
                          '#FGA2{display: inline}',
                          '#FGM3{display: inline}',
                          '#FGA3{display: inline}',
                          '#EFFICIENCY2{display: inline}',
                          '#EFFICIENCY3{display: inline}',
                          '#EFG{display: inline}')
    ))


)

# Server ------------------------------------------------------------------

server <- function(input, output) {
  
  player.dataset <- reactive({
    
    player.filtered <- data %>%
      
      filter(PLAYER_NAME == input$player,
             #   if (input$result == 'MAKE') 
             #     {SHOT_MADE_FLAG == 1} else if
             # (input$result == 'MISS') 
             #       {SHOT_MADE_FLAG == 0} else
             #         {SHOT_MADE_FLAG %in% c(0, 1)} &
             DATE >= input$date.start,
             DATE <= input$date.end,
             if (input$home.away != 'ALL')
               {HOME.AWAY == input$home.away} else
                 {HOME.AWAY %in% c('HOME', 'AWAY')},
             
             if (input$opponent != 'ALL')
               {OPP == input$opponent} else
                 {OPP %in% c(unique(data$OPP))},
             
             if (input$period != 'ALL')
               {PERIOD == input$period} else
                 {PERIOD %in% c('1', '2', '3', '4', 'OT')})
    
    return(player.filtered)
  })
  
  # fg.n <- nrow(player.dataset())
  

  output$PlayerName <-
    renderText({
      
      input$player
      
    })
  
  output$FGM2 <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal' & player.dataset()[[22]] == 1])
    })
  
  output$FGA2 <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal'])
    })
  
  output$EFFICIENCY2 <-
    renderText({
      
      round(length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal' & player.dataset()[[22]] == 1]) / length(player.dataset()[[14]][player.dataset()[[14]] == '2PT Field Goal']),
            digits = 3)
      
    })
  
  output$FGM3 <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal' & player.dataset()[[22]] == 1])
    })
  
  output$FGA3 <-
    renderText({
      length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal'])
    })
  
  output$EFFICIENCY3 <-
    renderText({

      round(length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal' & player.dataset()[[22]] == 1]) / length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal']),
            digits = 3)
      
    })
  
  output$EFG <-
    renderText({
      round((sum(player.dataset()[[22]]) + 0.5 * length(player.dataset()[[14]][player.dataset()[[14]] == '3PT Field Goal' & player.dataset()[[22]] == 1])) / length(player.dataset()[[22]]),
            digits = 3)
    })


  
  output$PlayerShotchart <- renderPlotly({

    player.shotchart <- ggplot(data = player.dataset(),
                               aes(x = LOC_X,
                                   y = LOC_Y
                                   # ,
                                   # color = as.character(SHOT_MADE_FLAG)
                                   )) +
      geom_point(aes(text1 = DATE,
                     text2 = OPP,
                     text3 = ACTION_TYPE,
                     text4 = TIME,
                     customdata = URL.QTR,
                     color = COLOR)) +
      scale_color_identity() +
      annotate(geom = 'text',
               x = 22, y = c(-1.5, -3),
               label = c('MISS', 'MAKE'),
               color = c('#EF426F', '#00B2A9')) +
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
                            height = 800, width = 800,
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
  
  output$ShotchartBi <- renderPlot({
    validate(
      need(nrow(player.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
  
    shotchart.bivariate.plotter(player.dataset())},
      height = 800, width = 800, bg='#fdf6e3', execOnResize=F)

  
  output$ShotchartTopN <- renderPlot({
    validate(
      need(nrow(player.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    shotchart.topn.plotter(player.dataset(),
                           hexagons = 16,
                           top.n = 25)},
    height = 800, width = 800, bg='#fdf6e3', execOnResize=F)
  
  output$ShotchartDens <- renderPlot({
    validate(
      need(nrow(player.dataset()) >= 25, 'Not enough datapoints for relevant plot.'))
    shotchart.kde.plotter(player.dataset())},
    height = 800, width = 800, bg='#fdf6e3', execOnResize=F)
  
}

shinyApp(ui = ui, server = server)
