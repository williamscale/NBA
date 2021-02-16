import pandas as pd
import json
from nba_api.stats.endpoints import commonallplayers

def create_currentplayers_lists():

	response = commonallplayers.CommonAllPlayers(
			is_only_current_season = 1)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	currentplayers_raw = content['resultSets'][0]

	headers = currentplayers_raw['headers']

	rows = currentplayers_raw['rowSet']

	currentplayers_df = pd.DataFrame(rows)

	currentplayers_df.columns = headers

	currentplayer_id_list = currentplayers_df['PERSON_ID'].tolist()
	currentplayer_list = currentplayers_df['DISPLAY_FIRST_LAST'].tolist()

	return currentplayer_id_list, currentplayer_list

def get_playerid(player_name):

	response = commonallplayers.CommonAllPlayers()

	content = json.loads(response.get_json())

	# transform contents into dataframe
	players_raw = content['resultSets'][0]

	headers = players_raw['headers']

	rows = players_raw['rowSet']

	players_df = pd.DataFrame(rows)

	players_df.columns = headers

	playerid_row = players_df.loc[players_df['DISPLAY_FIRST_LAST'] == player_name]
	playerid = playerid_row['PERSON_ID']

	return playerid

if __name__ == '__main__':

	player_name = 'Tony Parker'
	x = create_currentplayers_lists()
	y = get_playerid(player_name)

	print(y)