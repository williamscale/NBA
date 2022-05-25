# Summarize corner 3 data.
# Author: Cale Williams
# Last Updated: 05/25/2022

# Import packages.
import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
import time
import pickle
import random
import os
import sys

# Import local packages.
file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(file_dir, '..', '..', 'Scrapers'))
from CommonAllPlayers_Func import get_playerid

# Set plot style.
plt.style.use('dark_background')

# corner3_df = pd.read_pickle(r'C:/Users/caler/Documents/MyProjects/NBA/R/Projects/Corner3/corner3_leaders_01to21.pkl')
# Initialize dataframe.
corner3_df = pd.DataFrame()

# Create list of pickled files to read.
files = ['data/corner3_leaders_2001.pkl', 'data/corner3_leaders_2002.pkl',
'data/corner3_leaders_2003.pkl', 'data/corner3_leaders_2004.pkl',
'data/corner3_leaders_2005.pkl', 'data/corner3_leaders_2006.pkl',
'data/corner3_leaders_2007.pkl', 'data/corner3_leaders_2008.pkl',
'data/corner3_leaders_2009.pkl', 'data/corner3_leaders_2010.pkl',
'data/corner3_leaders_2011.pkl', 'data/corner3_leaders_2012.pkl',
'data/corner3_leaders_2013.pkl', 'data/corner3_leaders_2014.pkl',
'data/corner3_leaders_2015.pkl', 'data/corner3_leaders_2016.pkl',
'data/corner3_leaders_2017.pkl', 'data/corner3_leaders_2018.pkl',
'data/corner3_leaders_2019.pkl', 'data/corner3_leaders_2020.pkl',
'data/corner3_leaders_2021.pkl']

# For each file...
for i in files:

	# Read and add to dataframe.
	corner3_df = pd.concat([corner3_df, pd.read_pickle(i)])

# Remove 2021 because season is not complete.
corner3_df = corner3_df[corner3_df['YEAR'] != '2020-21']

# Create list of unique player names.
player_list = corner3_df['PLAYER'].unique().tolist()

# Import player ids.
playerid_list_pkl = 'C:/Users/caler/Documents/MyProjects/NBA/R/Projects/Corner3/data/playerid_list.pkl'
open_file = open(playerid_list_pkl, 'rb')
playerid_list = pickle.load(open_file)


corner3_player_list = corner3_df['PLAYER'].tolist()

player_idx = [player_list.index(i) for i in corner3_player_list]

# Summarize FG3.
corner3_df['FG3M'] = corner3_df['RIGHT CORNER M'] + corner3_df['LEFT CORNER M'] + corner3_df['ABOVE BREAK M']
corner3_df['FG3M Corner'] = corner3_df['RIGHT CORNER M'] + corner3_df['LEFT CORNER M']
corner3_df['FG3A Corner'] = corner3_df['RIGHT CORNER A'] + corner3_df['LEFT CORNER A']

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

corner3_minFG3M.drop(['RIGHT CORNER A', 'RIGHT CORNER M', 'LEFT CORNER A',
	'LEFT CORNER M', 'ABOVE BREAK A', 'ABOVE BREAK M', 'FG3A',
	'FG% ABOVE BREAK', 'FG3M', 'FG3A Corner'],
	inplace = True,
	axis = 1)

corner3_minFG3M['Z, Corner 3PM'] = (corner3_minFG3M['FG3M Corner'] - dist_corner3pm_avg) / dist_corner3pm_std
corner3_minFG3M['Z, %3PA Corner'] = (corner3_minFG3M['%3PA CORNER'] - dist_corner3percA_avg) / dist_corner3percA_std
corner3_minFG3M['Z, Corner 3FG%'] = (corner3_minFG3M['FG% CORNER'] - dist_corner3fgperc_avg) / dist_corner3fgperc_std
corner3_minFG3M['Distance'] = corner3_minFG3M['Z, Corner 3PM'] + corner3_minFG3M['Z, %3PA Corner'] + corner3_minFG3M['Z, Corner 3FG%']

corner3_minFG3M.sort_values(by = ['Distance'],
	inplace = True,
	ascending = False)
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