import pandas as pd
import json
from nba_api.stats.endpoints import franchisehistory

team_info_raw = franchisehistory.FranchiseHistory()

content = json.loads(team_info_raw.get_json())

franchise_history_list = content['resultSets']
headers = franchise_history_list[0]
#rows_east = east_standings_raw[0]
print(headers)
#east_standings = pd.DataFrame(rows_east)

#east_standings.columns = headers

