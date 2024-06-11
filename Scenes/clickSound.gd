extends AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if Input.is_action_just_pressed("Click"):
		self.play()
