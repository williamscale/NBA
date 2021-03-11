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
import seaborn as sns
import numpy as np
from scipy import stats

name = input("Insert player name. (case sensitive)\n")
season = input("Insert season in format YYYY-YY.\n")

start_time = time.time()

playerid = get_playerid(name)

response = shotchartdetail.ShotChartDetail(
	team_id = 0, 
	player_id = playerid,
	context_measure_simple = 'FGA', # FGA/FG3A are made & missed
	#season_type_all_star = 'Regular Season',
	season_nullable = season
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
# abovebreak_3 = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Above the Break 3']
# corner3_right = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Right Corner 3']
# corner3_left = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Left Corner 3']
# midrange = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Mid-Range']
# restricted = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Restricted Area']
# paint = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'In The Paint (Non-RA)']
# backcourt = fg_attempt.loc[fg_attempt['SHOT_ZONE_BASIC'] == 'Backcourt']

# # summary by zone
# attempted_byZone = fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_ATTEMPTED_FLAG'].sum()
# successful_byZone = fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_MADE_FLAG'].sum()
# pct_byZone = fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_MADE_FLAG'].sum() / fg_attempt.groupby('SHOT_ZONE_BASIC')['SHOT_ATTEMPTED_FLAG'].sum()
# print('\n\n', attempted_byZone, '\n\n', successful_byZone, '\n\n', pct_byZone)

# Create figures
fig_court0, ax_court0 = plt.subplots()

ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
	color = 'white',
	lw = 2,
	zones_flag = 0)

fig_court1, ax_court1 = plt.subplots()

ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
	color = 'white',
	lw = 2,
	zones_flag = 0)

fig_court2, ax_court2 = plt.subplots()

ax, x_min, x_max, y_min, y_max = NBA_court_zones.draw_NBA_court(
	color = 'white',
	lw = 2,
	zones_flag = 0)

fg_make_loc = fg_make[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)
fg_miss_loc = fg_miss[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)
fg_attempt_loc = fg_attempt[['LOC_X', 'LOC_Y']].copy().reset_index(drop = True)

bin_edge_count = 10

court_bin_make, xedges_make, yedges_make, binnumber_make = stats.binned_statistic_2d(
	x = fg_make_loc['LOC_X'],
	y = fg_make_loc['LOC_Y'],
	values = None,
	statistic = 'count',
	bins = bin_edge_count,
	range = ((x_min, x_max), (y_min, y_max))
	)

court_bin_attempt, xedges_attempt, yedges_attempt, binnumber_attempt = stats.binned_statistic_2d(
	x = fg_attempt_loc['LOC_X'],
	y = fg_attempt_loc['LOC_Y'],
	values = None,
	statistic = 'count',
	bins = bin_edge_count,
	range = ((x_min, x_max), (y_min, y_max))
	)

fg_eff = court_bin_attempt

for bin_i in range(0, bin_edge_count):

	for bin_j in range(0, bin_edge_count):
		
		fg_eff[bin_i][bin_j] = court_bin_make[bin_i][bin_j] / court_bin_attempt[bin_i][bin_j]

cmap_discrete = plt.cm.get_cmap('viridis', 10)

xedges, yedges = np.meshgrid(xedges_make, yedges_make)
plot_eff0 = ax_court0.pcolormesh(xedges, yedges, fg_eff.T, cmap = cmap_discrete)
cbar0 = plt.colorbar(plot_eff0, ax = ax_court0)

plot_eff2 = ax_court2.pcolormesh(xedges, yedges, fg_eff.T, cmap = cmap_discrete)
cbar2 = plt.colorbar(plot_eff2, ax = ax_court2)

# hue for fg% maybe?
# seems to be dependednt on x,y not data
# ax_heatmap = sns.histplot(data = fg_make_loc,
# 	x = fg_make_loc['LOC_X'],
# 	y = fg_make_loc['LOC_Y'],
# 	#bins = 10,
# 	binrange = ((x_min, x_max), (y_min, y_max)),
# 	binwidth = 24,
# 	cbar = True,
# 	cmap = 'rocket_r',
# 	#color = 'flare',
# 	ax = ax_court,
# 	thresh = None
# 	)
#sns.color_palette("flare", as_cmap=True)
#sns.displot(fg_make_loc, x = fg_make_loc['LOC_X'], y = fg_make_loc['LOC_Y'])


# Plot data
ax_court0.scatter(fg_make['LOC_X'], fg_make['LOC_Y'], c = 'green', marker = 'o', alpha = 1)
ax_court0.scatter(fg_miss['LOC_X'], fg_miss['LOC_Y'], c = 'red', marker = 'x', alpha = 0.8)

ax_court1.scatter(fg_make['LOC_X'], fg_make['LOC_Y'], c = 'green', marker = 'o', alpha = 1)
ax_court1.scatter(fg_miss['LOC_X'], fg_miss['LOC_Y'], c = 'red', marker = 'x', alpha = 0.8)
#ax_heatmap = sns.heatmap(fg_makes)

# Plot data by zone
#ax_court.scatter(abovebreak_3['LOC_X'], abovebreak_3['LOC_Y'], c = 'orange', marker = '.', alpha = 1)
#ax_court.scatter(corner3_right['LOC_X'], corner3_right['LOC_Y'], c = 'red', marker = '.', alpha = 1)
#ax_court.scatter(corner3_left['LOC_X'], corner3_left['LOC_Y'], c = 'green', marker = '.', alpha = 1)
#ax_court.scatter(midrange['LOC_X'], midrange['LOC_Y'], c = 'black', marker = '.', alpha = 1)
#ax_court.scatter(restricted['LOC_X'], restricted['LOC_Y'], c = 'indigo', marker = '.', alpha = 1)
#ax_court.scatter(paint['LOC_X'], paint['LOC_Y'], c = 'blue', marker = '.', alpha = 1)

# Set titles
ax_court0.set(title = name + ' ' + season + ' FG%')
ax_court1.set(title = name + ' ' + season + ' Shot Chart')
ax_court2.set(title = name + ' ' + season + ' FG%')

# Set background colors
ax_court0.set_facecolor('black')
ax_court1.set_facecolor('black')
ax_court2.set_facecolor('black')

# add twitter handle


# Remove axes ticks
plt.xticks([])
plt.yticks([])

print('\n--- %s seconds ---\n' % (time.time() - start_time))

plt.show()