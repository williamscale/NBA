import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import RegularPolygon

def add_legend_shotchart(ax, hex_rad = 20, hex_y = 400, hex_x_shift = 125, cmap_list = ['steelblue', 'lightblue', 'grey', 'orange', 'red']):

	hex_centers_eff = [[-2 * hex_rad + hex_x_shift, hex_y], [-hex_rad + hex_x_shift, hex_y], [hex_x_shift, hex_y], [hex_rad + hex_x_shift, hex_y], [2 * hex_rad + hex_x_shift, hex_y]]

	for center in range(0, len(hex_centers_eff)):

		hex_eff = RegularPolygon((hex_centers_eff[center][0], hex_centers_eff[center][1]), numVertices = 6, radius = np.sqrt(hex_rad ** 2 / 3), color = cmap_list[center])
		ax.add_patch(hex_eff)

	labels_eff = ['Below\nAverage', 'FG%', 'Above\nAverage']
	labels_eff_loc = [[hex_centers_eff[0][0] - np.sqrt(hex_rad ** 2 / 3), hex_centers_eff[0][1]], [hex_centers_eff[2][0], hex_centers_eff[2][1] - hex_rad], [hex_centers_eff[4][0] + np.sqrt(hex_rad ** 2 / 3), hex_centers_eff[4][1]]]

	ax.text(x = labels_eff_loc[0][0],
		y = labels_eff_loc[0][1],
		s = labels_eff[0],
		fontsize = 8,
		c = 'white',
		ha = 'right',
		va = 'center')

	ax.text(x = labels_eff_loc[1][0],
		y = labels_eff_loc[1][1],
		s = labels_eff[1],
		fontsize = 12,
		c = 'white',
		ha = 'center',
		va = 'center',
		weight = 'bold')

	ax.text(x = labels_eff_loc[2][0],
		y = labels_eff_loc[2][1],
		s = labels_eff[2],
		fontsize = 8,
		c = 'white',
		ha = 'left',
		va = 'center')


	hex_centers_freq = [[-2 * hex_rad - hex_x_shift, hex_y], [-1.2 * hex_rad - hex_x_shift, hex_y], [0 - hex_x_shift, hex_y]]
	hex_rad_freq = [hex_rad / 5, hex_rad / 3, hex_rad / 2]

	for center in range(0, len(hex_centers_freq)):

		hex_freq = RegularPolygon((hex_centers_freq[center][0], hex_centers_eff[center][1]), numVertices = 6, radius = hex_rad_freq[center], color = cmap_list[2])
		ax.add_patch(hex_freq)

	labels_freq = ['Lower', 'Frequency', 'Higher']
	labels_freq_loc = [[hex_centers_freq[0][0] - np.sqrt((hex_rad / 2) ** 2 / 3), hex_centers_freq[0][1]], [hex_centers_freq[1][0], hex_centers_freq[1][1] - hex_rad], [hex_centers_freq[2][0] + np.sqrt(hex_rad ** 2 / 3), hex_centers_freq[2][1]]]

	ax.text(x = labels_freq_loc[0][0],
		y = labels_freq_loc[0][1],
		s = labels_freq[0],
		fontsize = 8,
		c = 'white',
		ha = 'right',
		va = 'center')

	ax.text(x = labels_freq_loc[1][0],
		y = labels_freq_loc[1][1],
		s = labels_freq[1],
		fontsize = 12,
		c = 'white',
		ha = 'center',
		va = 'center',
		weight = 'bold')

	ax.text(x = labels_freq_loc[2][0],
		y = labels_freq_loc[2][1],
		s = labels_freq[2],
		fontsize = 8,
		c = 'white',
		ha = 'left',
		va = 'center')


