import pandas as pd
import json
from nba_api.stats.endpoints import commonplayerinfo
from CommonAllPlayers_Func import create_players_list
import time

def create_currentplayers_lists(season):

	season = '2021'
	players_df, players_list, playersid_list = create_players_list(season)

	# append to a height list
	#for player_id in player_id_list:

	response = commonplayerinfo.CommonPlayerInfo(player_id = playersid_list[69])

	time.sleep(0.1)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	playersinfo_raw = content['resultSets'][0]

	headers = playersinfo_raw['headers']

	rows = playersinfo_raw['rowSet']

	playersinfo_df = pd.DataFrame(rows)

	playersinfo_df.columns = headers

	return playersinfo_df

def get_height(player_id):

	response = commonplayerinfo.CommonPlayerInfo(player_id)

	time.sleep(0.5)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	playersinfo_raw = content['resultSets'][0]

	headers = playersinfo_raw['headers']

	rows = playersinfo_raw['rowSet']

	playersinfo_df = pd.DataFrame(rows)

	playersinfo_df.columns = headers

	height = playersinfo_df['HEIGHT'].tolist()

	return height

if __name__ == '__main__':

	season = '2021'
	player_id = '1627749'
	a, b, c = create_players_list(season)
	d = create_currentplayers_lists(season)
	e = get_height(player_id)
	print(e)