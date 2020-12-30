import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
from nba_api.stats.endpoints import leaguegamelog
import list_func
import time

def create_gamelogCum_df(year, column_cum):

	log_raw = leaguegamelog.LeagueGameLog(
		player_or_team_abbreviation='T',
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

	return gamelog_cum_date 

if __name__ == '__main__':
	year = '1999-00'
	column_cum = 'Record'
	x = create_gamelogCum_df(year, column_cum)	
	print(x)