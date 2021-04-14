import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
import time
from CommonAllPlayers_func import get_playerid
from CommonPlayerInfo_func import get_height
import pickle
import random

plt.style.use('dark_background')
#plt.style.use('Solarize_Light2')

corner3_df = pd.read_pickle(r'C:/Users/caler/Documents/MyProjects/NBA/Pickles/corner3_leaders_01to21.pkl')

# remove 2021 from corner3_df
corner3_df = corner3_df[corner3_df['YEAR'] != '2020-21']

# create list of unique player names
player_list = corner3_df['PLAYER'].unique().tolist()

# # create list of player ids
# playerid_list = get_playerid(player_list)

playerid_list_pkl = 'C:/Users/caler/Documents/MyProjects/NBA/Pickles/playerid_list.pkl'

open_file = open(playerid_list_pkl, 'rb')
# pickle.dump(playerid_list, open_file)
# open_file.close()

playerid_list = pickle.load(open_file)

# height_list = []

# for playerid in playerid_list:

# 	print(playerid)

# 	height_list.append(get_height(playerid)[0])

height_list_pkl = 'C:/Users/caler/Documents/MyProjects/NBA/Pickles/height_list.pkl'

open_file1 = open(height_list_pkl, 'rb')
# pickle.dump(height_list, open_file1)
# open_file.close()

height_list = pickle.load(open_file1)

# hard code in missing heights
height_list[186] = '6-2'
height_list[220] = '6-7'
height_list[318] = '6-7'
height_list[339] = '6-6'
height_list[469] = '6-3'
height_list[489] = '6-0'
height_list[490] = '6-6'
height_list[565] = '6-4'
height_list[653] = '6-3'
height_list[702] = '6-3'
height_list[711] = '6-3'

height_inches = []

for i in range(0, len(height_list)):

	height_feet = height_list[i][0]

	height_length = len(height_list[i])
	height_inch_length = height_length - 2
	height_inch = height_list[i][height_length - height_inch_length:]

	height_inches.append(int(height_feet) * 12 + int(height_inch))

height_df = pd.DataFrame(list(zip(player_list, playerid_list, height_list, height_inches)),
	columns = ['Name', 'ID', 'Height', 'Height [inch]'])

corner3_player_list = corner3_df['PLAYER'].tolist()

player_idx = [player_list.index(i) for i in corner3_player_list]

height_repeat_list = []

for k in player_idx:

	height_repeat_list.append(height_inches[k])

corner3_df['Height'] = height_repeat_list
corner3_df['FG3M'] = corner3_df['RIGHT CORNER M'] + corner3_df['LEFT CORNER M'] + corner3_df['ABOVE BREAK M']
corner3_df['FG3M Corner'] = corner3_df['RIGHT CORNER M'] + corner3_df['LEFT CORNER M']
corner3_df['FG3A Corner'] = corner3_df['RIGHT CORNER A'] + corner3_df['LEFT CORNER A']

corner3_sum3mByheight_df = corner3_df.groupby(by = 'Height')['FG3M Corner'].sum()
corner3_sum3aByheight_df = corner3_df.groupby('Height')['FG3A Corner'].sum()
sum3aByheight_df = corner3_df.groupby('Height')['FG3A'].sum()
countByheight_df = corner3_df.groupby('Height')['PLAYER'].count()
# print(countByheight_df)

corner3_byHeight_df = pd.concat([countByheight_df, corner3_sum3mByheight_df, corner3_sum3aByheight_df, sum3aByheight_df], axis = 1)
corner3_byHeight_df.rename(columns = {'PLAYER': 'PLAYER SEASONS'}, inplace = True)

corner3_byHeight_df['FG3% Corner'] = corner3_byHeight_df['FG3M Corner'] / corner3_byHeight_df['FG3A Corner']
corner3_byHeight_df['%3PA Corner'] = corner3_byHeight_df['FG3A Corner'] / corner3_byHeight_df['FG3A']
corner3_byHeight_df['FG3A Corner per Player Season'] = corner3_byHeight_df['FG3A Corner'] / corner3_byHeight_df['PLAYER SEASONS']
corner3_byHeight_df['FG3A per Player Season'] = corner3_byHeight_df['FG3A'] / corner3_byHeight_df['PLAYER SEASONS']


# binned by height
corner3_byHeightBin_df = corner3_byHeight_df.groupby(pd.cut(corner3_byHeight_df.index, np.array([64, 72, 74, 76, 78, 80, 82, 84, 87]))).sum()
corner3_byHeightBin_df.drop(['FG3% Corner', '%3PA Corner'], inplace = True, axis = 1)
corner3_byHeightBin_df['%3PA Corner'] = corner3_byHeightBin_df['FG3A Corner'] / corner3_byHeightBin_df['FG3A']

corner3_byHeight_df.reset_index(inplace = True, drop = False)

print('All: ', '\n\n', corner3_df, '\n\n')

corner3_minFG3M = corner3_df[corner3_df['FG3M Corner'] >= 20].copy()

