extends Node2D

signal game_finished(result)
signal wave_finished 
var map_node
var settings_menu_scene = preload("res://Scenes/UIScenes/Settings_menu.tscn")
var map_name = "Map_2"
var build_mode = false
var build_valid = false
var build_location
var build_type
var tower_type
var build_tile
var current_wave = 0
var enemies_in_wave = 0
var base_health=100
var total_coins = 150
var all_waves= []

func _ready(): 
	
	connect("game_finished", self, "_on_game_finished")
	load_map(map_name)  # Cargar el mapa seleccionado
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()])

func load_map(map_name):
	map_node = load("res://Scenes/Maps/" + map_name + ".tscn").instance()
	add_child(map_node)  # Agregar el mapa seleccionado a la escena
	
func _process(_delta: float):
	
	if build_mode:
		update_tower_preview()
func _unhandled_input(event):
	# Verificar si estamos en modo de construcción. Si es así, no hacer nada relacionado con torres.
	if build_mode == false:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			var clicked = get_viewport().get_mouse_position()
			var tower = get_node_at_click(clicked)  # Usamos la función que detecta torres con el TileMap
			if tower and tower.has_method("show_menu"):
				tower.show_menu()  # Mostrar el menú de la torre al hacer clic
 # Si se presiona "cancelar" mientras estamos en modo de construcción, cancelamos la construcción
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	
	# Si se presiona "aceptar" mientras estamos en modo de construcción, verificamos si es posible construir
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()
	if event.is_action_pressed("ui_cancel") and not build_mode:
		toggle_settings_menu()
		
func toggle_settings_menu():
	var existing_menu = get_node_or_null("SettingsMenu")
	if existing_menu:
		# Si existe, lo eliminamos y reanudamos el juego
		existing_menu.queue_free()
		get_tree().paused = false
	else:
		# Si no existe, lo instanciamos y pausamos el juego
		var settings_menu = settings_menu_scene.instance()
		add_child(settings_menu)
		settings_menu.name = "Settings_Menu"
		settings_menu.rect_position = get_viewport().size / 2 - settings_menu.rect_size / 2  # Centrar en pantalla
		get_tree().paused = true
##
## Wave Func
##
func return_all_waves():
	
	# Mapa de dificultad 1 (Map_1)
	if map_name == "Map_1":
		all_waves = [
			[["rat", 1.0], ["wolf", 0.8]],  # Oleada 1
			[["goblin", 0.9], ["wolf", 0.7]],  # Oleada 2
			[["rat", 1.0], ["wolf", 0.6], ["goblin", 0.8]],  # Oleada 3
			[["wolf", 0.7], ["wolf", 0.5], ["goblin", 0.6]],  # Oleada 4
			[["goblin", 0.8], ["wolf", 0.6], ["rat", 0.5]],  # Oleada 5
			[["wolf", 0.5], ["rat", 0.4], ["goblin", 0.6], ["goblin", 0.8]]  # Oleada 6
		]
	
	# Mapa de dificultad 2 (Map_2)
	elif map_name == "Map_2":
		all_waves = [
			[["rat", 1.0], ["wolf", 0.6], ["goblin", 0.8]],  # Oleada 1
			[["goblin", 0.7], ["wolf", 0.6], ["rat", 1.0], ["wolf", 0.8]],  # Oleada 2
			[["rat", 1.0], ["wolf", 0.7], ["goblin", 0.8], ["wolf", 0.5]],  # Oleada 3
			[["wolf", 0.6], ["wolf", 0.5], ["goblin", 0.8], ["rat", 1.0], ["rat", 1.0]],  # Oleada 4
			[["rat", 1.0], ["goblin", 0.6], ["wolf", 0.5], ["wolf", 0.7], ["rat", 0.5], ["goblin", 0.8]],  # Oleada 5
			[["wolf", 0.5], ["rat", 1.0], ["goblin", 0.7], ["wolf", 0.6], ["rat", 1.0], ["goblin", 0.8]]  # Oleada 6
		]
	
	# Mapa de dificultad 3 (Map_3)
	elif map_name == "Map_3":
		all_waves = [
			[["rat", 1.0], ["wolf", 0.7], ["goblin", 0.8]],  # Oleada 1
			[["wolf", 0.6], ["rat", 1.0], ["goblin", 0.7], ["wolf", 0.5]],  # Oleada 2
			[["rat", 1.0], ["wolf", 0.6], ["goblin", 0.7], ["wolf", 0.7]],  # Oleada 3
			[["goblin", 0.8], ["wolf", 0.5], ["rat", 1.0], ["goblin", 0.8], ["wolf", 0.7]], # Oleada 6
			]
	
	return all_waves




