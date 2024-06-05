extends TileMap

var TILE_SIZE = 64
var MAP_LENGTH = 12
var MAP_HEIGHT = 9
var waterMap = []
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	waterMap.resize(MAP_LENGTH)
	waterMap.fill(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(Input. is_action_just_pressed("ui_select")):
		var waterBlock = Sprite2D.new()
		waterBlock.texture = load("res://Textures/water.png")
		waterBlock.z_index = 4
		var waterRng=rng.randi_range(0, MAP_LENGTH-1)
		while(MAP_HEIGHT<waterMap[waterRng]+1):
			waterRng=rng.randi_range(0, MAP_LENGTH-1)
		waterMap[waterRng]=waterMap[waterRng]+1
		var waterX=waterRng*TILE_SIZE-32
		var waterY=waterMap[waterRng]*TILE_SIZE-32
		waterBlock.position = Vector2(waterX,waterY)
		add_child(waterBlock)
