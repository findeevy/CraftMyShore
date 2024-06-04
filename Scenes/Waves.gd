extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input. is_action_just_pressed("ui_select")):
		var waterBlock = Sprite2D.new()
		waterBlock.texture = load("res://Textures/water.png")
		add_child(waterBlock)
		var rng = RandomNumberGenerator.new()
		waterBlock.global_position = Vector2((rng.randi_range(0, 11))*64-32,0)
