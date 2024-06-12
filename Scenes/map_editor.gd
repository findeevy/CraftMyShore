extends Node

signal render_background
signal render

@onready var city_flooder = preload("res://city_animated_sprite.tscn")
@onready var tree_flooder = preload("res://tree_animated_sprite.tscn")

func _ready():
	load_array("map.dat")
	render.emit()
	render_background.emit()

func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_just_pressed("Click"):
		if Controller.mouse_tile_position.x < Controller.board_length and Controller.mouse_tile_position.y < Controller.board_height:
			map_cycle()
			render.emit()
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c+1,Controller.ap_start_r):
			Controller.selected_tile="l"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c,Controller.ap_start_r):
			Controller.selected_tile="w"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c,Controller.ap_start_r+2):
			Controller.selected_tile="c"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c,Controller.ap_start_r+1):
			Controller.selected_tile="t"
		elif Controller.mouse_tile_position==Vector2i(Controller.ap_start_c+1,Controller.ap_start_r+1):
			Controller.selected_tile="v"

func map_cycle():
	match Controller.selected_tile:
		"w":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=0
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=0
		"l":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=1
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=0
		"c":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=2
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=2
		"v":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=4
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=4
		"t":
			Controller.init_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=3
			Controller.tile_array[Controller.mouse_tile_position.y][Controller.mouse_tile_position.x]=1
	render.emit()
	render_background.emit()

func load_array(file_name):
	Controller.load_map(file_name)
	Controller.ap_start_c = Controller.board_length + 2
	process_game_tick()

func process_game_tick():
	if not Controller.game_ended:
		Controller.mouse_step = 0
		Controller.historical_game_states.append([Controller.tile_array.duplicate(true), Controller.wrs.duplicate(true), Controller.ap_craft_indicator.duplicate(true)])
		Controller.tick_counter += 1
		print("flooding %d%s" % [abs(Controller.tick_array[Controller.tick_counter]), ", try spawning plants" if Controller.tick_array[Controller.tick_counter] < 0 else ""])
		Controller.ap = 6
		for mov in Controller.cur_moves:
			match mov[4]:
				4:
					Controller.trees_moved += 1
				2:
					Controller.cities_moved += 1
				1:
					Controller.terrain_moved += 1
		Controller.cur_moves = []
		for winfo in Controller.pending_broken_waters:
			if winfo == null:
				continue
			Controller.tile_array[winfo[0]][winfo[1]] &= ~4
			print("spawn anim")
			var anim = tree_flooder.instantiate()
			anim.position = Vector2i(winfo[1], winfo[0]) * Colors.TILE_SIZE
			add_child(anim)
		Controller.pending_broken_waters = []
		Controller.ap_craft_indicator.fill(null)
		if Controller.tick_counter == Controller.tick_array.size() - 1:
			Controller.game_ended = true
			Controller.historical_game_states.append([Controller.tile_array, Controller.wrs, Controller.ap_craft_indicator])
			print("done; %d cities survived" % Controller.count_surviving_cities())
	else:
		print("done; %d cities survived" % Controller.count_surviving_cities())
