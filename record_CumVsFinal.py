import record_func
import pandas as pd 
import year_range_func
import matplotlib.pyplot as plt

start_year = 2018
end_year = 2019
record = '4-0'

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

print('From ' + str(start_year - 1) + '-' + str(start_year) + ' to ' + str(end_year) + '-' + str(end_year + 1) + ', '
	'the average number of wins for a team that starts ' + record + ' is ' + str(avg_wins) + 
	'.\nThe best case was ' + str(best_case) + '.\nThe worst case was ' + str(worst_case) + '.')

hist = records['Wins'].hist()
plt.xlabel('Win Qty')
plt.ylabel('Team Qty')
plt.title('Final Win Counts for Teams that Start ' + record)
plt.show()


