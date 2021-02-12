import matplotlib.pyplot as plt
import requests
import pandas as pd
from nba_api.stats.endpoints import commonplayerinfo as cpi 
import json
import NBA_court_zones
from nba_api.stats.static import players
from nba_api.stats.endpoints import shotchartdetail
from matplotlib.patches import Circle, Rectangle, Arc
import CommonTeamRoster_func

season = '2020-21'
team = 1610612759
struc = 'df'

plot_flag = 1

roster_df = CommonTeamRoster_func.create_roster(season, team, struc)
roster_df = roster_df.loc[roster_df['EXP'] != 'R']
roster = roster_df['PLAYER'].tolist()

abovebreak_3_list = []
abovebreak_3_player_list = []
corner3_right_list = []
corner3_right_player_list = []
corner3_left_list = []
corner3_left_player_list = []
midrange_list = []
midrange_player_list = []
restricted_list = []
restricted_player_list = []
paint_list = []
paint_player_list = []

for player_roster in roster:

	player_dict = players.get_players()

	name = player_roster
	#print('\n\n', name, '\n\n')

	player = [player for player in player_dict if player['full_name'] == name][0]

	response = shotchartdetail.ShotChartDetail(
		team_id = 0, 
		player_id = player['id'],
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
	
	#print('\n\n', attempted_byZone, '\n\n', successful_byZone, '\n\n', pct_byZone)

	if not abovebreak_3.empty:

		abovebreak_3_list.append(attempted_byZone['Above the Break 3'])
		abovebreak_3_player_list.append(player_roster)

	if not corner3_right.empty:

		corner3_right_list.append(attempted_byZone['Right Corner 3'])
		corner3_right_player_list.append(player_roster)

	if not corner3_left.empty:

		corner3_left_list.append(attempted_byZone['Left Corner 3'])
		corner3_left_player_list.append(player_roster)

	if not midrange.empty:

		midrange_list.append(attempted_byZone['Mid-Range'])
		midrange_player_list.append(player_roster)

	if not restricted.empty:

		restricted_list.append(attempted_byZone['Restricted Area'])
		restricted_player_list.append(player_roster)

	if not paint.empty:

		paint_list.append(attempted_byZone['In The Paint (Non-RA)'])
		paint_player_list.append(player_roster)

zones_df = pd.DataFrame()

# restricted area
zones_df['Player'] = restricted_player_list
zones_df['Attempted'] = restricted_list

if plot_flag == 1:

	# create figure
	fig_court, ax_court = plt.subplots(1)

	NBA_court_zones.draw_NBA_court(
		color = 'black',
		lw = 2,
		zones_flag = 0)

	# plot data
	ax_court.scatter(fg_make['LOC_X'], fg_make['LOC_Y'], c = 'green', marker = '.', alpha = 0.7)
	ax_court.scatter(fg_miss['LOC_X'], fg_miss['LOC_Y'], c = 'red', marker = '.', alpha = 0.7)

	# plot data by zone
	ax_court.scatter(abovebreak_3['LOC_X'], abovebreak_3['LOC_Y'], c = 'orange', marker = '.', alpha = 1)
	ax_court.scatter(corner3_right['LOC_X'], corner3_right['LOC_Y'], c = 'red', marker = '.', alpha = 1)
	ax_court.scatter(corner3_left['LOC_X'], corner3_left['LOC_Y'], c = 'green', marker = '.', alpha = 1)
	ax_court.scatter(midrange['LOC_X'], midrange['LOC_Y'], c = 'black', marker = '.', alpha = 1)
	ax_court.scatter(restricted['LOC_X'], restricted['LOC_Y'], c = 'indigo', marker = '.', alpha = 1)
	ax_court.scatter(paint['LOC_X'], paint['LOC_Y'], c = 'blue', marker = '.', alpha = 1)

	# create title
	ax_court.set(title = name)

	plt.show()

