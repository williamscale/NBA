import pandas as pd
import json
from nba_api.stats.endpoints import teamdashptpass

response = teamdashptpass.TeamDashPtPass(
	team_id = 1610612759)

content = json.loads(response.get_json())

# transform contents into dataframe
pass_made_raw = content['resultSets'][0]
pass_received_raw = content['resultSets'][1]

headers = pass_made_raw['headers']
rows_pass_made = pass_made_raw['rowSet']
rows_pass_received = pass_received_raw['rowSet']

pass_made_raw = pd.DataFrame(rows_pass_made)
pass_received_raw = pd.DataFrame(rows_pass_received)

pass_made_raw.columns = headers
pass_received_raw.columns = headers

print(pass_received_raw)