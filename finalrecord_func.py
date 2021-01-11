import gamelog_cumulative
import pandas as pd
import year_range_func

def create_finalrecord_df(start_year, end_year):

	year_range = year_range_func.create_yearRange_list(start_year, end_year)
	record_df = pd.DataFrame()

	for year in year_range:

		new_finalrecord = gamelog_cumulative.create_gamelogCum_df(year, 'Record')
		new_finalrecord['Year'] = year
		record_df = pd.concat([record_df, new_finalrecord], sort = True)

	finalrecord_df = record_df.groupby('Year').tail(1)
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