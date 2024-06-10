extends Label

signal render_end

var game_ended = false
var end_timer = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_ended:
		if !Controller.is_paused:
			end_timer -= delta
			if end_timer < 0:
				end_timer = 1.0
				print(Controller.tick_array.size())
				if Controller.tick_array.size() - 2 < Controller.view_tick:
					Controller.view_tick = 0
					Controller.view_historical_tick(Controller.view_tick)
					render_end.emit()
				else:
					Controller.view_tick += 1
					Controller.view_historical_tick(Controller.view_tick)
					render_end.emit()

func _input(event):
	if  Controller.tick_counter == Controller.tick_array.size() - 1 and !game_ended:
		self.text = "DONE!\nCITIES LEFT: %d\nTREES PLANTED: %d\nCITIES MOVED: %d\nTREES MOVED: %d\nTERRAIN MOVED: %d" % [Controller.count_surviving_cities(), Controller.trees_planted, Controller.cities_moved, Controller.trees_moved, Controller._moved]
		end_timer = 1.0
		game_ended = true
