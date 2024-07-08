library(tidyverse)
library(readxl)

data <- readRDS(
  './MyProjects/NBA/R/Projects/FTA_Prediction/Data/shootingfouls_2023.RDS'
  )

team.ft.rate <- read_xlsx(
  path = './MyProjects/NBA/R/Projects/FTA_Prediction/Data/ft_2023.xlsx',
  sheet = 'Team') %>%
  select(Team, G, MP, FGA, FTA) %>%
  mutate(Team = recode(Team,
                       'Indiana Pacers' = 'IND',
                       'Milwaukee Bucks' = 'MIL',
                       'Boston Celtics' = 'BOS',
                       'Oklahoma City Thunder' = 'OKC',
                       'Atlanta Hawks' = 'ATL',
                       'Dallas Mavericks' = 'DAL',
                       'Golden State Warriors' = 'GSW',
                       'Sacramento Kings' = 'SAC',
                       'Utah Jazz' = 'UTA',
                       'Los Angeles Clippers' = 'LAC',
                       'Phoenix Suns' = 'PHX',
                       'Philadelphia 76ers' = 'PHI',
                       'Los Angeles Lakers' = 'LAL',
                       'New Orleans Pelicans' = 'NOP',
                       'Washington Wizards' = 'WAS',
                       'Denver Nuggets' = 'DEN',
                       'Cleveland Cavaliers' = 'CLE',
                       'Toronto Raptors' = 'TOR',
                       'New York Knicks' = 'NYK',
                       'Minnesota Timberwolves' = 'MIN',
                       'Houston Rockets' = 'HOU',
                       'San Antonio Spurs' = 'SAS',
                       'Detroit Pistons' = 'DET',
                       'Brooklyn Nets' = 'BKN',
                       'Chicago Bulls' = 'CHI',
                       'Orlando Magic' = 'ORL',
                       'Miami Heat' = 'MIA',
                       'Portland Trail Blazers' = 'POR',
                       'Charlotte Hornets' = 'CHA',
                       'Memphis Grizzlies' = 'MEM'))


opp.ft.rate <- read_xlsx(
  path = './MyProjects/NBA/R/Projects/FTA_Prediction/Data/ft_2023.xlsx',
  sheet = 'Opponent') %>%
  select(Team, G, MP, FGA, FTA) %>%
  mutate(Team = recode(Team,
                       'Indiana Pacers' = 'IND',
                       'Milwaukee Bucks' = 'MIL',
                       'Boston Celtics' = 'BOS',
                       'Oklahoma City Thunder' = 'OKC',
                       'Atlanta Hawks' = 'ATL',
                       'Dallas Mavericks' = 'DAL',
                       'Golden State Warriors' = 'GSW',
                       'Sacramento Kings' = 'SAC',
                       'Utah Jazz' = 'UTA',
                       'Los Angeles Clippers' = 'LAC',
                       'Phoenix Suns' = 'PHX',
                       'Philadelphia 76ers' = 'PHI',
                       'Los Angeles Lakers' = 'LAL',
                       'New Orleans Pelicans' = 'NOP',
                       'Washington Wizards' = 'WAS',
                       'Denver Nuggets' = 'DEN',
                       'Cleveland Cavaliers' = 'CLE',
                       'Toronto Raptors' = 'TOR',
                       'New York Knicks' = 'NYK',
                       'Minnesota Timberwolves' = 'MIN',
                       'Houston Rockets' = 'HOU',
                       'San Antonio Spurs' = 'SAS',
                       'Detroit Pistons' = 'DET',
                       'Brooklyn Nets' = 'BKN',
                       'Chicago Bulls' = 'CHI',
                       'Orlando Magic' = 'ORL',
                       'Miami Heat' = 'MIA',
                       'Portland Trail Blazers' = 'POR',
                       'Charlotte Hornets' = 'CHA',
                       'Memphis Grizzlies' = 'MEM'))

ft.rate <- left_join(x = team.ft.rate,
                     y = opp.ft.rate,
                     by = 'Team',
                     suffix = c('.team', '.opp'))

data <- data %>%
  left_join(ft.rate, by = c('home_team_tricode' = 'Team'))
slr