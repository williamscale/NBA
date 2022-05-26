import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
from nba_api.stats.endpoints import leaguegamelog
import time
import os
import sys

# file_dir = os.path.dirname(os.path.abspath(__file__))
# sys.path.append(os.path.join(file_dir, '..', 'Misc'))

import list_func

def create_gamelogCum_df(year, column_cum, plot_flag = 1, savefig_flag = 0):

	log_raw = leaguegamelog.LeagueGameLog(
		player_or_team_abbreviation = 'T',
		season = year,
		sorter = 'DATE',
		)

	time.sleep(0.5)
	content = json.loads(log_raw.get_json())
	results = content['resultSets'][0]
	headers = results['headers']
	rows = results['rowSet']

	log = pd.DataFrame(rows)
	log.columns = headers

	log['WIN'] = (log['WL'] == 'W') * 1
	log['LOSS'] = (log['WL'] == 'L') * 1

	log['Cumulative Wins'] = log.groupby('TEAM_ABBREVIATION').WIN.cumsum()
	log['Cumulative Losses'] = log.groupby('TEAM_ABBREVIATION').LOSS.cumsum()
	log['Record'] = log['Cumulative Wins'].astype(str) + '-' + log['Cumulative Losses'].astype(str)

	log['Cumulative Point Differential'] = log.groupby('TEAM_ABBREVIATION').PLUS_MINUS.cumsum()

	gamelog_cum_team = log[[
	'SEASON_ID',
	'TEAM_ID',
	'TEAM_ABBREVIATION',
	'TEAM_NAME',
	'GAME_ID',
	'GAME_DATE',
	'WL',
	'Cumulative Wins',
	'Record',
	'Cumulative Point Differential']].copy()

	teams = gamelog_cum_team['TEAM_ABBREVIATION'].unique().tolist()
	dates = gamelog_cum_team['GAME_DATE'].unique()

	teams_date = [team + ' DATE' for team in teams] 
	teams_gamelog_cum = [team for team in teams]

	column_names = list_func.alternateList(teams_date, teams_gamelog_cum)

	gamelog_cum_date = pd.DataFrame(columns = teams_gamelog_cum)

	if column_cum == 'Wins':

		for team in teams:

			gamelog_cum_list = gamelog_cum_team.loc[gamelog_cum_team['TEAM_ABBREVIATION'] == team]['Cumulative Wins'].tolist()
			
			gamelog_cum_date[team] = gamelog_cum_list

	elif column_cum == 'Record':

		for team in teams:

			gamelog_cum_list = gamelog_cum_team.loc[gamelog_cum_team['TEAM_ABBREVIATION'] == team]['Record'].tolist()
			
			gamelog_cum_date[team] = gamelog_cum_list

	elif column_cum == 'Points Differential':

		for team in teams:

			gamelog_cum_list = gamelog_cum_team.loc[gamelog_cum_team['TEAM_ABBREVIATION'] == team]['Cumulative Point Differential'].tolist()
			
			gamelog_cum_date[team] = gamelog_cum_list

	else: 

		print('Improper column input. Input either "Wins", "Record", or "Points Differential" (case-sensitive).')

	game_idx = pd.Series(range(1, len(gamelog_cum_date) + 1))
	gamelog_cum_date.set_index(game_idx, drop = True, inplace = True)

	if plot_flag == 1:

		fig_cumstat, ax_cumstat = plt.subplots()

		ax_cumstat.plot(gamelog_cum_date, color = 'grey')
		ax_cumstat.plot(gamelog_cum_date['SAS'], color = '#EF426F', linewidth = 5)
		ax_cumstat.plot(gamelog_cum_date['UTA'], color = '#002B5C')
		ax_cumstat.plot(gamelog_cum_date['HOU'], color = '#CE1141')

		ax_cumstat.set_facecolor('black')
		ax_cumstat.set_xlabel('Game')
		ax_cumstat.set_ylabel('Wins')

		plt.xlim([1, 79])
		plt.ylim([0, 53])

		ax_cumstat.text(x = 72.5,
			y = gamelog_cum_date['SAS'][72],
			s = 'Spurs',
			fontsize = 12,
			c = '#EF426F',
			ha = 'left',
			va = 'center')

		ax_cumstat.text(x = 72.5,
			y = gamelog_cum_date['UTA'][72],
			s = 'Jazz',
			fontsize = 12,
			c = '#002B5C',
			ha = 'left',
			va = 'center')

		ax_cumstat.text(x = 72.5,
			y = gamelog_cum_date['HOU'][72],
			s = 'Rockets',
			fontsize = 12,
			c = '#CE1141',
			ha = 'left',
			va = 'center')

	else: 

		pass

	if savefig_flag == 1:

		# specify file type
		image_type = '.jpeg'

		# specify file name
		fig1_name = 'spurs_' + year + '_' + column_cum + image_type
		fig_cumstat.set_size_inches(10, 8)

		# save file
		fig_cumstat.savefig(fname = fig1_name, dpi = 1000, bbox_inches = 'tight')

	else:

		pass

	plt.show()

	return gamelog_cum_date 

if __name__ == '__main__':
	year = '2018-19'
	column_cum = 'Points Differential'
	plot_flag = 0
	savefig_flag = 0
	# x = create_gamelogCum_df(year, column_cum, plot_flag, savefig_flag)
	# print(x)