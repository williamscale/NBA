import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
from nba_api.stats.endpoints import leaguegamelog
import list_func
import time

def create_recordCum_df(year):

	log_raw = leaguegamelog.LeagueGameLog(
		player_or_team_abbreviation='T',
		season = year,
		sorter = 'DATE',
		#timeout = 30,
		#headers = {'Host': 'stats.nba.com',
		#'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
		#'Accept': 'application/json, text/plain, */*',
    	#'Accept-Language': 'en-US,en;q=0.5',
    	#'Referer': 'https://stats.nba.com/',
    	#'Accept-Encoding': 'gzip, deflate, br',
    	#'Connection': 'keep-alive',}
		#date_to_nullable = '2017-12-01',
		#date_from_nullable = '2017-12-01',
		)

	time.sleep(3)
	content = json.loads(log_raw.get_json())
	results = content['resultSets'][0]
	headers = results['headers']
	rows = results['rowSet']

	log = pd.DataFrame(rows)
	log.columns = headers

	log_nodup = log.drop_duplicates(subset = 'GAME_ID')

	log['WIN'] = (log['WL'] == 'W') * 1
	log['LOSS'] = (log['WL'] == 'L') * 1
	log['Cumulative Wins'] = log.groupby('TEAM_ABBREVIATION').WIN.cumsum()
	log['Cumulative Losses'] = log.groupby('TEAM_ABBREVIATION').LOSS.cumsum()
	log['Record'] = log['Cumulative Wins'].astype(str) + '-' + log['Cumulative Losses'].astype(str)

	record_team = log[['SEASON_ID', 'TEAM_ID', 'TEAM_ABBREVIATION', 'TEAM_NAME', 'GAME_ID', 'GAME_DATE', 'WL', 'Record']].copy()

	teams = record_team['TEAM_ABBREVIATION'].unique().tolist()
	dates = record_team['GAME_DATE'].unique()

	teams_date = [team + ' DATE' for team in teams] 
	teams_record = [team for team in teams]


	column_names = list_func.alternateList(teams_date, teams_record)

	record_date = pd.DataFrame(columns = teams_record)

	for team in teams:

		record_list = record_team.loc[record_team['TEAM_ABBREVIATION'] == team]['Record'].tolist()

		#date_list = record_team.loc[record_team['TEAM_ABBREVIATION'] == team]['GAME_DATE'].tolist()
		
		record_date[team] = record_list
		#record_date[team + ' DATE'] = date_list
		#final_record = record_date.iloc[-1]
		#final_record = final_record[1::2]

	return record_date #, final_record

def create_winsCum_df(year):

	log_raw = leaguegamelog.LeagueGameLog(
		player_or_team_abbreviation='T',
		season = year,
		sorter = 'DATE',
		#date_to_nullable = '2017-12-01',
		#date_from_nullable = '2017-12-01',
		)

	content = json.loads(log_raw.get_json())
	results = content['resultSets'][0]
	headers = results['headers']
	rows = results['rowSet']

	log = pd.DataFrame(rows)
	log.columns = headers

	log_nodup = log.drop_duplicates(subset = 'GAME_ID')

	log['WIN'] = (log['WL'] == 'W') * 1
	log['Cumulative Wins'] = log.groupby('TEAM_ABBREVIATION').WIN.cumsum()

	wins_team = log[['SEASON_ID', 'TEAM_ID', 'TEAM_ABBREVIATION', 'TEAM_NAME', 'GAME_ID', 'GAME_DATE', 'WL', 'Cumulative Wins']].copy()

	teams = wins_team['TEAM_ABBREVIATION'].unique().tolist()
	dates = wins_team['GAME_DATE'].unique()

	teams_date = [team + ' DATE' for team in teams] 
	teams_wins = [team + ' Cumulative Wins' for team in teams]

	column_names = list_func.alternateList(teams_date, teams_wins)

	wins_date = pd.DataFrame(columns = column_names)

	for team in teams:

		wins_list = wins_team.loc[wins_team['TEAM_ABBREVIATION'] == team]['Cumulative Wins'].tolist()

		date_list = wins_team.loc[wins_team['TEAM_ABBREVIATION'] == team]['GAME_DATE'].tolist()
		
		wins_date[team + ' Cumulative Wins'] = wins_list
		wins_date[team + ' DATE'] = date_list

	return wins_date

if __name__ == '__main__':
	year = '1999-00'
	x = create_recordCum_df(year)
	print(x)