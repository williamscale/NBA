import requests
import pandas as pd
from nba_api.stats.endpoints import commonplayerinfo as cpi 
import json
import CommonAllPlayers_func
from nba_api.stats.endpoints import shotchartdetail
import time

def fg_dist(player_or_teams):
	
	current_players_id_list, current_players_list = CommonAllPlayers_func.create_currentplayers_lists(teams = player_or_teams)

	if current_players_list == []: 

		current_players_list = [player_or_teams]

	players_filtered_list = []
	furthest_makes_list = []
	avg_makes_list = []

	for name in current_players_list:

		playerid = CommonAllPlayers_func.get_playerid(name)

		response = shotchartdetail.ShotChartDetail(
		team_id = 0, 
		player_id = playerid,
		context_measure_simple = 'FGA', # FGA/FG3A are made & missed
		#season_type_all_star = 'Regular Season',
		season_nullable = '2020-21'
		#period = '4',
		)

		time.sleep(0.1)

		content = json.loads(response.get_json())

		# transform contents into dataframe
		results = content['resultSets'][0]
		headers = results['headers']
		rows = results['rowSet']
		fg_attempt = pd.DataFrame(rows)

		if fg_attempt.empty == False and fg_attempt.shape[0] >= 100:

			fg_attempt.columns = headers

			# all field goal attempts
			fg_attempt['LOC_X'] = -1 * fg_attempt['LOC_X']
			fg_attempt['shot_dist'] = (fg_attempt['LOC_X'] ** 2 + fg_attempt['LOC_Y'] ** 2) ** 0.5

			# all successful field goals
			fg_make = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 1]

			# all unsuccessful field goals
			fg_miss = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 0]

			furthest_make_ft = fg_make['shot_dist'].max() / (5 / 6 * 12)
			avg_make_ft = fg_make['shot_dist'].mean() / (5 / 6 * 12)

			players_filtered_list.append(name)
			furthest_makes_list.append(furthest_make_ft)
			avg_makes_list.append(avg_make_ft)

		else:

			continue

	shot_range_df = pd.DataFrame(list(zip(players_filtered_list, furthest_makes_list, avg_makes_list)), 
	               columns =['Player', 'Furthest FG', 'Average Distance FG']) 

	shot_range_df.sort_values(by=['Average Distance FG'], inplace = True)

	return shot_range_df

if __name__ == '__main__':

	player_or_teams = 'Keldon Johnson'
	fg_dist_df = fg_dist(player_or_teams)
	print(fg_dist_df)