# distance formula dimensions
# Corner 3PM
dist_corner3pm_max = corner3_minFG3M['FG3M Corner'].max()
dist_corner3pm_avg = corner3_minFG3M['FG3M Corner'].mean()
dist_corner3pm_std = corner3_minFG3M['FG3M Corner'].std()
# %3PA Corner
dist_corner3percA_max = corner3_minFG3M['%3PA CORNER'].max()
dist_corner3percA_avg = corner3_minFG3M['%3PA CORNER'].mean()
dist_corner3percA_std = corner3_minFG3M['%3PA CORNER'].std()
# Corner 3FG%
dist_corner3fgperc_max = corner3_minFG3M['FG% CORNER'].max()
dist_corner3fgperc_avg = corner3_minFG3M['FG% CORNER'].mean()
dist_corner3fgperc_std = corner3_minFG3M['FG% CORNER'].std()

corner3_minFG3M.drop(['RIGHT CORNER A', 'RIGHT CORNER M', 'LEFT CORNER A', 'LEFT CORNER M', 'ABOVE BREAK A', 'ABOVE BREAK M', 'FG3A', 'FG% ABOVE BREAK', 'Height', 'FG3M', 'FG3A Corner'], inplace = True, axis = 1)

corner3_minFG3M['Z, Corner 3PM'] = (corner3_minFG3M['FG3M Corner'] - dist_corner3pm_avg) / dist_corner3pm_std
corner3_minFG3M['Z, %3PA Corner'] = (corner3_minFG3M['%3PA CORNER'] - dist_corner3percA_avg) / dist_corner3percA_std
corner3_minFG3M['Z, Corner 3FG%'] = (corner3_minFG3M['FG% CORNER'] - dist_corner3fgperc_avg) / dist_corner3fgperc_std
corner3_minFG3M['Distance'] = corner3_minFG3M['Z, Corner 3PM'] + corner3_minFG3M['Z, %3PA Corner'] + corner3_minFG3M['Z, Corner 3FG%']

corner3_minFG3M.sort_values(by = ['Distance'], inplace = True, ascending = False)
print('FG3M Corner >= 20, Top 20 by Distance: ', '\n\n', corner3_minFG3M.head(20), '\n\n')

corner3_minFG3M_top10 = corner3_minFG3M[0:10]

print(corner3_minFG3M_top10)

corner3_df_F1 = corner3_df[corner3_df['%3PA CORNER'] >= 0.5]
# print('%3PA Corner >= 50%:', '\n\n', corner3_df_F1, '\n\n')

corner3_df_F2 = corner3_df_F1[corner3_df_F1['FG% CORNER'] >= 0.40]
# print('%3PA Corner >= 50% AND FG% Corner >= 40%:', '\n\n', corner3_df_F2, '\n\n')

corner3_df_F3 = corner3_df_F2[corner3_df_F2.groupby('PLAYER')['PLAYER'].transform(len) > 1]
# corner3_df_F3.sort_values(by = ['FG3M Corner'], inplace = True, ascending = False)
# print('Appearing > 1:', '\n\n', corner3_df_F3, '\n\n')

# notable players
bowenb = corner3_df_F3[corner3_df_F3['PLAYER'] == 'Bruce Bowen']
johnsonj = corner3_df_F3[corner3_df_F3['PLAYER'] == 'Joe Johnson']
parkera = corner3_df_F3[corner3_df_F3['PLAYER'] == 'Anthony Parker']
battiers = corner3_df_F3[corner3_df_F3['PLAYER'] == 'Shane Battier']

# top 3 in each category
# print('Top 5 Corner 3s Made: ', '\n', corner3_df_F3.nlargest(5, 'FG3M Corner'), '\n\n')
# print('Top 5 %3PA Corner: ', '\n', corner3_df_F3.nlargest(5, '%3PA CORNER'), '\n\n')
# print('Top 5 FG% Corner 3: ', '\n', corner3_df_F3.nlargest(5, 'FG% CORNER'), '\n\n')

fig1, ax1 = plt.subplots()
fig2, ax2 = plt.subplots()
fig3, ax3 = plt.subplots()
fig4, ax4 = plt.subplots()
fig5, ax5 = plt.subplots()
fig6, ax6 = plt.subplots()
fig7, ax7 = plt.subplots()

ax1.text(x = 0.7,
		y = 500,
		s = '\u0040cale_williams',
		color = 'white',
		fontstyle = 'italic'
		)

F1_x = 0.5
F2_y = 0.4

ax1.hist(x = corner3_minFG3M['%3PA CORNER'],
	bins = 20,
	#density = True,
	color = 'teal',
	alpha = 0.8,
	)

# ax1.axvline(x = F1_x, color = 'goldenrod', linestyle = 'dashed', linewidth = 2)

ax1.set_xlabel('Percent of 3PA from the Corner')
ax1.set_ylabel('Player Seasons')

ax2.scatter(x = corner3_df['Height'],
	y = corner3_df['%3PA CORNER'],
	s = 10,
	color = 'teal')

