# standard imports
import os
import sys
import requests
import time
import json

# third-party imports
import pandas as pd
import matplotlib.pyplot as plt
from nba_api.stats.endpoints import playbyplay as pbp

# local imports
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', 'GameLogs'))
from gamelog_league import create_cat_list
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', 'PlottingSupport'))
import team_colors

def lastleadchange_create_df(season, cat, pickle_flag = 0, plot_flag = 0, tocsv_flag = 0):

	if pickle_flag == 1:

		league_gamelog, gameid_all_list = create_cat_list(season, cat)

		wl = 'W'
		wl_gamelog = league_gamelog[league_gamelog['WL'] == wl]

		gameid_list = wl_gamelog['GAME_ID'].tolist()
		team_log_list = wl_gamelog['TEAM_NAME'].tolist()
		teamabb_log_list = wl_gamelog['TEAM_ABBREVIATION'].tolist()

		lastleadchange_period_list = []
		lastleadchange_time_list = []

		for game in gameid_list:

			print(game)

			response_pbp = pbp.PlayByPlay(
				game_id = game)

			time.sleep(0.5)

			content_pbp = json.loads(response_pbp.get_json())
			results_pbp = content_pbp['resultSets'][0]
			headers_pbp = results_pbp['headers']
			rows_pbp = results_pbp['rowSet']
			league_pbp = pd.DataFrame(rows_pbp)
			league_pbp.columns = headers_pbp

			league_pbp.loc[league_pbp['SCOREMARGIN'] == 'TIE', 'SCOREMARGIN'] = 0
			# league_pbp.loc[league_pbp['SCOREMARGIN'] != 'TIE', 'Tied?'] = 'False'

			league_pbp = league_pbp[league_pbp['SCOREMARGIN'].notnull()]

			league_pbp['SCOREMARGIN'] = league_pbp['SCOREMARGIN'].astype(int)

			if league_pbp['SCOREMARGIN'].iat[-1] < 0:

				league_pbp.loc[league_pbp['SCOREMARGIN'] > 0, 'Loser Lead or Tie?'] = 'True'
				league_pbp.loc[league_pbp['SCOREMARGIN'] == 0, 'Loser Lead or Tie?'] = 'True'

			else:

				league_pbp.loc[league_pbp['SCOREMARGIN'] < 0, 'Loser Lead or Tie?'] = 'True'
				league_pbp.loc[league_pbp['SCOREMARGIN'] == 0, 'Loser Lead or Tie?'] = 'True'

			league_pbp.reset_index(drop = True, inplace = True)

			lastleadchange_idx = league_pbp[league_pbp['Loser Lead or Tie?'] == 'True'].last_valid_index()

			if lastleadchange_idx is not None and lastleadchange_idx != len(league_pbp):

				lastleadchange_period_list.append(league_pbp['PERIOD'][lastleadchange_idx + 1])
				lastleadchange_time_list.append(league_pbp['PCTIMESTRING'][lastleadchange_idx + 1])

			elif lastleadchange_idx == len(league_pbp):

				lastleadchange_period_list.append(league_pbp['PERIOD'][lastleadchange_idx])
				lastleadchange_time_list.append(league_pbp['PCTIMESTRING'][lastleadchange_idx])

			else:

				lastleadchange_period_list.append(league_pbp['PERIOD'][0])
				lastleadchange_time_list.append(league_pbp['PCTIMESTRING'][0])

		lastleadchange_df = pd.DataFrame(list(zip(gameid_list, team_log_list, teamabb_log_list, lastleadchange_period_list, lastleadchange_time_list)),
		               columns = ['GAME_ID', 'TEAM', 'TEAM_ABB', 'PERIOD', 'TIME'])

		file_name = './lastleadchange_' + season + '.pkl'

		lastleadchange_df.to_pickle(file_name)

	else:

		file_name = './lastleadchange_' + season + '.pkl'
		lastleadchange_df = pd.read_pickle(file_name)

	longest_game = 48 + (lastleadchange_df['PERIOD'].max() - 4) * 5

	period_list = lastleadchange_df['PERIOD'].tolist()

	period_list = [period * 12 if period <= 4 else period * 5 + 48 for period in period_list]

	time_split = lastleadchange_df['TIME'].str.split(':', expand = True)

	lastleadchange_df['MIN'] = time_split[0].astype(int)
	lastleadchange_df['SEC'] = time_split[1].astype(int)
	lastleadchange_df['ELAPSED TIME'] = period_list - lastleadchange_df['MIN'] - lastleadchange_df['SEC'] / 60

	team_gb_mean = lastleadchange_df.groupby(['TEAM_ABB']).mean()
	team_gb_mean.sort_values(by = 'ELAPSED TIME', inplace = True, ascending = False)

	if plot_flag == 1:

		plt.style.use('Solarize_Light2')
		name_list, abb_list, primary1_list = team_colors.return_teamcolors_lists()
		colors_df = pd.DataFrame(list(zip(abb_list, primary1_list)), columns = ['TEAM_ABB', 'COLOR_1'])

		team_gb_mean = pd.merge(team_gb_mean, colors_df, on = ['TEAM_ABB'], how = 'left').set_index('TEAM_ABB')
		fig_box, ax_box = plt.subplots()
		box_team = lastleadchange_df.boxplot(column = 'ELAPSED TIME', by = 'TEAM_ABB', ax = ax_box, vert = False)

		fig_bar, ax_bar = plt.subplots()

		q_labels = ['Q1', 'Q2', 'Q3', 'Q4']
		qtime_labels = [0, 12, 24, 36]
		plt.xticks(ticks = qtime_labels, labels = q_labels)
		plt.yticks(fontsize = 6)

		plt.barh(y = team_gb_mean.index, width = team_gb_mean['ELAPSED TIME'], color = team_gb_mean['COLOR_1'])
		LCfont = {'fontname':'Lucida Console'}

		plt.suptitle('if the Jazz are ahead at halftime, maybe give up', **LCfont, fontsize = 16)
		plt.title('AVERAGE TIME IN WHICH TEAM TAKES & KEEPS LEAD | 2020-21, through May 10 | @cale_williams', **LCfont, fontsize = 6, loc = 'left')
		plt.axvline(x = qtime_labels[1], ls = ':', lw = 1.5, color = 'black')
		plt.axvline(x = qtime_labels[2], ls = ':', lw = 1.5, color = 'black')
		plt.axvline(x = qtime_labels[3], ls = ':', lw = 1.5, color = 'black')

		plt.savefig('lastleadchange_2020-21.jpeg', dpi = 500, bbox_inches = 'tight')

		plt.show()


	# print(lastleadchange_df)

	if tocsv_flag == 1:

		lastleadchange_df.to_csv('./lastleadchange_2020-21.csv')
		team_gb_mean.to_csv('./team_gb_med_2020-21.csv')

	return lastleadchange_df

if __name__ == '__main__':

	season = '2020-21'
	cat = 'GAME_ID'
	pickle_flag = 0
	plot_flag = 1
	tocsv_flag = 0

	lastleadchange_df = lastleadchange_create_df(season, cat, pickle_flag, plot_flag, tocsv_flag)