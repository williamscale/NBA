import pandas as pd
import json
from nba_api.stats.endpoints import leaguegamelog
import time
import numpy as np

season = '2020-21'

response = leaguegamelog.LeagueGameLog(
			season = season,
			player_or_team_abbreviation = 'T')

time.sleep(0.1)

content = json.loads(response.get_json())

# transform contents into dataframe
teamgamelog_raw = content['resultSets'][0]

headers = teamgamelog_raw['headers']

rows = teamgamelog_raw['rowSet']

teamgamelog_df = pd.DataFrame(rows)

teamgamelog_df.columns = headers

# teamgamelog_ft = teamgamelog_df.drop(teamgamelog_df.columns.difference(['SEASON_ID']), 1)
# each game is two rows
game_rows = 2

# sum each stat for each game
# some stats are meaningless summed
summed_df = teamgamelog_df.groupby(['GAME_ID']).sum()

summed_df['Total FT_PCT'] = summed_df['FTM'] / summed_df['FTA']

# set FTA and FT% filters
fta_filter = 51
ft_pct_filter = 0.92

# convert float to numpy float64
ft_pct_filter_np = np.float64(ft_pct_filter)

ft_filtered = summed_df.loc[(summed_df['FTA'] >= fta_filter) & (summed_df['Total FT_PCT'] >= ft_pct_filter_np)]
games_filtered_list = ft_filtered.index.tolist()

games_filtered = teamgamelog_df[teamgamelog_df['GAME_ID'].isin(games_filtered_list)]
print(ft_filtered)