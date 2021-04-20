import pandas as pd 
import matplotlib.pyplot as plt
import time
import os
import sys

file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', '..', 'GameLogs'))

import CumVsFinal_func

start_time = time.time()

raw_data = pd.read_excel('C:/Users/caler/Documents/MyProjects/NBA/Projects/CurrentVSHistorical/ptsDif_current.xlsx', sheet_name = '2020-21')
ptsDif_current = pd.DataFrame(raw_data, columns = ['Team', 'G', 'PT DIFF'])

list_team = ptsDif_current['Team'].tolist()
list_games = ptsDif_current['G'].tolist()
list_ptdiff = ptsDif_current['PT DIFF'].tolist()

start_year = 1970
end_year = 2019
greater_or_lesser = 'within'
plot_flag = 0

# initialize dictionary
dict_of_df = {} 

for idx in ptsDif_current.index:

	print(list_team[idx] + ':\n')

	dict_of_df['{}'.format(list_team[idx])] = CumVsFinal_func.create_ptsDif_CumVsRecord_df(start_year,
  		end_year,
	  	list_ptdiff[idx],
	  	list_games[idx],
	  	greater_or_lesser,
	  	plot_flag)

	print('\n')

print('--- %s seconds ---' % (time.time() - start_time))