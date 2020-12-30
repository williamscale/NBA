import gamelog_cumulative
import pandas as pd

def create_teamsrecord_df(record_input, year_input):

	# input record to check and year
	#record_input = '3-0'
	#year_input = '2015-16'

	# output dataframe
	recordCum_df = gamelog_cumulative.create_recordCum_df(year_input)

	# create empty df to populate in loop
	record_count = pd.DataFrame()

	# loop through each column (team) and 1 if they had inputted record, 0 if not
	for team in recordCum_df:
		
		# (?<!\S) says that start/end of string must be to right/left of searched term
		record_01 = recordCum_df[team].str.contains(r'(?<!\S)' + record_input + r'(?!\S)').sum()#.tolist()
		record_count.at[0, team] = record_01

	# obtain last row (final record) & transpose
	final_record = recordCum_df.tail(1).transpose().reset_index()
	final_record.columns = ['Team', 'Final Record']

	# transpose
	record_count = record_count.transpose().reset_index()
	record_count.columns = ['Team', 'Record ' + record_input + '?']

	# combine dataframes and remove duplicate Team column
	record_count = record_count.join(final_record.set_index('Team'), on='Team')

	# get indexes of teams with column that does not match inputted record
	nomatch_idx = record_count[record_count['Record ' + record_input + '?'] == 0].index

	# drop previous rows and reset index
	record_count.drop(nomatch_idx, inplace = True)
	record_count.reset_index(drop = True, inplace = True)
	record_count.drop('Record ' + record_input + '?', 1, inplace = True)

	record_count['Year'] = pd.Series([year_input for team in range(len(record_count.index))], index = record_count.index)

	# substring to be searched 
	dash = '-'
	  
	# finding dash and creating list with index of dash within str 
	dash_loc = record_count['Final Record'].str.find(dash).tolist()

	# create empty lists
	wins = []
	losses = []

	for i in range(0, len(dash_loc)):

		wins.append(record_count.iloc[i]['Final Record'][0 : dash_loc[i]])
		losses.append(record_count.iloc[i]['Final Record'][dash_loc[i] + 1 :])

	wins = [int(i) for i in wins]
	losses = [int(i) for i in losses]
	gp = [wins[i] + losses[i] for i in range(len(wins))]
	win_pct = [wins[i] / gp[i] for i in range(len(wins))]

	record_count['Wins'] = wins
	record_count['Losses'] = losses
	record_count['GP'] = gp
	record_count['Win Pct'] = win_pct

	return record_count

if __name__ == '__main__':
	record_input = '15-6'
	year_input = '2011-12'
	x = create_teamsrecord_df(record_input, year_input)
	print(x)