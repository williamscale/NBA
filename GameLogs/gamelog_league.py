# standard imports
import requests
import json
import time

# third-party imports
import pandas as pd
from nba_api.stats.endpoints import leaguegamelog as lgl

def create_cat_list(season, cat):

	response_gamelog = lgl.LeagueGameLog(
		season = season)

	time.sleep(0.5)

	content_gamelog = json.loads(response_gamelog.get_json())

	# transform contents into dataframe
	results_gamelog = content_gamelog['resultSets'][0]
	headers_gamelog = results_gamelog['headers']
	rows_gamelog = results_gamelog['rowSet']
	league_gamelog = pd.DataFrame(rows_gamelog)
	league_gamelog.columns = headers_gamelog

	cat_list = league_gamelog[cat].tolist()

	return league_gamelog, cat_list

if __name__ == '__main__':

	season = '2020-21'
	cat = 'GAME_ID'

	league_gamelog, cat_list = create_cat_list(season, cat)