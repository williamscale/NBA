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
from nba_api.stats.endpoints import commonplayerinfo as cpi, shotchartdetail

# local imports
import NBA_court_zones
import ShotChartZones_Func
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', 'Players'))
from CommonAllPlayers_Func import get_playerid
sys.path.append(os.path.join(file_dir, '..', 'PlottingSupport'))
import add_twitterhandle as tweet

def player_shotchart(player, season = 0, fg_type = 'FGA', season_type = 'Regular Season', period = 0, plot_flag = 1, bin_edge_count = 15):

	# start timer
	start_time = time.time()

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

	furthest_make_ft = fg_make['shot_dist'].max() / (5 / 6 * 12)
	avg_make_ft = fg_make['shot_dist'].mean() / (5 / 6 * 12)

	make_dict, miss_dict = ShotChartZones_Func.create_dict_shotzones_df(fg_make, fg_miss)

	# Create figures
	fig_court1, ax_court1 = plt.subplots()
	# tweet.add_twitterhandle(fig_court1)

	ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
		color = 'white',
		lw = 2,
		zones_flag = 0)

	fig_court2, ax_court2 = plt.subplots()
	tweet.add_twitterhandle(fig_court2)

	ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
		color = 'white',
		lw = 2,
		zones_flag = 0)

	#fig_box, ax_box = plt.subplots()
	#plt.boxplot(fg_make['shot_dist'])

	fg_make_loc = fg_make[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)
	fg_miss_loc = fg_miss[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)
	fg_attempt_loc = fg_attempt[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)

	court_bin_make, xedges_make, yedges_make, binnumber_make = stats.binned_statistic_2d(
		x = fg_make_loc['LOC_X'],
		y = fg_make_loc['LOC_Y'],
		values = None,
		statistic = 'count',
		bins = bin_edge_count,
		range = ((x_min, x_max), (y_min, y_max))
		)

	court_bin_attempt, xedges_attempt, yedges_attempt, binnumber_attempt = stats.binned_statistic_2d(
		x = fg_attempt_loc['LOC_X'],
		y = fg_attempt_loc['LOC_Y'],
		values = None,
		statistic = 'count',
		bins = bin_edge_count,
		range = ((x_min, x_max), (y_min, y_max))
		)

	fg_eff = court_bin_attempt

	for bin_i in range(0, bin_edge_count):

		for bin_j in range(0, bin_edge_count):
			
			fg_eff[bin_i][bin_j] = court_bin_make[bin_i][bin_j] / court_bin_attempt[bin_i][bin_j]

	cmap_discrete = plt.cm.get_cmap('viridis', 10)

	xedges, yedges = np.meshgrid(xedges_make, yedges_make)

	plot_eff2 = ax_court2.pcolormesh(xedges, yedges, fg_eff.T, cmap = cmap_discrete)
	cbar2 = plt.colorbar(plot_eff2, ax = ax_court2)

	# Plot data
	ax_court1.scatter(fg_make['LOC_X'], fg_make['LOC_Y'], c = 'green', marker = 'o', alpha = 1, s = 3)
	# ax_court1.scatter(fg_miss['LOC_X'], fg_miss['LOC_Y'], c = 'red', marker = 'x', alpha = 0.8)

	# Set titles
	ax_court1.set(title = player[0] + ' ' + season)
	# ax_court2.set(title = name[0] + ' ' + season + ' FG%')
	# ax_court1.set(title = name[0])
	ax_court2.set(title = player[0] + ' FG%')

	# Set background colors
	ax_court1.set_facecolor('black')
	ax_court2.set_facecolor('black')

	# Remove axes ticks
	ax_court1.set_xticks([])
	ax_court1.set_yticks([])
	ax_court2.set_xticks([])
	ax_court2.set_yticks([])

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
	bin_edge_count = 10

	fg_make = player_shotchart(player, season, fg_type, season_type, period, plot_flag, bin_edge_count)