import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
from nba_api.stats.endpoints import leaguegamelog
import time

def create_playergamelog_cum_df(player, stat, year = '2020-21'):

	log_raw = leaguegamelog.LeagueGameLog(
		player_or_team_abbreviation = 'P',
		season = year,
		sorter = 'DATE')

	time.sleep(0.5)

	content = json.loads(log_raw.get_json())
	results = content['resultSets'][0]
	headers = results['headers']
	rows = results['rowSet']

	log = pd.DataFrame(rows)
	log.columns = headers

	log_player = log[log['PLAYER_NAME'] == player].copy()

	log_player.reset_index(inplace = True, drop = True)

	sma_list = [[]] * len(stat)
	cma_list = [[]] * len(stat)

	for i in range(0, len(stat)):

		sma_list[i].append(log_player[stat[i]].rolling(10, min_periods = 1).mean())
		cma_list[i].append(log_player[stat[i]].expanding(min_periods = 1).mean())

	fig_1, ax_1 = plt.subplots()

	ax_1.plot(log_player[stat[0]], '.', label = stat[0])
	ax_1.plot(log_player[stat[1]], '.', label = stat[1])

	ax_1.plot(sma_list[0][0], label = stat[0])
	ax_1.plot(sma_list[0][1], label = stat[1])


	# ax_1.plot(log_player[stat], '.', label = 'REB')
	# ax_1.plot(log_player['SMA'], label = '10 GAME ROLLING AVERAGE')
	# ax_1.plot(log_player['CMA'], label = 'CUMULATIVE AVERAGE')
	# # ax_1.plot(log_player['EWM'], label = 'EXPONENTIAL WEIGHTED AVERAGE')

	ax_1.set_facecolor('black')
	ax_1.set_title(player + ', ' + year)
	# ax_1.set_xlabel('Game')
	# ax_1.set_ylabel(stat + '/G')
	ax_1.legend()

	# # specify file type
	# image_type = '.jpeg'

	# # specify file name
	# fig_name = player + '_' + year + image_type

	# # save file
	# fig_1.savefig(fig_name, dpi = 1000, bbox_inches = 'tight')

	plt.show()


	# log = log.sort_values(by = ['PLAYER_NAME', 'GAME_DATE'],
	# 	ascending = [True, True])

	# log[cum_title] = log.groupby('PLAYER_NAME')[stat].cumsum()
	# log['GP'] = log.groupby('PLAYER_NAME').cumcount() + 1
	# log['Running Average'] = log[cum_title] / log['GP']

	# log_spurs.set_index('GP', inplace = True)
	# log_spurs.groupby('PLAYER_NAME')['Running Average'].plot(legend = True)



	return log_player

if __name__ == '__main__':

	player = 'Jakob Poeltl'
	stat = ['REB', 'PTS']

	x = create_playergamelog_cum_df(player, stat)