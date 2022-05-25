import pandas as pd
import json
from nba_api.stats.endpoints import commonallplayers
import time

def create_currentplayers_lists(teams = []):

	response = commonallplayers.CommonAllPlayers(
		is_only_current_season = 1)

	time.sleep(0.5)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	currentplayers_raw = content['resultSets'][0]

	headers = currentplayers_raw['headers']

	rows = currentplayers_raw['rowSet']

	currentplayers_df = pd.DataFrame(rows)

	currentplayers_df.columns = headers

	if teams == []:

		currentplayer_id_list = currentplayers_df['PERSON_ID'].tolist()

		currentplayer_list = currentplayers_df['DISPLAY_FIRST_LAST'].tolist()

	elif type(teams) == str:

		currentplayer_id_team = currentplayers_df.loc[currentplayers_df['TEAM_NAME'] == teams]
		teamid = currentplayer_id_team['TEAM_ID'].tolist()

		currentplayer_id_list = currentplayer_id_team['PERSON_ID'].tolist()

		currentplayer_list = currentplayer_id_team['DISPLAY_FIRST_LAST'].tolist()

	elif teams:

		currentplayer_id_lists = []
		currentplayer_lists = []

		for team in teams:

			currentplayer_id_team = currentplayers_df.loc[currentplayers_df['TEAM_NAME'] == team]

			currentplayer_id_lists.append(currentplayer_id_team['PERSON_ID'].tolist())
			currentplayer_id_list = [player for team_list in currentplayer_id_lists for player in team_list]

			currentplayer_lists.append(currentplayer_id_team['DISPLAY_FIRST_LAST'].tolist())
			currentplayer_list = [player for team_list in currentplayer_lists for player in team_list]

	return currentplayer_id_list, currentplayer_list

def create_players_list(season):

	response = commonallplayers.CommonAllPlayers(
		is_only_current_season = 0,
		league_id = '00'
		)

	time.sleep(0.2)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	allplayers_raw = content['resultSets'][0]

	headers = allplayers_raw['headers']

	rows = allplayers_raw['rowSet']

	allplayers_df = pd.DataFrame(rows)

	allplayers_df.columns = headers

	season_start = str(int(season) - 1)

	players_df = allplayers_df.loc[(allplayers_df['FROM_YEAR'] <= season_start) & (allplayers_df['TO_YEAR'] >= season_start)]

	players_list = players_df['DISPLAY_FIRST_LAST'].tolist()

	playersid_list = players_df['PERSON_ID'].tolist()

	return players_df, players_list, playersid_list

def get_playerid(player_name = []):

	response = commonallplayers.CommonAllPlayers()

	time.sleep(0.5)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	players_raw = content['resultSets'][0]

	headers = players_raw['headers']

	rows = players_raw['rowSet']

	players_df = pd.DataFrame(rows)

	players_df.columns = headers

	playerid_list = []

	for player in player_name:

		playerid_list.append(players_df[players_df.iloc[:, 2] == player]['PERSON_ID'].tolist()[0])

	return playerid_list

if __name__ == '__main__':

	# player_name = ['Toby Bailey', 'Patty Mills', 'Dejounte Murray']
	# a, b = create_currentplayers_lists()
	c, d, e = create_players_list(season = '2021')
	# f = get_playerid()

	# print(len(b), len(a))
	print(c)