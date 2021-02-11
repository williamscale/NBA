import pandas as pd
import json
from nba_api.stats.endpoints import commonteamroster as ctr 

def create_roster(season, team, struc):

	response = ctr.CommonTeamRoster(
		season = '2020-21',
		team_id = 1610612759)

	content = json.loads(response.get_json())

	# transform contents into dataframe
	results = content['resultSets'][0]
	headers = results['headers']
	rows = results['rowSet']

	team_roster = pd.DataFrame(rows)
	team_roster.columns = headers

	if struc == 'df':

		roster = team_roster

	elif struc == 'list':

		roster = team_roster['PLAYER'].tolist()

	else:

		print('\nIncorrect data structure input. Use either "list" or "df".\n')

	return roster

if __name__ == '__main__':

	season = '2020-21'	
	team = 1610612759
	struc = 'list'
	
	roster = create_roster(season, team, struc)

