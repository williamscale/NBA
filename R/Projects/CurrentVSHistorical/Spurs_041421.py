import os 
import sys

# file_dir = os.path.dirname(os.path.abspath(__file__))
# sys.path.append(os.path.join(file_dir, '..', '..', 'GameLogs'))

import CumVsFinal_func

start_year = 1970	
end_year = 2019
ptsDif = -65
games = 53
record = '26-27'
greater_or_lesser = 'within'

print('\nBY POINT DIFFERENTIAL:\n')
ptsDif_df = CumVsFinal_func.create_ptsDif_CumVsRecord_df(start_year, end_year, ptsDif, games, greater_or_lesser, plot_flag = 1)

print('\n\nBY RECORD:\n')
records_df = CumVsFinal_func.create_record_CumVsFinal_df(start_year, end_year, record)