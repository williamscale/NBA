# Scrape corner 3 data.
# Author: Cale Williams
# Last Updated: 05/25/2022

# Import packages.
import requests
import pandas as pd
import json
import time
import os
import sys
from nba_api.stats.endpoints import commonplayerinfo as cpi 
from nba_api.stats.endpoints import shotchartdetail

# Import local packages.
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', '..', 'Functions'))
import NBA_court_zones

file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', '..', 'Scrapers'))
from CommonAllPlayers_Func import create_players_list

# data starts in 1996-97 season, but using only last 20 seasons, starting 2000-01
# Got too slow with multiple seasons so input one season at a time.
# season_players = ['2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021']
# Select season to scrape.
season_players = ['2015']

# Choose FGA3 minimum.
FG3A_filter = 100

# Initialize lists.
player_list_filtered = []
corner3_right_list = []
corner3_left_list = []
abovebreak3_list = []
corner3_right_make_list = []
corner3_left_make_list = []
abovebreak3_make_list = []
FG3A_list = []
season_list = []

start_time = time.time()

# For each season...
for season in season_players:

	season_shotchart = str((int(season) - 1)) + '-' + season[-2:]

	# Create list of players.
	players_df, players_list, playersid_list = create_players_list(season)

	# For each player index...
	for i in range(0, len(players_list)):

		# Print player name.
		print(players_list[i])

		# Scrape FG3A data.
		response = shotchartdetail.ShotChartDetail(
			team_id = 0, 
			player_id = playersid_list[i],
			context_measure_simple = 'FG3A', # FGA/FG3A are made & missed
			season_nullable = season_shotchart
		)

		time.sleep(0.5)

		content = json.loads(response.get_json())

		# Transform contents into dataframe.
		results = content['resultSets'][0]
		headers = results['headers']
		rows = results['rowSet']

		# If dataframe is not empty...
		if not rows:

			continue

		else:

			# Create dataframe.
			fg_attempt = pd.DataFrame(rows)
			fg_attempt.columns = headers

			# If minimum FG3A is satisfied...
			if len(fg_attempt) >= FG3A_filter:

				# Append data to lists.
				player_list_filtered.append(players_list[i])
				corner3_right_list.append(len(fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Right Corner 3']))
				corner3_left_list.append(len(fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Left Corner 3']))
				abovebreak3_list.append(len(fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Above the Break 3']))
				corner3_right_make_list.append(len(fg_attempt.loc[(fg_attempt['SHOT_ZONE_BASIC'] == 'Right Corner 3') & fg_attempt['SHOT_MADE_FLAG'] == 1]))
				corner3_left_make_list.append(len(fg_attempt.loc[(fg_attempt['SHOT_ZONE_BASIC'] == 'Left Corner 3') & fg_attempt['SHOT_MADE_FLAG'] == 1]))
				abovebreak3_make_list.append(len(fg_attempt.loc[(fg_attempt['SHOT_ZONE_BASIC'] == 'Above the Break 3') & fg_attempt['SHOT_MADE_FLAG'] == 1]))
				FG3A_list.append(len(fg_attempt))
				season_list.append(season_shotchart)

# Create dataframe from lists.
corner3_df = pd.DataFrame(list(zip(player_list_filtered, season_list, corner3_right_list, corner3_right_make_list, corner3_left_list, corner3_left_make_list, abovebreak3_list, abovebreak3_make_list, FG3A_list)),
	columns = ['PLAYER', 'YEAR', 'RIGHT CORNER A', 'RIGHT CORNER M', 'LEFT CORNER A', 'LEFT CORNER M', 'ABOVE BREAK A', 'ABOVE BREAK M', 'FG3A'])

# Calculate efficiencies and rates.
corner3_df['%3PA CORNER'] = (corner3_df['RIGHT CORNER A'] + corner3_df['LEFT CORNER A']) / corner3_df['FG3A']
corner3_df['FG% CORNER'] = (corner3_df['RIGHT CORNER M'] + corner3_df['LEFT CORNER M']) / (corner3_df['RIGHT CORNER A'] + corner3_df['LEFT CORNER A'])
corner3_df['FG% ABOVE BREAK'] = corner3_df['ABOVE BREAK M'] / corner3_df['ABOVE BREAK A']

# Sort.
corner3_df.sort_values(by = ['%3PA CORNER'],
	inplace = True,
	ascending = False)

# Print summary dataframe.
print(corner3_df.head(20), '\n\n', corner3_df.tail(20))

# Pickle dataframe.
corner3_df.to_pickle('C:/Users/caler/Documents/MyProjects/NBA/R/Projects/Corner3/corner3_leaders_x.pkl')

print('\n--- %s seconds ---\n' % (time.time() - start_time))