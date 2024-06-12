extends Sprite2D

var previous_game = "";
var previous_game_text = "";
var file_written = false;
var file_exist = FileAccess.file_exists("res://previousGame.dat")

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Controller.mouse_tile_hover.x >= Controller.board_length or Controller.mouse_tile_hover.y >= Controller.board_height:
		position = get_global_mouse_position()
		visible = false
	else:
		position = Controller.mouse_tile_hover * Colors.TILE_SIZE
		visible = true
		var ap_cost_info = Controller.get_hover_ap_cost()
		var ap_cost = ap_cost_info[0]
		var ap_already = ap_cost_info[1]
		frame = 7 if ap_cost > Controller.ap + ap_already or ap_cost < 0 else ap_cost
		if Controller.mouse_step == 4:
			modulate = Colors.PLANT
		elif Controller.mouse_step == 2:
			modulate = Colors.CITY
		elif Controller.mouse_step == 1:
			modulate = Colors.HILL
		elif get_tree().current_scene.name == "map_editor":
			match Controller.selected_tile:
				"v":
					modulate = Colors.PLANT
				"c":
					modulate = Colors.CITY
				"t":
					modulate = Colors.HILL
				"w":
					modulate = Colors.WATER
				"l":
					modulate = Colors.NONE
		else:
			match Controller.tile_array[Controller.mouse_tile_hover.y][Controller.mouse_tile_hover.x]:
				4:
					modulate = Colors.PLANT
				2:
					modulate = Colors.CITY
				1:
					modulate = Colors.HILL
				_:
					modulate = Colors.NONE
