import pandas as pd 
import matplotlib.pyplot as plt
import ptsDif_func
import finalrecord_func
import record_func
from statistics import stdev, variance
import os
import sys

file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', 'Misc'))

import year_range_func

def create_ptsDif_CumVsRecord_df(start_year, end_year, ptsDif, games, greater_or_lesser, plot_flag = 0):

	plt.style.use('dark_background')

	year_range = year_range_func.create_yearRange_list(start_year, end_year)
	ptsDif_df = pd.DataFrame()

	if games > 50 :

		shortened_seasons = ['1998-99', '2011-12', '2019-20']
		year_range = [s for s in year_range if s not in shortened_seasons]

	for year in year_range:

		new_ptsDif = ptsDif_func.create_ptsDif_series(ptsDif, games, year, greater_or_lesser).to_frame()
		new_ptsDif['Year'] = year
		ptsDif_df = pd.concat([ptsDif_df, new_ptsDif])
		print('Loading...' + year)

	if ptsDif_df.empty:

		print('No qualifiers.')
		exit()

	finalrecord_df = finalrecord_func.create_finalrecord_df(start_year, end_year)

	ptsDif_df.reset_index(inplace = True)
	ptsDif_df.columns = ['Team', 'Point Differential', 'Year']


	finalrecord_df_cond = pd.DataFrame()

	for team in ptsDif_df['Team']:

		new_finalrecord_df_cond = finalrecord_df[(finalrecord_df['Team'] == team)]
		finalrecord_df_cond = pd.concat([finalrecord_df_cond, new_finalrecord_df_cond])

	finalrecord_df_cond.reset_index(drop = True, inplace = True)

	list_season = []
	list_record = []

	for idx in ptsDif_df.index:

		season = ptsDif_df['Year'][idx]
		list_season.append(season)

		record = finalrecord_df_cond[list_season[idx]][idx]
		list_record.append(record)

	ptsDif_df['Final Record'] = list_record

	# substring to be searched 
	dash = '-'

	# finding dash and creating list with index of dash within str 
	dash_loc = ptsDif_df['Final Record'].str.find(dash).tolist()

	# create empty lists
	wins = []
	losses = []

	for i in range(0, len(dash_loc)):

		wins.append(ptsDif_df.iloc[i]['Final Record'][0 : dash_loc[i]])
		losses.append(ptsDif_df.iloc[i]['Final Record'][dash_loc[i] + 1 :])

	wins = [int(i) for i in wins]
	losses = [int(i) for i in losses]
	gp = [wins[i] + losses[i] for i in range(len(wins))]
	win_pct = [wins[i] / gp[i] for i in range(len(wins))]

	ptsDif_df['Wins'] = wins
	ptsDif_df['Losses'] = losses
	ptsDif_df['GP'] = gp
	ptsDif_df['Win Pct'] = win_pct
	ptsDif_df.sort_values(by = ['Win Pct'], inplace = True, ascending = True)
	ptsDif_df['Team, Year'] = ptsDif_df['Team'] + ', ' + ptsDif_df['Year']

	bar_x_list = ptsDif_df['Team, Year'].tolist()
	bar_y_list = ptsDif_df['Win Pct'].tolist()

	win_pct = ptsDif_df['Wins'].sum() / ptsDif_df['GP'].sum()
	avg_wins = round(win_pct * 82, 1)
	best_case = round(ptsDif_df['Win Pct'].max() * 82, 0)
	worst_case = round(ptsDif_df['Win Pct'].min() * 82, 0)

	best_info = ptsDif_df.iloc[ptsDif_df['Win Pct'].idxmax()]
	worst_info = ptsDif_df.iloc[ptsDif_df['Win Pct'].idxmin()]
	std_dev = stdev(ptsDif_df['Win Pct']) * 82
	var = variance(ptsDif_df['Win Pct']) * 82

	print('\nFrom ' + str(start_year - 1) + '-' + str(start_year) + ' to ' + str(end_year) + '-' + str(end_year + 1) + 
		', the average number of wins for a team that starts with a point differential of ' + str(ptsDif) + ' ' +
		u'\u00B1' + ' 5 after ' + str(games) + ' games is ' + str(avg_wins) + '.\nThe best case was ' + str(best_case) +
		'.\nThe worst case was ' + str(worst_case) + '.\n')

	print('Standard Deviation: ', std_dev)
	print('Variation: ', var, '\n')
	print('Best case: \n', best_info, '\n')
	print('Worse case: \n', worst_info, '\n')

	print(ptsDif_df, '\n\n')

	if plot_flag == 1:

		# hist_data, bin_bounds, garbage = plt.hist(ptsDif_df['Win Pct'],
		# 	bins = 6,
		# 	color = 'goldenrod')
		plt.bar(x = bar_x_list,
			height = bar_y_list,
			color = 'goldenrod')

		#print(bin_bounds)
		#print(garbage)
		# plt.xlabel('Team')
		plt.ylabel('Win %')
		plt.xticks(fontsize = 10, rotation = 45)
		plt.title('Final Win Percentage for Teams with \nPoint Differential of -60 to -70 after ' + str(games) + ' Games')
		plt.grid(b = False)
		plt.show()

	return ptsDif_df

