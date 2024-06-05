extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_board_render():
	clear_layer(1)
	var r = 0
	for rd in GameBoard.tile_array:
		var c = 0
		for cd in rd:
			if cd & 1 > 0:
				set_cell(1, Vector2i(c, r), 0, Vector2i(0, 3))
			elif cd & 2 > 0:
				set_cell(1, Vector2i(c, r), 0, Vector2i(0, 2))
			elif cd & 4 > 0:
				set_cell(1, Vector2i(c, r), 0, Vector2i(0, 1))
			c+=1
		r+=1
	notify_runtime_tile_data_update(1)
	
func _on_game_board_render_background():
	clear_layer(0)
	var r = 0
	for rd in GameBoard.init_array:
		var c = 0
		for cd in rd:
			set_cell(0, Vector2i(c, r), 0, Vector2i(0, cd + 4))
			c+=1
		r+=1
	notify_runtime_tile_data_update(0)
