extends Node

var file_name = "map.dat"
var init_array = []
var tile_array = []

var platform_type = "unknown"

var pdf = null
var pdf_sum = 0

var export_string = ""
var loaded_file = ""

var astar_grid = AStarGrid2D.new()
var pathfind_update_flag = 0
var path = null

var board_length = 0
var board_height = 0

var terrain_moved = 0
var cities_moved = 0
var trees_moved = 0

var trees_planted = 0

var water_array = []
var wrs = []

var selected_tile = "w"

var rng = RandomNumberGenerator.new()

var is_paused = false;

var is_editor = false;

var tick_counter = -1
# number of dice to roll per turn; negative numbers also spawn plants
var tick_array_default = [0, 1, 1, 1, 1, 2, -2, 2, 2, -2, 3, 3, -3, 3, 3, -3, 5]
var tick_array = null
var tick_start_r = 0

var mouse_tile_position = Vector2i(0,0)
var mouse_tile_hover = Vector2i(0,0)
var mouse_tile_selected = Vector2i(0,0)
var mouse_step = 0

var ap_start_c = 1
var ap_start_r = 1
var ap = 6
var cur_moves = []
var hover_move = null
var ap_craft_indicator = [null, null, null, null, null, null]

var waters_to_break = []
var pending_broken_waters = []
var temp_water_break_move = null

var game_ended = false
var historical_game_states = []
var view_tick = 0

func calculate_water_reach(col):
	var vol = water_array[col]
	var reach = 0
	var high_reach = 0
	while vol > 0:
		if high_reach >= board_height:
			break
		vol -= 1
		if reach < board_height and tile_array[reach][col] & 1 > 0:
			if high_reach <= reach:
				high_reach += 1
			else:
				reach += 2
		else:
			reach += 1
	return [reach, high_reach]

func get_flood_column():
	if pdf == null:
		if board_length == 11:
			return rng.randi_range(1, 6) + rng.randi_range(1, 6) - 2
		return rng.randi_range(0, board_length - 1)
	else:
		var x = rng.randi_range(1, pdf_sum)
		for i in pdf.size():
			if pdf[i] >= x:
				return i
			x -= pdf[i]

func count_surviving_cities():
	var city_count = 0
	for rd in tile_array:
		for cd in rd:
			if cd & 2 > 0:
				city_count += 1
	return city_count

func count_adjacent_water_tiles(r, c):
	waters_to_break = []
	if r > 0 and max(wrs[c][0], wrs[c][1]) - 1 >= r - 1:
		waters_to_break.append([r - 1, c])
	if r < board_height - 1 and max(wrs[c][0], wrs[c][1]) - 1 >= r + 1:
		waters_to_break.append([r + 1, c])
	if c > 0 and max(wrs[c - 1][0], wrs[c - 1][1]) - 1 >= r:
		waters_to_break.append([r, c - 1])
	if c < board_length - 1 and max(wrs[c + 1][0], wrs[c + 1][1]) - 1 >= r:
		waters_to_break.append([r, c + 1])

func view_historical_tick(tick):
	view_tick = tick
	tile_array = historical_game_states[tick][0]
	wrs = historical_game_states[tick][1]
	ap_craft_indicator = historical_game_states[tick][2]

func get_hover_ap_cost():
	if mouse_step == 0 or mouse_tile_hover.x >= board_length or mouse_tile_hover.y >= board_height:
		hover_move = null
		return Vector2i(0, 0)
	var move_cost = 1 if mouse_step == 4 else 2 if mouse_step == 1 else 3
	for c in cur_moves:
		if c[2] == mouse_tile_selected and c[4] == mouse_step:
			var dist = calculate_move_distance(c[3], mouse_tile_hover, mouse_step)
			hover_move = [move_cost, dist, mouse_tile_hover, c[3], mouse_step, 0]
			return Vector2i(dist * move_cost, c[0] * c[1])
	var dist = calculate_move_distance(mouse_tile_position, mouse_tile_hover, mouse_step)
	hover_move = [move_cost, dist, mouse_tile_hover, mouse_tile_position, mouse_step, 0]
	return Vector2i(dist * move_cost, 0)

