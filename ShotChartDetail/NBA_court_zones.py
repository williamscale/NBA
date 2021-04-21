import matplotlib.pyplot as plt
import math
from matplotlib.patches import Circle, Rectangle, Arc

def draw_NBA_court(color, lw, zones_flag, ax = None):

	if ax is None:
		ax = plt.gca()

	factor =  5 / 6
	hoop_center = [0, 0]
	hoop_rad = 9

	# hoop is origin for nba api coordinates, diameter is 18 inches
	hoop = Circle((hoop_center[0] * factor, hoop_center[1] * factor),
		radius = hoop_rad * factor,
		linewidth = lw,
		color = color,
		fill = False)

	# 6 feet wide, 6 inches behind hoop
	backboard_length = 6 * 12 
	backboard_y = hoop_center[1] - hoop_rad - 6
	backboard = plt.hlines(y = backboard_y * factor,
		xmin = -backboard_length / 2 * factor,
		xmax = backboard_length / 2 * factor,
		linewidth = lw,
		color = color)

	# 50 feet wide, 4 feet behind backboard
	baseline_width = 50 * 12
	baseline_y = backboard_y - 4 * 12
	baseline = plt.hlines(y = baseline_y * factor,
		xmin = -baseline_width / 2 * factor,
		xmax = baseline_width / 2 * factor,
		linewidth = lw,
		color = color)

	# 94 feet long
	court_length = 94 * 12
	halfcourt_y = court_length / 2 + baseline_y

	sideline_left = plt.vlines(x = -baseline_width / 2 * factor,
		ymin = baseline_y * factor,
		ymax = halfcourt_y * factor,
		linewidth = lw,
		color = color)

	sideline_right = plt.vlines(x = baseline_width / 2 * factor,
		ymin = baseline_y * factor,
		ymax = halfcourt_y * factor,
		linewidth = lw,
		color = color)

	halfcourt = plt.hlines(y = halfcourt_y * factor,
		xmin = -baseline_width / 2 * factor,
		xmax = baseline_width / 2 * factor,
		linewidth = lw,
		color = color)

	# 16 feet wide, 19 feet long
	paint_width = 16 * 12
	paint_length = 19 * 12
	paint = Rectangle((-paint_width / 2 * factor, baseline_y * factor),
		width = paint_width * factor,
		height = paint_length * factor,
		linewidth = lw,
		color = color,
		fill = False) 

	# 6 feet radius
	freethrow_circle_rad = 6 * 12
	freethrow_circle = Circle((hoop_center[0], (paint_length - abs(baseline_y)) * factor),
		radius = freethrow_circle_rad * factor,
		linewidth = lw,
		color = color,
		fill = False)

	# 23 feet 9 inches, 22 feet from hoop for arc and corner
	three_dist = 23 * 12 + 9
	corner3_dist = 22 * 12

	corner3_abovehoop = math.sqrt(three_dist ** 2 - corner3_dist ** 2)
	corner3_length = corner3_abovehoop + abs(baseline_y)
	theta_rad = math.atan2(corner3_abovehoop, corner3_dist)
	theta_deg = math.degrees(theta_rad)

	three_arc = Arc((hoop_center[0] * factor, hoop_center[1] * factor),
		width = three_dist * 2 * factor,
		height = three_dist * 2 * factor,
		angle = 0,
		theta1 = theta_deg,
		theta2 = 180 - theta_deg,
		linewidth = lw,
		color = color)

	corner3_left = plt.vlines(x = -corner3_dist * factor,
		ymin = baseline_y * factor,
		ymax = (corner3_length + baseline_y) * factor,
		linewidth = lw,
		color = color)

	corner3_left = plt.vlines(x = corner3_dist * factor,
		ymin = baseline_y * factor,
		ymax = (corner3_length + baseline_y) * factor,
		linewidth = lw,
		color = color)

	# 4 feet radius
	restricted_rad = 4 * 12
	restricted_arc = Arc((hoop_center[0] * factor, hoop_center[1] * factor),
		width = restricted_rad * 2 * factor,
		height = restricted_rad * 2 * factor, 
		angle = 0,
		theta1 = 0, 
		theta2 = 180,
		linewidth = lw,
		color = color)

	restricted_left = plt.vlines(x = (hoop_center[0] - restricted_rad) * factor,
		ymin = backboard_y * factor,
		ymax = hoop_center[1] * factor,
		linewidth = lw,
		color = color)

	restricted_right = plt.vlines(x = (hoop_center[0] + restricted_rad) * factor,
		ymin = backboard_y * factor,
		ymax = hoop_center[1] * factor,
		linewidth = lw,
		color = color)

	# 6 feet radius
	halfcourt_outer_rad = 6 * 12
	halfcourt_outer = Arc((hoop_center[0] * factor, halfcourt_y * factor),
		width = halfcourt_outer_rad * 2 * factor,
		height = halfcourt_outer_rad * 2 * factor,
		angle = 0,
		theta1 = 180,
		theta2 = 0,
		linewidth = lw,
		color = color)

	# 2 feet radius
	halfcourt_inner_rad = 2 * 12
	halfcourt_inner = Arc((hoop_center[0] * factor, halfcourt_y * factor),
		width = halfcourt_inner_rad * 2 * factor,
		height = halfcourt_inner_rad * 2 * factor,
		angle = 0,
		theta1 = 180,
		theta2 = 0,
		linewidth = lw,
		color = color)
	
	corner3_left_bounds = [-baseline_width / 2 * factor,
		baseline_y * factor,
		-corner3_dist * factor,
		(corner3_length + baseline_y) * factor] 

	
	corner3_left_zone = Rectangle((corner3_left_bounds[0],
		corner3_left_bounds[1]),
		corner3_left_bounds[2] - corner3_left_bounds[0],
		corner3_left_bounds[3] - corner3_left_bounds[1],
		alpha = 0.4)

	# list of patches
	court_list = [hoop, paint, freethrow_circle, three_arc, restricted_arc, halfcourt_outer, halfcourt_inner]

	if zones_flag == 0:

		for line in court_list:

			ax.add_patch(line)

	elif zones_flag == 1:
		
		# corner 3 zones
		corner3_left_bounds = [-baseline_width / 2 * factor,
			baseline_y * factor,
			-corner3_dist * factor,
			(corner3_length + baseline_y) * factor] 

		corner3_left_zone = Rectangle((corner3_left_bounds[0],
			corner3_left_bounds[1]),
			width = corner3_left_bounds[2] - corner3_left_bounds[0],
			height = corner3_left_bounds[3] - corner3_left_bounds[1],
			color = 'green',
			alpha = 0.4)

		corner3_right_bounds = [baseline_width / 2 * factor,
			baseline_y * factor,
			corner3_dist * factor,
			(corner3_length + baseline_y) * factor]

		corner3_right_zone = Rectangle((corner3_right_bounds[0],
			corner3_right_bounds[1]),
			width = corner3_right_bounds[2] - corner3_right_bounds[0],
			height = corner3_right_bounds[3] - corner3_right_bounds[1],
			color = 'green',
			alpha = 0.4)

		# top 3 zone(s)
		above_corner_region = Rectangle((corner3_left_bounds[0],
			corner3_left_bounds[3]),
			width = baseline_width * factor,
			height = halfcourt_y * factor - corner3_left_bounds[3],
			color = 'black',
			alpha = 0.4)

		zones_list = [corner3_left_zone, corner3_right_zone, above_corner_region]

		court_zones_list = court_list + zones_list

		for item in court_zones_list:

			ax.add_patch(item)

	# include area outside of boundaries
	x_min = (-baseline_width / 2) * factor
	x_max = (baseline_width / 2) * factor
	y_min = baseline_y * factor
	y_max = halfcourt_y * factor

	ax.set_aspect('equal')

	# Reduce plot size to court size
	plt.xlim(x_min - 10, x_max + 10)
	plt.ylim(y_min - 10, y_max + 10)

	#plt.show()

	return ax, x_min, x_max, y_min, y_max

if __name__ == '__main__':

	color = 'black'
	lw = 2
	zones_flag = 1

	court = draw_NBA_court(color, lw, zones_flag)
