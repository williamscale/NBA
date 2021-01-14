import pandas as pd 
import year_range_func
import matplotlib.pyplot as plt
import ptsDif_func
import finalrecord_func
import record_func
from statistics import stdev, variance

def create_ptsDif_CumVsRecord_df(start_year, end_year, ptsDif, games, greater_or_lesser, plot_flag = 0):

	year_range = year_range_func.create_yearRange_list(start_year, end_year)
	ptsDif_df = pd.DataFrame()

	for year in year_range:

		new_ptsDif = ptsDif_func.create_ptsDif_series(ptsDif, games, year, greater_or_lesser).to_frame()
		new_ptsDif['Year'] = year
		ptsDif_df = pd.concat([ptsDif_df, new_ptsDif])

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

	win_pct = ptsDif_df['Wins'].sum() / ptsDif_df['GP'].sum()
	avg_wins = round(win_pct * 82, 1)
	best_case = round(ptsDif_df['Win Pct'].max() * 82, 0)
	worst_case = round(ptsDif_df['Win Pct'].min() * 82, 0)

	best_info = ptsDif_df.iloc[ptsDif_df['Win Pct'].idxmax()]
	worst_info = ptsDif_df.iloc[ptsDif_df['Win Pct'].idxmin()]
	std_dev = stdev(ptsDif_df['Win Pct']) * 82
	var = variance(ptsDif_df['Win Pct']) * 82

	print('From ' + str(start_year - 1) + '-' + str(start_year) + ' to ' + str(end_year) + '-' + str(end_year + 1) + 
		', the average number of wins for a team that starts with a point differential of ' + str(ptsDif) + ' ' +
		u'\u00B1' + ' 5 after ' + str(games) + ' games is ' + str(avg_wins) + '.\nThe best case was ' + str(best_case) +
		'.\nThe worst case was ' + str(worst_case) + '.')

	print('Standard Deviation: ', std_dev)
	print('Variation: ', var)
	print('Best case: \n', best_info)
	print('Worse case: \n', worst_info)

	if plot_flag == 1:

		hist_data, bin_bounds, garbage = plt.hist(ptsDif_df['Win Pct'], bins = 8)
		#print(bin_bounds)
		#print(garbage)
		plt.xlabel('Win Pct')
		plt.ylabel('Team Qty')
		plt.title('Final Win Percentage for Teams with \nPoint Differential of -15 to -25 after ' + str(games) + ' Games')
		plt.grid()
		plt.show()

	return ptsDif_df

def create_record_CumVsFinal_df(start_year, end_year, record):

	year_range = year_range_func.create_yearRange_list(start_year, end_year)
	records = pd.DataFrame()

	for year in year_range:

		r = record_func.create_teamsrecord_df(record, year)
		records = pd.concat([records, r])
		print('Loading...' + year)

	records.reset_index(drop = True, inplace = True)

	win_pct = records['Wins'].sum() / records['GP'].sum()
	avg_wins = win_pct * 82
	best_case = records['Win Pct'].max() * 82
	worst_case = records['Win Pct'].min() * 82

	best_info = records.iloc[records['Win Pct'].idxmax()]
	worst_info = records.iloc[records['Win Pct'].idxmin()]

	print('From ' + str(start_year - 1) + '-' + str(start_year) + ' to ' + str(end_year) + '-' + str(end_year + 1) + ', '
		'the average number of wins for a team that starts ' + record + ' is ' + str(avg_wins) + 
		'.\nThe best case was ' + str(best_case) + '.\nThe worst case was ' + str(worst_case) + '.')

	print(records)
	print(best_info)
	print(worst_info)

	hist = records['Win Pct'].hist()
	plt.xlabel('Win Pct')
	plt.ylabel('Team Qty')
	plt.title('Final Win Percentage for Teams that Start ' + record)
	plt.show()

	return records

if __name__ == '__main__':

	start_year = 2016
	end_year = 2016
	ptsDif = 10
	games = 5
	record = '10-5'
	greater_or_lesser = 'within'

	ptsDif_df = create_ptsDif_CumVsRecord_df(start_year, end_year, ptsDif, games, greater_or_lesser, plot_flag = 1)
	#records_df = create_record_CumVsFinal_df(start_year, end_year, record)

	print(ptsDif_df)
	#print(records_df)