extends FileDialog

signal finalize_load

func _on_map_editor_load_map_file():
	self.set_filters(PackedStringArray(["*.dat ; CMS Maps"]))
	self.current_file="new_map"
	self.visible = true;


func _on_file_selected(path):
	Controller.loaded_file=path
	finalize_load.emit()
