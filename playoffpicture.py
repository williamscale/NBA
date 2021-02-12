import pandas as pd
import json
from nba_api.stats.endpoints import playoffpicture

response = playoffpicture.PlayoffPicture(
	season_id = 22020
	)

content = json.loads(response.get_json())

# transform contents into dataframe
# east standings
east_raw = content['resultSets'][2]
west_raw = content['resultSets'][5]

east_headers = east_raw['headers']
west_headers = west_raw['headers']

east_rows = east_raw['rowSet']
west_rows = west_raw['rowSet']

east_standings = pd.DataFrame(east_rows)
west_standings = pd.DataFrame(west_rows)

east_standings.columns = east_headers
west_standings.columns = west_headers

print(west_standings)