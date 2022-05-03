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
# import NBA_court_zones
# import ShotChartZones_Func
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', 'Players'))
from CommonAllPlayers_Func import get_playerid
sys.path.append(os.path.join(file_dir, '..', 'PlottingSupport'))
# import add_twitterhandle as tweet

def player_shotchart(player, season = 0, fg_type = 'FGA', season_type = 'Regular Season', period = 0):

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

	# all successful field goals
	fg_make = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 1]

	# all unsuccessful field goals
	fg_miss = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 0]

	file_name = player[0].replace(' ', '-') + '.' + season + '.csv'
	fg_attempt.to_csv(file_name)

	return fg_attempt

if __name__ == '__main__':

	player = ['Derrick White']
	season = '2021-22'
	fg_type = 'FGA'
	season_type = 'Regular Season'
	period = 0

	fg_make = player_shotchart(player, season, fg_type, season_type, period)