func update_pathfinding_grid(s, by):
	if pathfind_update_flag != by:
		astar_grid.fill_solid_region(astar_grid.region, false)
		for c in board_length:
			var max_reach = max(wrs[c][0], wrs[c][1]) - 1
			for r in board_height:
				if s != Vector2i(c, r) and not (max_reach < r and init_array[r][c] > 0 and tile_array[r][c] & by == 0):
					var skip = false
					for m in cur_moves:
						if m[4] == by and m[3] == s and m[2] == Vector2i(c,r):
							skip = true # i miss gotos
					if skip:
						continue
					#print("impassable at ",r,", ",c)
					astar_grid.set_point_solid(Vector2i(c,r), true)
					#print(astar_grid.is_point_solid(Vector2i(c,r)))
		pathfind_update_flag = by

func calculate_move_distance(s, e, by):
	update_pathfinding_grid(s, by)
	path = astar_grid.get_id_path(s, e)
	return path.size() - 1

func try_do_move():
	var tile_val = tile_array[mouse_tile_position.y][mouse_tile_position.x]
	var max_reach = max(wrs[mouse_tile_position.x][0], wrs[mouse_tile_position.x][1]) - 1
	if max_reach < mouse_tile_position.y:
		var dist = calculate_move_distance(mouse_tile_selected, mouse_tile_position, mouse_step)
		var move_cost = 1 if mouse_step == 4 else 2 if mouse_step == 1 else 3

		for i in cur_moves.size():
			if cur_moves[i][2] == mouse_tile_selected and cur_moves[i][4] == mouse_step:
				dist = calculate_move_distance(cur_moves[i][3], mouse_tile_position, mouse_step)
				if ap + cur_moves[i][0] * cur_moves[i][1] - dist * move_cost < 0:
					mouse_step = 0
					return
				mouse_tile_selected = cur_moves[i][3]
				undo_move(i)
				break

		if ap - dist * move_cost < 0:
			mouse_step = 0
			return
		ap -= dist * move_cost

		var water_will_break = -1
		if mouse_step == 4:
			count_adjacent_water_tiles(mouse_tile_position.y, mouse_tile_position.x)
			if waters_to_break.size() == 1:
				var col = waters_to_break[0][1]
				print("breaking one water in ", col)
				water_array[col] -= 1
				wrs[col] = calculate_water_reach(col)
				water_will_break = pending_broken_waters.size()
				pending_broken_waters.append([mouse_tile_position.y, mouse_tile_position.x, waters_to_break[0][0], waters_to_break[0][1]])
				waters_to_break = []
			elif waters_to_break.size() > 0:
				temp_water_break_move = [move_cost, dist, mouse_tile_position, mouse_tile_selected, mouse_step, pending_broken_waters.size()]
				tile_array[mouse_tile_selected.y][mouse_tile_selected.x] &= ~mouse_step
				tile_array[mouse_tile_position.y][mouse_tile_position.x] |= mouse_step
				mouse_step = 0
				pathfind_update_flag = 0
				return
		if dist > 0:
			cur_moves.append([move_cost, dist, mouse_tile_position, mouse_tile_selected, mouse_step, water_will_break])
			tile_array[mouse_tile_selected.y][mouse_tile_selected.x] &= ~mouse_step
			tile_array[mouse_tile_position.y][mouse_tile_position.x] |= mouse_step
		mouse_step = 0
		pathfind_update_flag = 0

func get_next_tile_cycle(td, cur_step):
	match cur_step:
		0, 2 when td & 4 > 0:
			return 4
		0, 2 when td & 1 > 0:
			return 1
		0, 2:
			return 2
		4 when td & 1 > 0:
			return 1
		4 when td & 2 > 0:
			return 2
		4:
			return 4
		1 when td & 2 > 0:
			return 2
		1 when td & 4 > 0:
			return 4
		1:
			return 1

