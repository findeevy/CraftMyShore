extends Sprite2D

var TILE_SIZE = 64;

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Controller.mouse_tile_hover.x > Controller.board_length - 1 or Controller.mouse_tile_hover.y > Controller.board_height - 1:
		position=get_global_mouse_position()
		visible = false
	else:
		position=Controller.mouse_tile_hover*TILE_SIZE
		visible = true
		if(Controller.mouse_step==4):
			modulate = Color(0.11764, 0.43529, 0.31372)
			draw_cursor(1)
		elif(Controller.mouse_step==2):
			modulate = Color(0.91764, 0.196078, 0.23529)
			draw_cursor(3)
		elif(Controller.mouse_step==1):
			modulate = Color(1, 0.63529, 0.078431)
			draw_cursor(2)
		else:
			modulate = Color(1, 1, 1)
			texture = load("res://Textures/cursor.png")
func draw_cursor(cost):
	var dist = abs(Controller.mouse_tile_position.y - Controller.mouse_tile_hover.y) + abs(Controller.mouse_tile_position.x - Controller.mouse_tile_hover.x)
	var amount = cost*(dist)
	if amount <= Controller.ap:
		texture = load("res://Textures/cursor"+str(amount)+".png")
	elif dist == 0:
		texture = load("res://Textures/cursor.png")
	else:
		texture = load("res://Textures/cursorNo.png")
