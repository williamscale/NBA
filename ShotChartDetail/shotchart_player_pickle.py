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
from matplotlib.patches import Circle, Rectangle, Arc, RegularPolygon
import seaborn as sns
from scipy import stats
from tabulate import tabulate
from nba_api.stats.endpoints import commonplayerinfo as cpi, shotchartdetail
import pickle

# local imports
import NBA_court_zones
import ShotChartZones_Func
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', 'Players'))
from CommonAllPlayers_Func import get_playerid
sys.path.append(os.path.join(file_dir, '..', 'PlottingSupport'))
import add_twitterhandle as tweet
import add_hexlegend

def player_shotchart(player, season = 0, fg_type = 'FGA', season_type = 'Regular Season', period = 0, plot_flag = 1, twitter_flag = 1, bin_edge_count = 15, plot_fg = 'all', savefig_flag = 0):

	# start timer
	start_time = time.time()

	# import pickled dictionaries
	league_make_bybin = pickle.load(open('playermake_2003-04.pkl', 'rb'))
	league_attempt_bybin = pickle.load(open('playerattempt_2003-04.pkl', 'rb'))
	
	league_make_sum_bybin = np.zeros([bin_edge_count, bin_edge_count])
	league_attempt_sum_bybin = np.zeros([bin_edge_count, bin_edge_count])

	for key in league_make_bybin:

		league_make_sum_bybin = np.add(league_make_sum_bybin, league_make_bybin[key])
		league_attempt_sum_bybin = np.add(league_attempt_sum_bybin, league_attempt_bybin[key])

	league_avg_eff_bybin = np.divide(league_make_sum_bybin, league_attempt_sum_bybin)

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

	# create identifier for shot zones
	fg_attempt['shot_id'] = fg_attempt['SHOT_ZONE_BASIC'] + fg_attempt['SHOT_ZONE_AREA'] + fg_attempt['SHOT_ZONE_RANGE']

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

	# shotid_make_gb = fg_attempt.groupby(['shot_id'])['SHOT_MADE_FLAG'].sum()
	# shotid_attempt_gb = fg_attempt.groupby(['shot_id'])['SHOT_ATTEMPTED_FLAG'].sum()
	# player_eff_byzone = shotid_make_gb / shotid_attempt_gb

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

		fig_court3, ax_court3 = plt.subplots()
		
		ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
			color = 'white',
			lw = 2,
			zones_flag = 0)

		if twitter_flag == 1:

			tweet.add_twitterhandle(fig_court3)

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

		court_bin_make = court_bin_make.flatten()
		court_bin_attempt = court_bin_attempt.flatten()
		fga_filter = np.sort(court_bin_attempt)[-bin_edge_count]
		commonbins = np.where(court_bin_attempt < fga_filter, 0, court_bin_attempt)

		center_x = []
		center_y = []

		# need to find center of each bin to then plot a shape at
		for i in range(0, len(xedges_make) - 1):

			center_x.append((xedges_make[i] + xedges_make[i + 1]) / 2)
			center_y.append((yedges_make[i] + yedges_make[i + 1]) / 2)


		# count of all field goals in each bin
		fg_eff = commonbins

		# loop through bins
		for bin_i in range(0, len(fg_eff)):

			# divide successful field goal count by attempted field goal count for each bin
			if commonbins[bin_i] == 0:

				fg_eff[bin_i] = 2.01

			else:

				fg_eff[bin_i] = court_bin_make[bin_i] / commonbins[bin_i]

		fg_eff = np.reshape(fg_eff, (bin_edge_count, bin_edge_count))
		fg_eff_diff = np.subtract(fg_eff, league_avg_eff_bybin)
		# print(fg_eff_diff)
		fg_eff_masked = np.ma.masked_greater(fg_eff, 1)
		fg_eff_masked_lgavg = np.ma.masked_greater(fg_eff_diff, 1)
		fg_eff_masked_lgavg = np.ma.masked_invalid(fg_eff_masked_lgavg)

		# select color map and quantity of colors
		cmap_discrete = plt.cm.get_cmap('bwr', 10)

		# mesh grid based on bin edges
		xedges, yedges = np.meshgrid(xedges_make, yedges_make)
		plot_eff2 = ax_court2.pcolormesh(xedges, yedges, fg_eff_masked.T, cmap = cmap_discrete)
		cbar2 = plt.colorbar(plot_eff2, ax = ax_court2)

		xcenters, ycenters = np.meshgrid(center_x, center_y)
		attempts_reshaped = np.reshape(court_bin_attempt, (bin_edge_count, bin_edge_count)).T

		np.nan_to_num(fg_eff_diff, copy = False, nan = 1.01)

		cmap_bounds = [-0.1, -0.05, 0.05, 0.1]
		cmap_colors = ['steelblue', 'lightblue', 'grey', 'orange', 'red']
		cmap_reps = ['-0.1', '-0.05', '0.0', '0.05', '0.1']

		fg_eff_diff_cmap = fg_eff_diff
		fg_eff_diff_cmap = np.where(fg_eff_diff <= cmap_bounds[0], cmap_bounds[0], fg_eff_diff_cmap)
		fg_eff_diff_cmap = np.where((fg_eff_diff <= cmap_bounds[1]) & (fg_eff_diff > cmap_bounds[0]), cmap_bounds[1], fg_eff_diff_cmap)
		fg_eff_diff_cmap = np.where((fg_eff_diff < cmap_bounds[2]) & (fg_eff_diff > cmap_bounds[1]), 0.0, fg_eff_diff_cmap)
		fg_eff_diff_cmap = np.where((fg_eff_diff < cmap_bounds[3]) & (fg_eff_diff >= cmap_bounds[2]), cmap_bounds[2], fg_eff_diff_cmap)
		fg_eff_diff_cmap = np.where((fg_eff_diff_cmap >= cmap_bounds[3]) & (fg_eff_diff_cmap <= 1), cmap_bounds[3], fg_eff_diff_cmap)

		fg_eff_diff_cmap_str = fg_eff_diff_cmap.astype(str)
		fg_eff_diff_cmap_str = np.where(fg_eff_diff_cmap_str == cmap_reps[0], cmap_colors[0], fg_eff_diff_cmap_str)
		fg_eff_diff_cmap_str = np.where(fg_eff_diff_cmap_str == cmap_reps[1], cmap_colors[1], fg_eff_diff_cmap_str)
		fg_eff_diff_cmap_str = np.where(fg_eff_diff_cmap_str == cmap_reps[2], cmap_colors[2], fg_eff_diff_cmap_str)
		fg_eff_diff_cmap_str = np.where(fg_eff_diff_cmap_str == cmap_reps[3], cmap_colors[3], fg_eff_diff_cmap_str)
		fg_eff_diff_cmap_str = np.where(fg_eff_diff_cmap_str == cmap_reps[4], cmap_colors[4], fg_eff_diff_cmap_str)
		fg_eff_diff_cmap_str = fg_eff_diff_cmap_str.T
	
		for column in range(0, bin_edge_count):

			for row in range(0, bin_edge_count):

				if fg_eff.T[row, column] > 1:

					pass

				else:

					ax_court3.scatter(x = xcenters[row, column],
						y = ycenters[row, column],
						s = 10 * attempts_reshaped[row, column],
						c = fg_eff_diff_cmap_str[row, column],
						marker = 'h')

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
		ax_court3.set(title = player[0] + ', ' + season)

		# set background colors
		ax_court1.set_facecolor('black')
		ax_court2.set_facecolor('black')
		ax_court3.set_facecolor('black')

		# remove axes ticks
		ax_court1.set_xticks([])
		ax_court1.set_yticks([])
		ax_court2.set_xticks([])
		ax_court2.set_yticks([])
		ax_court3.set_xticks([])
		ax_court3.set_yticks([])

		add_hexlegend.add_legend_shotchart(ax_court3)

		if savefig_flag == 1:

			# specify file type
			image_type = '.jpeg'

			# specify file name
			fig1_name = player[0] + '_' + season + '_shotchart' + image_type
			fig2_name = player[0] + '_' + season + '_shotchartEff' + image_type
			fig3_name = player[0] + '_' + season + '_shotchartEff2' + image_type
			fig_court3.set_size_inches(10, 8)

			# save file
			fig_court1.savefig(fig1_name, dpi = 1000, bbox_inches = 'tight')
			fig_court2.savefig(fig2_name, dpi = 1000, bbox_inches = 'tight')
			fig_court3.savefig(fig3_name, dpi = 500, bbox_inches = 'tight')



		print('\n--- %s seconds ---\n' % (time.time() - start_time))

		plt.show()

	return fg_make

if __name__ == '__main__':

	player = ['Kevin Garnett']
	season = '2003-04'
	fg_type = 'FGA'
	season_type = 'Regular Season'
	period = 0
	plot_flag = 1
	twitter_flag = 0
	bin_edge_count = 20
	plot_fg = 'all'
	savefig_flag = 1

	fg_make = player_shotchart(player, season, fg_type, season_type, period, plot_flag, twitter_flag, bin_edge_count, plot_fg, savefig_flag)