def create_record_CumVsFinal_df(start_year, end_year, record):

	plt.style.use('dark_background')

	year_range = year_range_func.create_yearRange_list(start_year, end_year)
	records = pd.DataFrame()

	for year in year_range:

		r = record_func.create_teamsrecord_df(record, year)
		records = pd.concat([records, r])
		print('Loading...' + year)

	records.reset_index(drop = True, inplace = True)
	records.sort_values(by = ['Win Pct'], inplace = True, ascending = True)
	records['Team, Year'] = records['Team'] + ', ' + records['Year']

	bar_x_list = records['Team, Year'].tolist()
	bar_y_list = records['Win Pct'].tolist()

	win_pct = records['Wins'].sum() / records['GP'].sum()
	avg_wins = win_pct * 82
	best_case = records['Win Pct'].max() * 82
	worst_case = records['Win Pct'].min() * 82
	avg_winpct = records['Win Pct'].mean()
	std_dev = stdev(records['Win Pct']) * 82

	best_info = records.iloc[records['Win Pct'].idxmax()]
	worst_info = records.iloc[records['Win Pct'].idxmin()]

	print('\nFrom ' + str(start_year - 1) + '-' + str(start_year) + ' to ' + str(end_year) + '-' + str(end_year + 1) + ', '
		'the average number of wins for a team that starts ' + record + ' is ' + str(avg_wins) + 
		'.\nThe best case was ' + str(best_case) + '.\nThe worst case was ' + str(worst_case) + '.', '\n')

	print('Best case:\n', best_info, '\n')
	print('Worst case:\n', worst_info, '\n')

	print(records, '\n\n')

	# print(std_dev)

	# hist = records['Win Pct'].hist(color = 'goldenrod')
	plt.bar(x = bar_x_list,
		height = bar_y_list,
		color = 'goldenrod')
	plt.xlabel('Team')
	plt.ylabel('Win %')
	plt.xticks(rotation = 60)
	plt.title('Final Win Percentage for Teams that Start ' + record)
	plt.grid(b = False)
	plt.show()

	return records

if __name__ == '__main__':

	start_year = 1970	
	end_year = 2019
	ptsDif = -65
	games = 53
	record = '26-27'
	greater_or_lesser = 'within'

	# ptsDif_df = create_ptsDif_CumVsRecord_df(start_year, end_year, ptsDif, games, greater_or_lesser, plot_flag = 1)
	# records_df = create_record_CumVsFinal_df(start_year, end_year, record)

	# # print(ptsDif_df)
	# print(records_df)