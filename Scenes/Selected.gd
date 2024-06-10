extends Sprite2D

var TILE_SIZE=64

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 4
	frame = 0
	modulate = Color(0,0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Controller.mouse_step > 0 and Controller.mouse_tile_hover.y < Controller.board_height and Controller.mouse_tile_hover.x < Controller.board_length:
		visible = true
		position = Controller.mouse_tile_selected * TILE_SIZE
		if Controller.mouse_step == 4:
			modulate = Color(0.11764, 0.43529, 0.31372)
		elif Controller.mouse_step == 2:
			modulate = Color(0.91764, 0.196078, 0.23529)
		elif Controller.mouse_step == 1:
			modulate = Color(1, 0.63529, 0.078431)
		else:
			modulate = Color(1, 1, 1)
	else:
		visible = false
