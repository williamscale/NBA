import gamelog_cumulative
import pandas as pd
import year_range_func

def create_finalrecord_df(start_year, end_year):

	# create list of years
	year_range = year_range_func.create_yearRange_list(start_year, end_year)

	# initialize dataframe
	record_df = pd.DataFrame()

	# loop through list of years
	for year in year_range:

		# create df with cumulative records
		new_finalrecord = gamelog_cumulative.create_gamelogCum_df(year, 'Record')

		# add column with year
		new_finalrecord['Year'] = year

		# add to df
		record_df = pd.concat([record_df, new_finalrecord], sort = True)

	# make last row (final record) of each year into df	
	finalrecord_df = record_df.groupby('Year').tail(1)

	# rearrange
	finalrecord_df = finalrecord_df.set_index('Year')
	finalrecord_df = finalrecord_df.transpose()
	finalrecord_df.reset_index(drop = False, inplace = True)
	finalrecord_df = finalrecord_df.rename_axis(None, axis = 1)
	finalrecord_df = finalrecord_df.rename(columns = {'index':'Team'}, inplace = False)

	return finalrecord_df

if __name__ == '__main__':
	start_year = 2011
	end_year = 2019
	x = create_finalrecord_df(start_year, end_year)
	print(x)