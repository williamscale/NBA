def create_yearRange_list(start_year, end_year):

	season_range_int_1 = list(range(start_year - 1, end_year))
	season_range_int_2 = [season + 1 for season in season_range_int_1]

	season_range_str_1 = [str(season) for season in season_range_int_1] 
	season_range_str_2 = [str(season) for season in season_range_int_2]

	season_range_str_1 = [season + '-' for season in season_range_str_1]
	season_range_str_2 = [century[2:] for century in season_range_str_2]

	season_range_list = [i + j for i, j in zip(season_range_str_1, season_range_str_2)] 

	return season_range_list

def create_yearRange_2YYYY_list(start_year, end_year):

	season_range_int_1 = list(range(start_year - 1, end_year))

	season_range_str_1 = [str(season) for season in season_range_int_1] 

	season_range_list = ['2' + season for season in season_range_str_1]

	return season_range_list

if __name__ == '__main__':
	start_year = 2005
	end_year = 2011
	x = create_yearRange_2YYYY_list(start_year, end_year)
	print(x)