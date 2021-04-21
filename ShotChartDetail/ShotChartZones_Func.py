def create_dict_shotzones_df(make_df, miss_df):

	make_corner3right = make_df.loc[make_df['SHOT_ZONE_BASIC'] == 'Right Corner 3']
	make_corner3left = make_df.loc[make_df['SHOT_ZONE_BASIC'] == 'Left Corner 3']
	make_abovebreak3 = make_df.loc[make_df['SHOT_ZONE_BASIC'] == 'Above the Break 3']
	make_midrange = make_df.loc[make_df['SHOT_ZONE_BASIC'] == 'Mid-Range']
	make_paint = make_df.loc[make_df['SHOT_ZONE_BASIC'] == 'In The Paint (Non-RA)']
	make_ra = make_df.loc[make_df['SHOT_ZONE_BASIC'] == 'Restricted Area']

	make_dict = {
		'Right Corner 3': make_corner3right,
		'Left Corner 3': make_corner3left,
		'Above the Break 3': make_abovebreak3,
		'Mid-Range': make_midrange,
		'In The Paint (Non-RA)': make_paint,
		'Restricted Area': make_ra
		}

	miss_corner3right = miss_df.loc[miss_df['SHOT_ZONE_BASIC'] == 'Right Corner 3']
	miss_corner3left = miss_df.loc[miss_df['SHOT_ZONE_BASIC'] == 'Left Corner 3']
	miss_abovebreak3 = miss_df.loc[miss_df['SHOT_ZONE_BASIC'] == 'Above the Break 3']
	miss_midrange = miss_df.loc[miss_df['SHOT_ZONE_BASIC'] == 'Mid-Range']
	miss_paint = miss_df.loc[miss_df['SHOT_ZONE_BASIC'] == 'In The Paint (Non-RA)']
	miss_ra = miss_df.loc[miss_df['SHOT_ZONE_BASIC'] == 'Restricted Area']

	miss_dict = {
		'Right Corner 3': miss_corner3right,
		'Left Corner 3': miss_corner3left,
		'Above the Break 3': miss_abovebreak3,
		'Mid-Range': miss_midrange,
		'In The Paint (Non-RA)': miss_paint,
		'Restricted Area': miss_ra
		}

	return make_dict, miss_dict