extends FileDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_map_editor_save_map_file():
	self.set_filters(PackedStringArray(["*.dat ; CMS Maps"]))
	self.current_file="new_map"
	self.visible = true;


func _on_file_selected(path):
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.seek(0)
	f.store_string(Controller.export_string)
