extends Node

signal render_background
signal render

func _ready():
	Controller.load_array("map.dat")
	render.emit()
	render_background.emit()
	
func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_just_pressed("Click"):
		if Controller.tick_counter == Controller.tick_array.size() - 1:
			if Controller.mouse_tile_position.y == Controller.board_height and Controller.mouse_tile_position.x < Controller.tick_counter:
				Controller.view_historical_tick(Controller.mouse_tile_position.x)
				render.emit()
			elif Controller.mouse_tile_position.x in range(Controller.ap_start_c, Controller.ap_start_c + 1) and Controller.tick_counter == Controller.tick_array.size() - 1:
				if Controller.mouse_tile_position.y in range(Controller.ap_start_r+3, Controller.ap_start_r + 4):
					Controller.is_paused = false
					render_background.emit()
			elif Controller.mouse_tile_position.x in range(Controller.ap_start_c+1, Controller.ap_start_c + 2) and Controller.tick_counter == Controller.tick_array.size() - 1:
				if Controller.mouse_tile_position.y in range(Controller.ap_start_r+3, Controller.ap_start_r + 4):
					Controller.is_paused = true
					render_background.emit()
			return
		if Controller.waters_to_break != []:
			for w in Controller.waters_to_break:
				if w[0] == Controller.mouse_tile_position.y and w[1] == Controller.mouse_tile_position.x:
					Controller.process_water_break(w[0], w[1])
					render.emit()
					return
		elif Controller.mouse_tile_position.x < Controller.board_length and Controller.mouse_tile_position.y < Controller.board_height:
			Controller.cycleTile()
			render.emit()
		elif Controller.mouse_tile_position.x in range(Controller.ap_start_c, Controller.ap_start_c + 2):
			if Controller.mouse_tile_position.y in range(Controller.ap_start_r, Controller.ap_start_r + 3):
				var click_pos = 2 * (Controller.mouse_tile_position.y - Controller.ap_start_r) + Controller.mouse_tile_position.x - Controller.ap_start_c
				if Controller.ap_craft_indicator[click_pos] == null:
					return
				Controller.undo_move(Controller.ap_craft_indicator[click_pos][1])
				render.emit()
			elif Controller.mouse_tile_position.y == Controller.ap_start_r + 3:
				Controller.process_game_tick()
				render.emit()
	if Input.is_action_just_pressed("Right Click"):
		if Controller.tick_counter == Controller.tick_array.size():
			Controller.view_historical_tick(Controller.tick_counter)
			render.emit()
		else:
			Controller.mouse_step = 0
