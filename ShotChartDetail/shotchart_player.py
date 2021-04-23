# standard imports
import os
import sys
import requests
import time
import json
import math

# third-party imports
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Rectangle, Arc
import seaborn as sns
from scipy import stats
from tabulate import tabulate
from nba_api.stats.endpoints import commonplayerinfo as cpi, shotchartdetail

# local imports
import NBA_court_zones
import ShotChartZones_Func
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', 'Players'))
from CommonAllPlayers_Func import get_playerid
sys.path.append(os.path.join(file_dir, '..', 'PlottingSupport'))
import add_twitterhandle as tweet

def player_shotchart(player, season = 0, fg_type = 'FGA', season_type = 'Regular Season', period = 0, plot_flag = 1, twitter_flag = 1, bin_edge_count = 15, plot_fg = 'all', savefig_flag = 0):

	# start timer
	start_time = time.time()

	# print title
	print('--------------------\n', player[0], '\n', season, '\n--------------------', '\n\n', sep = '')

	# get player ID from name input
	playerid = get_playerid(player)

	# retrieve data
	response = shotchartdetail.ShotChartDetail(
		context_measure_simple = 'FGA',
		period = period,
		player_id = playerid,
		season_type_all_star = season_type,
		team_id = 0, 
		season_nullable = season)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	results = content['resultSets'][0]
	headers = results['headers']
	rows = results['rowSet']
	fg_attempt = pd.DataFrame(rows)
	fg_attempt.columns = headers

	# mirror x, NBA's data is reversed
	fg_attempt['LOC_X'] = -1 * fg_attempt['LOC_X']

	# calculate distance of fg
	fg_attempt['shot_dist'] = (fg_attempt['LOC_X'] ** 2 + fg_attempt['LOC_Y'] ** 2) ** 0.5

	# all successful field goals
	fg_make = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 1]

	# all unsuccessful field goals
	fg_miss = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 0]

	# successful field goal statistics
	furthest_ft = round(fg_make['shot_dist'].max() / (5 / 6 * 12), 1)
	avg_ft = round(fg_make['shot_dist'].mean() / (5 / 6 * 12), 1)
	std_ft = round(fg_make['shot_dist'].std() / (5 / 6 * 12), 1)
	var_ft = round(fg_make['shot_dist'].var() / (5 / 6 * 12), 1)

	# create summary table of stats
	stats_headers = [['Furthest', 'Average', 'Standard Deviation', 'Variance'], [furthest_ft, avg_ft, std_ft, var_ft]]
	print('SHOT DISTANCE:\n', tabulate(stats_headers, headers = 'firstrow', tablefmt = 'fancy_grid'), sep = '')

	# categorize field goals by NBA-defined zones
	make_dict, miss_dict = ShotChartZones_Func.create_dict_shotzones_df(fg_make, fg_miss)

	print('\n\n', 'MADE FIELD GOALS:\n', fg_make)

	# create plots
	if plot_flag == 1:

		# create figures with shot charts
		fig_court1, ax_court1 = plt.subplots()

		ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
			color = 'white',
			lw = 2,
			zones_flag = 0)

		if twitter_flag == 1:

			tweet.add_twitterhandle(fig_court1)

		fig_court2, ax_court2 = plt.subplots()
		
		ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
			color = 'white',
			lw = 2,
			zones_flag = 0)

		if twitter_flag == 1:

			tweet.add_twitterhandle(fig_court2)

		# create dataframes of makes, misses, and all
		fg_make_loc = fg_make[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)
		fg_miss_loc = fg_miss[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)
		fg_attempt_loc = fg_attempt[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)

		# bin succcessful field goals by location
		court_bin_make, xedges_make, yedges_make, binnumber_make = stats.binned_statistic_2d(
			x = fg_make_loc['LOC_X'],
			y = fg_make_loc['LOC_Y'],
			values = None,
			statistic = 'count',
			bins = bin_edge_count,
			range = ((x_min, x_max), (y_min, y_max))
			)

		# bin all field goals by location
		court_bin_attempt, xedges_attempt, yedges_attempt, binnumber_attempt = stats.binned_statistic_2d(
			x = fg_attempt_loc['LOC_X'],
			y = fg_attempt_loc['LOC_Y'],
			values = None,
			statistic = 'count',
			bins = bin_edge_count,
			range = ((x_min, x_max), (y_min, y_max))
			)

		# count of all field goals in each bin
		fg_eff = court_bin_attempt

		# loop through bins
		for bin_i in range(0, bin_edge_count):

			# loop through bins
			for bin_j in range(0, bin_edge_count):
				
				# divide successful field goal count by attempted field goal count for each bin
				if court_bin_attempt[bin_i][bin_j] == 0:

					fg_eff[bin_i][bin_j] = 0

				else:

					fg_eff[bin_i][bin_j] = court_bin_make[bin_i][bin_j] / court_bin_attempt[bin_i][bin_j]

		# select color map and quantity of colors
		cmap_discrete = plt.cm.get_cmap('viridis', 10)

		# mesh grid based on bin edges
		xedges, yedges = np.meshgrid(xedges_make, yedges_make)
		plot_eff2 = ax_court2.pcolormesh(xedges, yedges, fg_eff.T, cmap = cmap_discrete)
		cbar2 = plt.colorbar(plot_eff2, ax = ax_court2)

		if plot_fg == 'makes':

			# plot successful field goals
			ax_court1.scatter(fg_make['LOC_X'], fg_make['LOC_Y'], c = 'green', marker = 'o', alpha = 1, s = 10)

		elif plot_fg == 'misses':

			# plot unsuccessful field goals
			ax_court1.scatter(fg_miss['LOC_X'], fg_miss['LOC_Y'], c = 'red', marker = 'x', alpha = 0.8, s = 10)

		else:

			# plot all field goals
			ax_court1.scatter(fg_make['LOC_X'], fg_make['LOC_Y'], c = 'green', marker = 'o', alpha = 1, s = 10)
			ax_court1.scatter(fg_miss['LOC_X'], fg_miss['LOC_Y'], c = 'red', marker = 'x', alpha = 0.6, s = 10)

		# set titles
		ax_court1.set(title = player[0] + ', ' + season)
		ax_court2.set(title = player[0] + ', FG%, ' + season)

		# set background colors
		ax_court1.set_facecolor('black')
		ax_court2.set_facecolor('black')

		# remove axes ticks
		ax_court1.set_xticks([])
		ax_court1.set_yticks([])
		ax_court2.set_xticks([])
		ax_court2.set_yticks([])

		if savefig_flag == 1:

			# specify file type
			image_type = '.jpeg'

			# specify file name
			fig1_name = player[0] + '_' + season + '_shotchart' + image_type
			fig2_name = player[0] + '_' + season + '_shotchartEff' + image_type

			# save file
			fig_court1.savefig(fig1_name, dpi = 1000, bbox_inches = 'tight')
			fig_court2.savefig(fig2_name, dpi = 1000, bbox_inches = 'tight')

		print('\n--- %s seconds ---\n' % (time.time() - start_time))

		plt.show()

	return fg_make

if __name__ == '__main__':

	player = ['Lonnie Walker IV']
	season = '2020-21'
	fg_type = 'FGA'
	season_type = 'Regular Season'
	period = 0
	plot_flag = 1
	twitter_flag = 1
	bin_edge_count = 10
	plot_fg = 'all'
	savefig_flag = 1

	fg_make = player_shotchart(player, season, fg_type, season_type, period, plot_flag, twitter_flag, bin_edge_count, plot_fg, savefig_flag)