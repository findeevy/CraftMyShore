extends TileMap

var TILE_SIZE = 64
var MAP_LENGTH = 12
var MAP_HEIGHT = 9
var waterCounter = 0
var waveSize = 3
var waterMap = []
var tracker = ""
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	waterMap.resize(MAP_LENGTH)
	waterMap.fill(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
