import pandas as pd
import json
from nba_api.stats.endpoints import playoffpicture

response = playoffpicture.PlayoffPicture(
	season_id = 22018
	)

content = json.loads(response.get_json())

# transform contents into dataframe
# east standings
east_standings_raw = content['resultSets'][2]
west_standings_raw = content['resultSets'][3]

east_headers = east_standings_raw['headers']
west_headers = west_standings_raw['headers']

east_rows = east_standings_raw['rowSet']
west_rows = west_standings_raw['rowSet']

east_standings = pd.DataFrame(east_rows)
west_standings = pd.DataFrame(west_rows)

east_standings.columns = east_headers
west_standings.columns = west_headers

print(east_standings)