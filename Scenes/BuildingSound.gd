extends AudioStreamPlayer

var local_building = 0

func _ready():
	local_building = Controller.count_surviving_cities()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if local_building < 1:
		local_building = Controller.count_surviving_cities()
	elif Controller.count_surviving_cities() < local_building:
		local_building = Controller.count_surviving_cities()
		self.play()
