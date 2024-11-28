extends Control

func _on_Exit_pressed(): # Eliminamos el menú principal y cargamos la nueva escena
	# Cambia la escena por la nueva. Asegúrate de usar la extensión ".tscn" de la escena.
	get_tree().change_scene("res://SceneHandler.tscn")  # Cambia a la nueva escena

