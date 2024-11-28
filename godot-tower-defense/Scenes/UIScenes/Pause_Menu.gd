extends Control




func _ready():
	pass 




func _on_ResumeButton_pressed():
	get_tree().paused = false
	queue_free()


func _on_OptionsButton_pressed():
	var settings_menu_scene = preload("res://Scenes/UIScenes/Settings_menu.tscn")
	var settings_menu_scene_instance =settings_menu_scene.instance()
	add_child(settings_menu_scene_instance)


func _on_MainMenuButton_pressed():
	get_tree().paused = false  # Despausar el juego
	get_tree().change_scene("res://SceneHandler.tscn") # Cambia a la nueva escena

