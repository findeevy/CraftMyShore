extends AudioStreamPlayer

var local_tree = 0

func _ready():
	local_tree = Controller.trees_planted

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Controller.trees_planted > local_tree:
		local_tree = Controller.trees_planted
		self.play()
