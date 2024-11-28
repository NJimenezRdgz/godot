extends Control
onready var ResOptButton = $HBoxContainer/Column2/ResolutionButton
signal CloseSettingsMenu

func _on_Exit_pressed():
	emit_signal("CloseSettingsMenu")


func _on_MasterVolumeVolumeButton_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)

var Resolutions: Dictionary = {"1920x1080": Vector2(1920,1080),
							   "1280x720": Vector2(1280,720),
							   "1020x600": Vector2(1020,600),
							}
func _ready():
	addResolutions()
	self.pause_mode = Node.PAUSE_MODE_PROCESS
func addResolutions():
	for r in Resolutions:
		ResOptButton.add_item(r)


func _on_ResolutionButton_item_selected(index):
	var size = Resolutions.get(ResOptButton.get_item_text(index))
	OS.set_window_size(size)




