extends Node

signal render_background
signal render

var init_array = []
var tile_array = []

var board_length = 0
var board_height = 0

var water_counter = 0
var wave_size = 3
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
	board_height=init_array[0].size()
	board_length=init_array.size()

# Called when the node enters the scene tree for the first time.
func _ready():
	load_array("map.dat")
	water_array.resize(board_length)
	water_array.fill(0)
	render.emit()
	render_background.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input. is_action_just_pressed("ui_select") and water_counter<board_length*board_height):
		for i in wave_size:
			var waterRng=rng.randi_range(0, board_length-1)
			while(board_height<water_array[waterRng]):
				waterRng=rng.randi_range(0, board_length-1)
			water_counter+=1
			water_array[waterRng]=water_array[waterRng]+1
			print(str(water_array))