ax2.set_xlabel('Height [in]')
ax2.set_ylabel('Percent of 3PA from the Corner')
ax2.set_title('Title')

ax3.bar(x = ['<= 6ft', '<= 6ft 2in', '<= 6ft 4in', '<= 6ft 6in', '<= 6ft 8in', '<= 6ft 10in', '<= 7ft', '> 7ft'],
	height = corner3_byHeightBin_df['%3PA Corner'],
	color = 'teal')

ax3.set_xlabel('Percent of 3PA from the Corner')
ax3.set_ylabel('Player Seasons')
ax3.set_title('Corner 3PAs as Percent of Total 3PAs')

ax4.scatter(x = corner3_byHeight_df['Height'][4:16],
	y = corner3_byHeight_df['%3PA Corner'][4:16],
	color = 'teal',
	marker = '.',
	s = corner3_byHeight_df['PLAYER SEASONS'][4:16] * 2,
	alpha = 0.8)

ax4.plot(corner3_byHeight_df['Height'][4:16],
	corner3_byHeight_df['%3PA Corner'][4:16],
	color = 'teal')

ax4.set_xlabel('Height')
ax4.set_ylabel('Corner FG3A per Player Season')
ax4.set_title('Title')

ax5.scatter(x = corner3_df_F1['%3PA CORNER'],
	y = corner3_df_F1['FG% CORNER'],
	s = 10,
	color = 'goldenrod')

ax5.axhline(y = F2_y, color = 'teal', linestyle = 'dashed', linewidth = 2)

ax5.set_xlabel('Percent of 3PA from the Corner')
ax5.set_ylabel('Corner 3 FG%')

ax5.text(x = 0.84,
		y = 0.54,
		s = '\u0040cale_williams',
		color = 'white',
		fontstyle = 'italic'
		)

ax6.scatter(x = corner3_minFG3M['%3PA CORNER'],
	y = corner3_minFG3M['FG% CORNER'],
	color = 'teal',
	alpha = 0.5,
	s = corner3_minFG3M['FG3M Corner'] * 5)

ax6.scatter(x = corner3_minFG3M_top10['%3PA CORNER'],
	y = corner3_minFG3M_top10['FG% CORNER'],
	color = 'goldenrod',
	alpha = 0.8,
	s = corner3_minFG3M_top10['FG3M Corner'] * 5)

ax6.scatter(x = [0.8, 0.818, 0.84],
	y = [0, 0, 0],
	color = 'teal',
	alpha = 0.5,
	s = [100, 200, 300])

ax6.axvline(x = dist_corner3percA_avg, color = 'firebrick', linestyle = 'dashed', linewidth = 2)
ax6.axhline(y = dist_corner3fgperc_avg, color = 'firebrick', linestyle = 'dashed', linewidth = 2)

ax6.set_xlabel(r'% of FG3A from the Corner')
ax6.set_ylabel('Corner 3 FG%')

ax6.text(x = 0.88,
		y = 0.7,
		s = '\u0040cale_williams',
		color = 'white',
		fontstyle = 'italic'
		)

ax6.text(x = 0.05,
		y = 0.7,
		s = 'few corner 3PA relative to total 3PA',
		color = 'firebrick',
		)

ax6.text(x = 0.05,
		y = 0,
		s = 'few corner 3PA relative to total 3PA \n & lower efficiency',
		color = 'firebrick',
		)

ax6.text(x = 0.55,
		y = 0.01,
		s = 'lower efficiency',
		color = 'firebrick',
		)

ax6.text(x = 0.75,
		y = -0.01,
		s = 'fewer',
		color = 'teal',
		)

ax6.text(x = 0.86,
		y = -0.01,
		s = 'more',
		color = 'teal',
		)

ax6.text(x = 0.73,
		y = 0.03,
		s = 'Corner 3s Made',
		color = 'teal',
		fontsize = 20
		)

ax7.scatter(x = corner3_df_F3['%3PA CORNER'],
	y = corner3_df_F3['FG% CORNER'],
	color = 'gray',
	alpha = 0.5,
	s = corner3_df_F3['FG3M Corner'] * 5)

ax7.scatter(x = bowenb['%3PA CORNER'],
	y = bowenb['FG% CORNER'],
	color = 'darkorange',
	alpha = 0.8,
	s = bowenb['FG3M Corner'] * 5)

ax7.scatter(x = johnsonj['%3PA CORNER'],
	y = johnsonj['FG% CORNER'],
	color = 'seagreen',
	alpha = 0.8,
	s = johnsonj['FG3M Corner'] * 5)

ax7.scatter(x = parkera['%3PA CORNER'],
	y = parkera['FG% CORNER'],
	color = 'cornflowerblue',
	alpha = 0.8,
	s = parkera['FG3M Corner'] * 5)

ax7.scatter(x = battiers['%3PA CORNER'],
	y = battiers['FG% CORNER'],
	color = 'violet',
	alpha = 0.8,
	s = battiers['FG3M Corner'] * 5)

plt.show()