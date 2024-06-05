extends Node

signal render_background
signal render

func _ready():
	Controller.load_array("map.dat")
	render.emit()
	render_background.emit()
	
func _process(delta):
	pass
	
func _on_button_pressed():
	Controller.process_game_tick()
	render.emit()
func _input(event):
	if(Input.is_action_just_pressed("Click") and Controller.mouse_tile_position.x<=Controller.board_length and Controller.mouse_tile_position.y<=Controller.board_height):
		Controller.cycleTile()
		render.emit()
