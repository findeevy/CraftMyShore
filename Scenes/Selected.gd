extends Sprite2D

var TILE_SIZE=64

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 4
	modulate = Color(0,0,0)
	texture = load("res://Textures/cursor.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Controller.mouse_step > 0:
		position = Controller.mouse_tile_selected*TILE_SIZE
		visible = true
	else:
		visible = false
