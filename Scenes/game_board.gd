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
