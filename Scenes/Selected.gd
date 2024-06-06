extends Sprite2D

var TILE_SIZE=64

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 4
	modulate = Color(0,0,0)
	texture = load("res://Textures/cursor.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Controller.mouse_step > 0 and Controller.mouse_tile_hover.y*TILE_SIZE < Controller.board_height and Controller.mouse_tile_hover.x*TILE_SIZE < Controller.board_length:
		var type_picked = Controller.tile_array[Controller.mouse_tile_hover.y][Controller.mouse_tile_hover.x]
		if (type_picked==4):
			modulate = Color(0.11764, 0.43529, 0.31372)
			position = Controller.mouse_tile_selected*TILE_SIZE
		elif(type_picked==2):
			modulate = Color(0.91764, 0.196078, 0.23529)
			position = Controller.mouse_tile_selected*TILE_SIZE
		elif(type_picked==1):
			modulate = Color(1, 0.63529, 0.078431)
			position = Controller.mouse_tile_selected*TILE_SIZE
		else:
			modulate = Color(1, 1, 1)
			visible = true
	else:
		visible = false
