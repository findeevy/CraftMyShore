extends Node

signal render_background
signal render

var init_array = []
var tile_array = []

var board_length = 0
var board_height = 0

var water_counter = 0
var wave_size = 1
var water_array = []
var rng = RandomNumberGenerator.new()

func load_array(file_name):
	var f = FileAccess.open("res://" + file_name, FileAccess.READ)
	while f.get_position() < f.get_length():
		var l = f.get_line()
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
				"g":
					id.append(4)
					td.append(4)
				"t":
					id.append(3)
					td.append(1)
		init_array.append(id)
		tile_array.append(td)
	board_length = init_array[0].size()
	board_height = init_array.size()

func calculate_water_reach(col):
	var vol = water_array[col]
	#print(water_array)
	#print("col:", col, " vol:", vol)
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
			
func check_grass_absorb(col): # this just checks if grass absorbs a single new water tile; grass tile movement should go somewhere else
	var res = calculate_water_reach(col)
	var max_reach = max(res[0], res[1]) - 1
	if max_reach < 0:
		return
	if max_reach + 1 < board_height and tile_array[max_reach+1][col] & 4 > 0:
		water_array[col] -= 1
		tile_array[max_reach+1][col] &= ~4
		print("col %d destroyed grass down" % col)
	elif col > 0 and tile_array[max_reach][col-1] & 4 > 0:
		water_array[col] -= 1
		tile_array[max_reach][col-1] &= ~4
		print("col %d destroyed grass left" % col)
	elif col < board_length-1 and tile_array[max_reach][col+1] & 4 > 0:
		water_array[col] -= 1
		tile_array[max_reach][col+1] &= ~4
		print("col %d destroyed grass right" % col)
	
func check_destroy_city(col):
	var res = calculate_water_reach(col)
	var max_reach = max(res[0], res[1]) - 1
	if max_reach < 0:
		return
	if tile_array[max_reach][col] & 2 > 0:
		tile_array[max_reach][col] &= ~2
		print("col %d destroyed city" % col)
		
func create_wave():
	var waterRng = rng.randi_range(0, board_length - 1)
	water_array[waterRng] += 1
	check_grass_absorb(waterRng)
	check_destroy_city(waterRng)

# Called when the node enters the scene tree for the first time.
func _ready():
	load_array("map.dat")
	water_array.resize(board_length)
	water_array.fill(0)
	render.emit()
	render_background.emit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	for i in wave_size:
		GameBoard.create_wave() # because the instance node needs to call the actual global instance
	render.emit()
