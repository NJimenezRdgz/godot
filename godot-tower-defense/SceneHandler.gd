extends Node

func _ready():
	load_main_menu()

# Cargar el menú principal y conectar botones
func load_main_menu():
	get_node("MainMenu/M/VB/Play").connect("pressed", self, "on_play_pressed")
	get_node("MainMenu/M/VB/Quit").connect("pressed", self, "on_quit_pressed")
	get_node("MainMenu/M/VB/Settings").connect("pressed", self, "on_settings_pressed")
# Cargar la escena de selección de mapas
func load_map_select():
	get_node("MapSelectScene/M/HB/Map_1").connect("pressed", self, "on_map_1_pressed")
	get_node("MapSelectScene/M/HB/Map_2").connect("pressed", self, "on_map_2_pressed")
	get_node("MapSelectScene/M/HB/Map_3").connect("pressed", self, "on_map_3_pressed")
	get_node("MapSelectScene/Back").connect("pressed", self, "on_back_pressed")



# Botón Play carga la escena de selección de mapas
func on_play_pressed():
	get_node("MainMenu").queue_free()  # Eliminamos el menú principal
	var map_select_scene = load("res://Scenes/UIScenes/MapSelectScene.tscn").instance()
	add_child(map_select_scene)
	load_map_select()  # Conectar botones de MapSelectScene
	
func load_game_scene(map_name):
	var map_select = get_node("MapSelectScene")
	if map_select:
		map_select.queue_free()  # Eliminamos la selección de mapas
	else:
		print("Error: MapSelectScene no está en el árbol.")
	var game_scene = load("res://Scenes/MainScenes/GameScene.tscn").instance()
	game_scene.map_name = map_name  # Pasar el nombre del mapa a GameScene
	add_child(game_scene)

# Botón Configuración
func on_settings_pressed():
	var settings_menu = load("res://Scenes/UIScenes/Settings_menu.tscn").instance()
	add_child(settings_menu)
	get_node("Settings_menu").connect("CloseSettingsMenu", self, "CloseSettingsMenu")

# Botones para cargar mapas específicos
func on_map_1_pressed():
	print("Clickado map1")
	load_game_scene("Map_1")  # Carga GameScene con mapa 1

func on_map_2_pressed():
	print("Clickado map2")
	load_game_scene("Map_2")  # Carga GameScene con mapa 2

func on_map_3_pressed():
	print("Clickado map3")
	load_game_scene("Map_3")  # Carga GameScene con mapa 3
	
func on_back_pressed():
	var map_select = get_node("MapSelectScene")
	map_select.queue_free()
	var main_menu = load("res://Scenes/UIScenes/MainMenu.tscn").instance()
	add_child(main_menu)
	load_main_menu()
# Cargar el juego con el mapa seleccionado
func CloseSettingsMenu():
	get_node("Settings_menu").queue_free()
# Botón Salir
func on_quit_pressed():
	get_tree().quit()

# Volver al menú principal tras terminar el juego
func unload_game(result):
	get_node("GameScene").queue_free()
	var main_menu = load("res://Scenes/UIScenes/MainMenu.tscn").instance()
	add_child(main_menu)
	load_main_menu()
