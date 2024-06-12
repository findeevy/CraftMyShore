extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	self.theme = Theme.new()
	var f = load("res://Fonts/finPixel.ttf")
	self.add_theme_font_override("font", f)
	self.add_theme_font_size_override("font_size", 32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
