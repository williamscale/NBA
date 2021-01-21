import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
from nba_api.stats.endpoints import leaguegamelog
import time

def create_movingAvgPlayer_df(year, player, stat):

	log_raw = leaguegamelog.LeagueGameLog(
		player_or_team_abbreviation='P',
		season = year,
		sorter = 'DATE',
		)

	time.sleep(3)
	content = json.loads(log_raw.get_json())
	results = content['resultSets'][0]
	headers = results['headers']
	rows = results['rowSet']

	log = pd.DataFrame(rows)
	log.columns = headers

	# set bounds for games played and minutes played in a season
	game_min = 20
	mins_min = game_min * 10

	# sum all minutes played and count games played for each player
	log_mins_gp = log.groupby(['PLAYER_NAME']).agg({'MIN':sum, 'PLAYER_NAME':'count'})

	# filter out by mins and gp
	log_cond = log_mins_gp[log_mins_gp['MIN'] >= mins_min] 
	log_cond = log_mins_gp[log_mins_gp['PLAYER_NAME'] >= game_min] 
	log_cond.columns = ['MINS', 'GP']

	# create list of players that satisfy conditions
	players_cond = log_cond.index.tolist()

	# create df with players that satisfy condition
	# use df[~df] for 'is not in'
	log_stat = log[log['PLAYER_NAME'].isin(players_cond)]

	# drop all unneeded columns and reset index
	log_stat = log_stat.drop(log_stat.columns.difference(['PLAYER_NAME', stat]), 1)
	log_stat.reset_index(drop = True, inplace = True)

	# calculate average of specified stat
	average_stat = log_stat.groupby('PLAYER_NAME')[stat].mean()

	# create moving average column
	log_stat['Average'] = log_stat.groupby('PLAYER_NAME')[stat].cumsum() / (log_stat.groupby('PLAYER_NAME')[stat].cumcount() + 1)

	# initialize list
	final_avg_list = []

	# loop through players
	for player in log_stat['PLAYER_NAME']:

		# append list of player final averages
		final_avg_list.append(average_stat.loc[player])
	
	# create new df column with final averages
	log_stat['Final Average'] = final_avg_list

	# create column if moving avg is within final avg bounds
	log_stat['Within bounds?'] = np.where((log_stat['Average'] >= np.floor(log_stat['Final Average'])) 
		& (log_stat['Average'] < np.ceil(log_stat['Final Average'])), 1, 0)

	# create column of moving gp
	log_stat['Cum Count'] = log_stat.groupby('PLAYER_NAME')[stat].cumcount() + 1

	# copy player names to new df and remove duplicates
	players_cond = log_stat[['PLAYER_NAME']].copy()
	players_cond.drop_duplicates(inplace = True)

	# initialize list (going to be list of lists)
	zero_list = []

	# loop through players
	for player in players_cond['PLAYER_NAME']:

		# append list to create list of zeros index for each player
		zero_list.append(np.where((log_stat['Within bounds?'] == 0) & (log_stat['PLAYER_NAME'] == player)))

	# initialize list
	final_zero_list = []

	# loop through list of lists
	for zeros_list in range(0, len(zero_list)):

		# retrieve index of final zero for each player
		final_zero_list.append(zero_list[zeros_list][0][-1])

	# create new column with final zero index
	players_cond['Final 0 Index'] = final_zero_list

	# initialize lists
	cumcount_list = []
	final_avg_cond_list = []

	# loop through players final zero indices
	for idx in players_cond['Final 0 Index']:

		# append list of final zero game
		cumcount_list.append(log_stat['Cum Count'][idx])

		# append list of final average 
		final_avg_cond_list.append(log_stat['Final Average'][idx])

	# correct game count
	cumcount_list = [game + 1 for game in cumcount_list]

	# create new columns
	players_cond['No Change Game'] = cumcount_list
	players_cond['Final Average'] = final_avg_cond_list

	# initialize list
	gp_list = []

	# loop through players 
	for player in players_cond['PLAYER_NAME']:

		# append list of gp
		gp_list.append(log_cond.loc[player, 'GP'])

	# add new column for gp and reset index
	players_cond['GP'] = gp_list
	players_cond.reset_index(drop = True, inplace = True)

	return players_cond

if __name__ == '__main__':
	year = '2018-19'
	player = 'James Harden'
	stat = 'PTS'
	x = create_movingAvgPlayer_df(year, player, stat)	
	#print(x)