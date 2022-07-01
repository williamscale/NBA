import os
import sys
import requests
import time
import json
import math

# third-party imports
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Rectangle, Arc
import seaborn as sns
from scipy import stats
from tabulate import tabulate
from nba_api.stats.endpoints import commonplayerinfo as cpi, shotchartdetail

import CommonAllPlayers_Func

import shots_player

ids, names = CommonAllPlayers_Func.create_currentplayers_lists()
names = [[name] for name in names]

for i in range(0, len(names)):
	print(names[i])
	shots_player.player_shotchart(names[i], '2021-22', 'FGA', 'PlayIn', 0)