func cycleTile():
	var tile_val = tile_array[mouse_tile_position.y][mouse_tile_position.x]
	if tile_val == 0 and mouse_step == 0:
		return
	var max_reach = max(wrs[mouse_tile_position.x][0], wrs[mouse_tile_position.x][1]) - 1
	if max_reach >= mouse_tile_position.y:
		return
	if mouse_step == 0:
		mouse_tile_selected = mouse_tile_position
		mouse_step = get_next_tile_cycle(tile_val, mouse_step)
	elif mouse_tile_selected == mouse_tile_position:
		mouse_step = get_next_tile_cycle(tile_val, mouse_step)
	elif tile_val & mouse_step > 0:
		mouse_tile_selected = mouse_tile_position
		mouse_step = get_next_tile_cycle(tile_val, 0)
	elif init_array[mouse_tile_position.y][mouse_tile_position.x] > 0:
		try_do_move()

func process_water_break(r, c):
	water_array[c] -= 1
	wrs[c] = calculate_water_reach(c)

	pending_broken_waters.append([temp_water_break_move[2].y, temp_water_break_move[2].x, r, c])
	waters_to_break = []

	cur_moves.append(temp_water_break_move)
	temp_water_break_move = null

func is_tile_watterlogged(r, c):
	for wmv in pending_broken_waters:
		if wmv != null and wmv[0] == r and wmv[1] == c:
			return true
	return false

func undo_move(move_index):
	var res = cur_moves[move_index]
	if tile_array[res[3].y][res[3].x] & res[4] > 0:
		return
	cur_moves.pop_at(move_index)
	ap += res[0] * res[1]
	tile_array[res[2].y][res[2].x] &= ~res[4]
	tile_array[res[3].y][res[3].x] |= res[4]
	if res[5] >= 0:
		var col = pending_broken_waters[res[5]][3]
		water_array[col] += 1
		wrs[col] = calculate_water_reach(col)
		pending_broken_waters[res[5]] = null

		var max_reach = max(wrs[col][0], wrs[col][1]) - 1
		if max_reach < 0:
			pathfind_update_flag = 0
			return
		var check_tile = null
		if max_reach + 1 < board_height and tile_array[max_reach+1][col] & 4 > 0 and not is_tile_watterlogged(max_reach+1, col):
			check_tile = Vector2i(col, max_reach+1)
		elif col > 0 and tile_array[max_reach][col-1] & 4 > 0 and not is_tile_watterlogged(max_reach, col-1):
			check_tile = Vector2i(col-1, max_reach)
		elif col < board_length-1 and tile_array[max_reach][col+1] & 4 > 0 and not is_tile_watterlogged(max_reach, col+1):
			check_tile = Vector2i(col+1, max_reach)

		if check_tile:
			for i in cur_moves.size():
				cur_moves[i][5] = pending_broken_waters.size()
				var mov = cur_moves[i]
				if mov[2] == check_tile:
					count_adjacent_water_tiles(check_tile.y, check_tile.x)
					if waters_to_break.size() == 1:
						water_array[col] -= 1
						wrs[col] = calculate_water_reach(col)
						pending_broken_waters.append([mov[2].y, mov[2].x, waters_to_break[0][0], waters_to_break[0][1]])
						waters_to_break = []
					elif waters_to_break.size() > 0:
						temp_water_break_move = mov
						tile_array[mov[3].y][mov[3].x] &= ~mov[4]
						tile_array[mov[2].y][mov[2].x] |= mov[4]
		pathfind_update_flag = 0


