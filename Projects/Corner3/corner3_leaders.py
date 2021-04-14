import requests
import pandas as pd
from nba_api.stats.endpoints import commonplayerinfo as cpi 
import json
import NBA_court_zones
from nba_api.stats.endpoints import shotchartdetail
import time
from CommonAllPlayers_func import create_players_list

# starts in 1996-97 season, but using only last 20 seasons, starting 2000-01
season_players = ['2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021']
#season_players = ['2021']

FG3A_filter = 100

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

for season in season_players:

	season_shotchart = str((int(season) - 1)) + '-' + season[-2:]

	players_df, players_list, playersid_list = create_players_list(season)

	for i in range(0, len(players_list)):

		print(players_list[i])

		#playerid = get_playerid(player)

		response = shotchartdetail.ShotChartDetail(
			team_id = 0, 
			player_id = playersid_list[i],
			context_measure_simple = 'FG3A', # FGA/FG3A are made & missed
			season_nullable = season_shotchart
		)

		time.sleep(1)

		content = json.loads(response.get_json())

		# transform contents into dataframe
		results = content['resultSets'][0]
		headers = results['headers']
		rows = results['rowSet']

		if not rows:

			continue

		else:

			fg_attempt = pd.DataFrame(rows)
			fg_attempt.columns = headers
			#fg_make = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 1]

			if len(fg_attempt) >= FG3A_filter:

				player_list_filtered.append(players_list[i])

				corner3_right_list.append(len(fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Right Corner 3']))
				corner3_left_list.append(len(fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Left Corner 3']))
				abovebreak3_list.append(len(fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Above the Break 3']))
				corner3_right_make_list.append(len(fg_attempt.loc[(fg_attempt['SHOT_ZONE_BASIC'] == 'Right Corner 3') & fg_attempt['SHOT_MADE_FLAG'] == 1]))
				corner3_left_make_list.append(len(fg_attempt.loc[(fg_attempt['SHOT_ZONE_BASIC'] == 'Left Corner 3') & fg_attempt['SHOT_MADE_FLAG'] == 1]))
				abovebreak3_make_list.append(len(fg_attempt.loc[(fg_attempt['SHOT_ZONE_BASIC'] == 'Above the Break 3') & fg_attempt['SHOT_MADE_FLAG'] == 1]))

				FG3A_list.append(len(fg_attempt))

				season_list.append(season_shotchart)

corner3_df = pd.DataFrame(list(zip(player_list_filtered, season_list, corner3_right_list, corner3_right_make_list, corner3_left_list, corner3_left_make_list, abovebreak3_list, abovebreak3_make_list, FG3A_list)),
	columns = ['PLAYER', 'YEAR', 'RIGHT CORNER A', 'RIGHT CORNER M', 'LEFT CORNER A', 'LEFT CORNER M', 'ABOVE BREAK A', 'ABOVE BREAK M', 'FG3A'])

corner3_df['%3PA CORNER'] = (corner3_df['RIGHT CORNER A'] + corner3_df['LEFT CORNER A']) / corner3_df['FG3A']
corner3_df['FG% CORNER'] = (corner3_df['RIGHT CORNER M'] + corner3_df['LEFT CORNER M']) / (corner3_df['RIGHT CORNER A'] + corner3_df['LEFT CORNER A'])
corner3_df['FG% ABOVE BREAK'] = corner3_df['ABOVE BREAK M'] / corner3_df['ABOVE BREAK A']

corner3_df.sort_values(by = ['%3PA CORNER'], inplace = True, ascending = False)

print(corner3_df.head(20), '\n\n', corner3_df.tail(20))

corner3_df.to_pickle('C:/Users/caler/Documents/MyProjects/NBA/Pickles/corner3_leaders_01to21.pkl')

# # all field goal attempts
# fg_attempt['LOC_X'] = -1 * fg_attempt['LOC_X']

# # all successful field goals
# fg_make = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 1]

# total_attempt = len(fg_attempt)

# # all unsuccessful field goals
# #fg_miss = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 0]

# # dataframe for each zone attempted
# abovebreak_3 = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Above the Break 3']
# corner3_right = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Right Corner 3']
# corner3_left = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Left Corner 3']

# corner_attempt = len(corner3_right) + len(corner3_left)

# perc_corner = corner_attempt / total_attempt

# print(total_attempt, corner_attempt, perc_corner)

print('\n--- %s seconds ---\n' % (time.time() - start_time))

