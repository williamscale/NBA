import requests
import matplotlib.pyplot as plt
import pandas as pd
from nba_api.stats.endpoints import commonplayerinfo as cpi 
import json
import CommonAllPlayers_func
from nba_api.stats.endpoints import shotchartdetail
import time

def fg_dist(player_or_teams, plot_flag = 0, fg_attempt_filter = 100):
	
	current_players_id_list, current_players_list = CommonAllPlayers_func.create_currentplayers_lists(teams = player_or_teams)

	if current_players_list == []: 

		current_players_list = [player_or_teams]

	players_filtered_list = []
	furthest_makes_list = []
	avg_makes_list = []
	fg_make_shotdist_list = []

	# fig_box, ax_box = plt.subplots()

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

		if fg_attempt.empty == False and fg_attempt.shape[0] >= fg_attempt_filter:

			fg_attempt.columns = headers

			# all field goal attempts
			fg_attempt['LOC_X'] = -1 * fg_attempt['LOC_X']
			fg_attempt['shot_dist'] = ((fg_attempt['LOC_X'] ** 2 + fg_attempt['LOC_Y'] ** 2) ** 0.5) / (5 / 6 * 12)

			# all successful field goals
			fg_make = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 1]
			fg_make_shotdist_list.append(fg_make['shot_dist'].tolist())

			# all unsuccessful field goals
			fg_miss = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 0]

			furthest_make_ft = fg_make['shot_dist'].max() #/ (5 / 6 * 12)
			avg_make_ft = fg_make['shot_dist'].mean() #/ (5 / 6 * 12)

			players_filtered_list.append(name)
			furthest_makes_list.append(furthest_make_ft)
			avg_makes_list.append(avg_make_ft)

			# if plot_flag == 1:

			# 	plt.boxplot(fg_make['shot_dist'])
			# 	plt.pause(0.05)

		else:

			continue

	if plot_flag == 1:

		fig_box, ax_box = plt.subplots()

		plt.boxplot(x = fg_make_shotdist_list, whis = (0, 100))

		corner3_dist = 22
		arc3_dist = 23.75
		#plt.axhline(corner3_dist)
		plt.axhline(arc3_dist)

		ax_box.set_xticklabels(players_filtered_list)
		plt.xticks(rotation = 20)
		plt.title('FG Distance [ft], ' + player_or_teams)

		#ax_box.legend('Arc 3 Point Line')

		plt.show()

	shot_range_df = pd.DataFrame(list(zip(players_filtered_list, furthest_makes_list, avg_makes_list)), 
	               columns = ['Player', 'Furthest FG', 'Average Distance FG']) 

	shot_range_df.sort_values(by = ['Average Distance FG'], inplace = True)

	# if plot_flag == 1:

	# 	fig_bar, ax_bar = plt.subplots()

	# 	#plt.bar(shot_range_df['Player'], shot_range_df['Average Distance FG'])
	# 	plt.boxplot(shot_range_df['Average Distance FG'])

	# 	plt.show()

	return shot_range_df

if __name__ == '__main__':

	player_or_teams = []
	plot_flag = 0
	fg_attempt_filter = 150
	fg_dist_df = fg_dist(player_or_teams, plot_flag, fg_attempt_filter)
	print(fg_dist_df.head(15), '\n\n', fg_dist_df.tail(15))