func load_map():
	var web_load = false
	var fn = file_name if file_name.length() > 6 and file_name.substr(0,6) == "res://" else "res://Maps/" + file_name
	var f = FileAccess.open(fn, FileAccess.READ) if not web_load else null
	var mstring = AutoWebMap.map_a if web_load else ""
	tile_array = []
	init_array = []
	tick_array = tick_array_default.duplicate()
	var lines = mstring.split("\n")
	var i = 0
	while f.get_position() < f.get_length() if not web_load else lines.size() > i:
		var l = f.get_line() if not web_load else lines[i]
		i += 1
		if l.length() > 4 and l.substr(0, 4) == "pdf:":
			pdf = []
			pdf_sum = 0
			for v in l.substr(4).split(","):
				var n = v.strip_edges().to_int()
				pdf.append(n)
				pdf_sum += n
		elif l.length() > 4 and l.substr(0, 4) == "gea:":
			tick_array = []
			for v in l.substr(4).split(","):
				var n = v.strip_edges().to_int()
				tick_array.append(n)
		else:
			var id = []
			var td = []
			for c in l:
				match c:
					"l":
						id.append(1)
						td.append(0)
					"c":
						id.append(2)
						td.append(2)
					"w":
						id.append(0)
						td.append(0)
					"v":
						id.append(4)
						td.append(4)
					"t":
						id.append(3)
						td.append(1)
			init_array.append(id)
			tile_array.append(td)
	board_length = init_array[0].size()
	board_height = init_array.size()
	ap_start_c = board_length + 2
	ap_start_r = 0 if board_height <= 8 else 1
	tick_start_r = max(board_height, ap_start_r + 8)
	tick_counter = -1
	game_ended = false
	is_paused = false
	terrain_moved = 0
	cities_moved = 0
	trees_moved = 0
	trees_planted = 0

	get_window().size = Vector2i(max(board_length + 6, tick_array.size()), tick_start_r + 1) * Colors.TILE_SIZE

func fill_ap_craft_indicator():
	if game_ended:
		return
	ap_craft_indicator.fill(null)
	var local_moves = range(cur_moves.size())
	var ap_cost_info = Controller.get_hover_ap_cost()
	var ap_cost = ap_cost_info[0]
	var ap_already = ap_cost_info[1]
	if hover_move:
		local_moves.append(-1)
	if temp_water_break_move:
		local_moves.append(-2)
	local_moves.sort_custom(func(ia, ib):
		var a = hover_move if ia == -1 else temp_water_break_move if ia == -2 else cur_moves[ia]
		var b = hover_move if ib == -1 else temp_water_break_move if ib == -2 else cur_moves[ib]
		return a[0] > b[0] if a[0] != b[0] else a[1] > b[1])
	for i in local_moves:
		var val = hover_move if i == -1 else temp_water_break_move if i == -2 else cur_moves[i]
		if hover_move and i >= 0 and val[3] == hover_move[3] and val[4] == hover_move[4]:
			continue
		if i == -1 and (ap + ap_already < ap_cost or val[1] == 0):
			continue
		match val[0]:
			3:
				if ap_craft_indicator[0] != null or val[1] > 1:
					ap_craft_indicator[1] = [3, i]
					ap_craft_indicator[3] = [3, i]
					ap_craft_indicator[5] = [3, i]
				if ap_craft_indicator[0] == null:
					ap_craft_indicator[0] = [3, i]
					ap_craft_indicator[2] = [3, i]
					ap_craft_indicator[4] = [3, i]
			2:
				for mov_cnt in val[1]:
					if ap_craft_indicator[0] == null:
						ap_craft_indicator[0] = [2, i]
						ap_craft_indicator[2] = [2, i]
					elif ap_craft_indicator[1] == null:
						ap_craft_indicator[1] = [2, i]
						ap_craft_indicator[3] = [2, i]
					elif ap_craft_indicator[4] == null:
						ap_craft_indicator[4] = [2, i]
						ap_craft_indicator[5] = [2, i]
			1:
				for mov_cnt in val[1]:
					var filled = false
					for c in range(0, 2):
						for r in range(0, 3):
							if ap_craft_indicator[c + 2 * r] == null and not filled:
								ap_craft_indicator[c + 2 * r] = [1, i]
								filled = true
