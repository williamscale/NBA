import gamelog_cumulative
import pandas as pd

def create_ptsDif_series(ptsDif_input, game_count, year_input, greater_or_lesser):

	# output dataframe
	ptsDifCum_df = gamelog_cumulative.create_gamelogCum_df(year_input, 'Points Differential', plot_flag = 0, savefig_flag = 0)

	# get just gamelog data up to specified number of games
	ptsDif_gameCount = ptsDifCum_df.iloc[game_count - 1]

	# drop rows in which point differential is not wanted and create new df
	if greater_or_lesser == 'greater':

		ptsDif_gameCount_cond = ptsDif_gameCount.drop(ptsDif_gameCount[ptsDif_gameCount < ptsDif_input].index)

	elif greater_or_lesser == 'lesser':

		ptsDif_gameCount_cond = ptsDif_gameCount.drop(ptsDif_gameCount[ptsDif_gameCount > ptsDif_input].index)

	elif greater_or_lesser == 'equal':

		ptsDif_gameCount_cond = ptsDif_gameCount.drop(ptsDif_gameCount[ptsDif_gameCount != ptsDif_input].index)

	elif greater_or_lesser == 'within':

		not_within_idx = ptsDif_gameCount[(ptsDif_gameCount < ptsDif_input - 5) | 
			(ptsDif_gameCount > ptsDif_input + 5)]

		ptsDif_gameCount_cond = ptsDif_gameCount.drop(not_within_idx.index)

	else: 

		print('Improper greater/lesser input. Input either "greater", "lesser", or "equal" (case-sensitive).')

	return ptsDif_gameCount_cond

if __name__ == '__main__':

	ptsDif_input = -65
	game_count = 53
	year_input = '2018-19'
	greater_or_lesser = 'within'
	x = create_ptsDif_series(ptsDif_input, game_count, year_input, greater_or_lesser)
	print(x)