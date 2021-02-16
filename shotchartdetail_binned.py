import matplotlib.pyplot as plt
import requests
import pandas as pd
from nba_api.stats.endpoints import commonplayerinfo as cpi 
import json
import NBA_court_zones
from nba_api.stats.endpoints import shotchartdetail
from matplotlib.patches import Circle, Rectangle, Arc
import time
from CommonAllPlayers_func import get_playerid

name = input("Insert player name. (case sensitive)\n")

start_time = time.time()

playerid = get_playerid(name)

response = shotchartdetail.ShotChartDetail(
	team_id = 0, 
	player_id = playerid,
	context_measure_simple = 'FGA', # FGA/FG3A are made & missed
	#season_type_all_star = 'Regular Season',
	season_nullable = '2020-21'
	#period = '4',
)

content = json.loads(response.get_json())

# transform contents into dataframe
results = content['resultSets'][0]
headers = results['headers']
rows = results['rowSet']
fg_attempt = pd.DataFrame(rows)
fg_attempt.columns = headers

# all field goal attempts
fg_attempt['LOC_X'] = -1 * fg_attempt['LOC_X']

# all successful field goals
fg_make = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 1]

# all unsuccessful field goals
fg_miss = fg_attempt.loc[fg_attempt['SHOT_MADE_FLAG'] == 0]

# dataframe for each zone
abovebreak_3 = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Above the Break 3']
corner3_right = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Right Corner 3']
corner3_left = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Left Corner 3']
midrange = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Mid-Range']
restricted = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Restricted Area']
paint = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'In The Paint (Non-RA)']
backcourt = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Backcourt']

# summary by zone
attempted_byZone = fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_ATTEMPTED_FLAG'].sum()
successful_byZone = fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_MADE_FLAG'].sum()
pct_byZone = fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_MADE_FLAG'].sum() / fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_ATTEMPTED_FLAG'].sum()
print('\n\n', attempted_byZone, '\n\n', successful_byZone, '\n\n', pct_byZone)

# Create figure
fig_court, ax_court = plt.subplots(1)

NBA_court_zones.draw_NBA_court(
	color = 'black',
	lw = 2,
	zones_flag = 0)

# Plot data
ax_court.scatter(fg_make['LOC_X'], fg_make['LOC_Y'], c = 'green', marker = '.', alpha = 0.7)
ax_court.scatter(fg_miss['LOC_X'], fg_miss['LOC_Y'], c = 'red', marker = '.', alpha = 0.7)

# Plot data by zone
#ax_court.scatter(abovebreak_3['LOC_X'], abovebreak_3['LOC_Y'], c = 'orange', marker = '.', alpha = 1)
#ax_court.scatter(corner3_right['LOC_X'], corner3_right['LOC_Y'], c = 'red', marker = '.', alpha = 1)
#ax_court.scatter(corner3_left['LOC_X'], corner3_left['LOC_Y'], c = 'green', marker = '.', alpha = 1)
#ax_court.scatter(midrange['LOC_X'], midrange['LOC_Y'], c = 'black', marker = '.', alpha = 1)
#ax_court.scatter(restricted['LOC_X'], restricted['LOC_Y'], c = 'indigo', marker = '.', alpha = 1)
#ax_court.scatter(paint['LOC_X'], paint['LOC_Y'], c = 'blue', marker = '.', alpha = 1)

# Create title
ax_court.set(title = name)

print('\n--- %s seconds ---\n' % (time.time() - start_time))

plt.show()