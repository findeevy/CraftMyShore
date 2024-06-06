extends Sprite2D

var TILE_SIZE = 64;

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 5
	texture = load("res://Textures/cursor2.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position=Controller.mouse_tile_hover*TILE_SIZE
	if(Controller.mouse_step==4):
		modulate = Color(0, 1, 0)
		draw_cursor(1)
	elif(Controller.mouse_step==2):
		modulate = Color(1, 0, 0)
		draw_cursor(3)
	elif(Controller.mouse_step==1):
		modulate = Color(1, 1, 0)
		draw_cursor(2)
	else:
		modulate = Color(1, 1, 1)
		texture = load("res://Textures/cursor.png")
func draw_cursor(cost):
	var amount = cost*(abs(Controller.mouse_tile_position.y - Controller.mouse_tile_hover.y) + abs(Controller.mouse_tile_position.x - Controller.mouse_tile_hover.x))
	if amount <= Controller.ap:
		texture = load("res://Textures/cursor"+str(amount)+".png")
	else:
		texture = load("res://Textures/cursorNo.png")
