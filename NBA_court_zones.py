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
		theta2 = 180 - theta_deg)

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

	

	#halfcourt_outer = Arc((0, 422.5), 120, 120, theta1 = 180, theta2 = 0, linewidth = lw, color = color)
	#halfcourt_inner = Arc((0, 422.5), 40, 40, theta1 = 180, theta2 = 0, linewidth = lw, color = color)

	court_lines = [hoop, paint, freethrow_circle, three_arc]

	for line in court_lines:

		ax.add_patch(line)

	#if zones_flag == 1:

		#corner3_left_bounds = [-250, -47.5, -220, 92.5] 
		#corner3_right_bounds = [220, -47.5, 250, 92.5] 
		#wing3_left_bounds = [-250, 
		#paint_bounds = [-80, -47.5, 80, 142.5]
		#mid_low_left_bounds = []

		#corner3_left = Rectangle((corner3_left_bounds[0],
		#	corner3_left_bounds[1]),
		#	corner3_left_bounds[2] - corner3_left_bounds[0],
		#	corner3_left_bounds[3] - corner3_left_bounds[1],
		#	alpha = 0.4)

		#corner3_right = Rectangle((corner3_right_bounds[0],
		#	corner3_right_bounds[1]),
		#	corner3_right_bounds[2] - corner3_right_bounds[0],
		#	corner3_right_bounds[3] - corner3_right_bounds[1],
		#	alpha = 0.4)

		#paint_zone = Rectangle((paint_bounds[0],
		#	paint_bounds[1]),
		#	paint_bounds[2] - paint_bounds[0],
		#	paint_bounds[3] - paint_bounds[1],
		#	alpha = 0.4)

		#zones = [corner3_left, corner3_right, paint_zone]

		#for zone in zones:

		#	ax.add_patch(zone)

	x_min = (-baseline_width / 2) * factor - 10
	x_max = (baseline_width / 2) * factor + 10
	y_min = baseline_y * factor - 10
	y_max = halfcourt_y * factor + 10 

	ax.set_aspect('equal')

	# Reduce plot size to court size
	plt.xlim(x_min, x_max)
	plt.ylim(y_min, y_max)
	plt.show()

	return ax

if __name__ == '__main__':

	color = 'black'
	lw = 1
	zones_flag = 1

	court = draw_NBA_court(color, lw, zones_flag)