func start_next_wave():
	# Preparamos las olas si aún hay disponibles
	return_all_waves()
	
	# Verificamos si hay más olas por iniciar
	if current_wave < all_waves.size():
		var wave_data = retrieve_wave_data(current_wave)  # Obtiene los datos de la ola actual
		
		if wave_data.size() > 0:
			update_wave_ui()  # Actualizamos la interfaz
			
			# Esperamos un pequeño tiempo antes de lanzar los enemigos
			yield(get_tree().create_timer(0.2), "timeout")
			
			spawn_enemies(wave_data)  # Generamos los enemigos
			
			# Incrementamos el número de ola actual
			current_wave += 1
	else:
		# Si no hay más olas, emitimos una señal de que el juego ha terminado
		emit_signal("game_finished", true)

func retrieve_wave_data(wave_index):
	if wave_index < all_waves.size():
		var wave_data = all_waves[wave_index]
		enemies_in_wave = wave_data.size()
		return wave_data
	else:
		return []  
func spawn_enemies(wave_data):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + i[0] + ".tscn").instance()
		new_enemy.connect("base_damage", self, "on_base_damage")
		new_enemy.connect("coins_dropped", self, "on_base_coins")
		new_enemy.connect("died", self, "_on_enemy_died")
		map_node.get_node("Path").add_child(new_enemy, true)
		new_enemy.offset = 0
		yield(get_tree().create_timer(i[1]), "timeout")
func _on_enemy_died(enemy):
	enemies_in_wave -= 1
	if enemies_in_wave <= 0:
		emit_signal("wave_finished",true)


##
##Building Functions
##
func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type + "_lvl_1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1:
		if GameData.tower_data[build_type]["cost"] > total_coins:
			get_node("UI").update_tower_preview(tile_position, "adff4545")  # Color rojo si no se tiene suficiente dinero
			build_valid = false
		else:
			get_node("UI").update_tower_preview(tile_position, "ad54ff3c")  # Color verde si es válido
			build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "adff4545")  # Color rojo si el lugar no es válido
		build_valid = false
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()
func verify_and_build():
	if build_valid and GameData.tower_data[build_type]["cost"] <= total_coins:
		var new_tower = load("res://Scenes/Towers/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		map_node.get_node("Towers").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cellv(build_tile, 27)  # Marca el tile como ocupado
		total_coins -= GameData.tower_data[build_type]["cost"]  # Resta el costo de las monedas
		get_node("UI").update_coins(total_coins) 
func on_base_damage(damage):
	base_health -= damage
	if base_health<=0:
		emit_signal("game_finished",false)
	else:
		get_node("UI").update_health_bar(base_health)
func on_base_coins(coins):
	total_coins += coins
	get_node("UI").update_coins(total_coins)
func _on_game_finished(result):
	if result:
		get_node("UI").show_victory_screen()
	else:
		get_node("UI").show_game_over_screen()
func update_wave_ui():
	get_node("UI").update_wave_label(current_wave, all_waves.size())
func get_node_at_click(mouse_pos: Vector2) -> Object:
	# Convertir la posición del mouse a coordenadas del tile
	var tilemap = map_node.get_node("TowerExclusion")  # TileMap que controla las zonas de construcción
	var tile_coords = tilemap.world_to_map(mouse_pos)

	# Verificar si alguna torre está en las coordenadas del tile
	var towers = map_node.get_node("Towers")  # Nodo que contiene todas las torres
	for tower in towers.get_children():
		var tower_tile_coords = tilemap.world_to_map(tower.position)
		if tower_tile_coords == tile_coords:
			print(tower)
			return tower  # Devuelve la torre encontrada en este tile
	
	return null  # Si no hay torre, devolver null

