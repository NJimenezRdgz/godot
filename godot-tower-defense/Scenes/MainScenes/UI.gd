extends CanvasLayer

onready var pause_play_button = get_node("HUD/GameControl/PausePlay")
onready var hp_bar = get_node("HUD/InfoBar/H/HP")
onready var hp_bar_tween = get_node("HUD/InfoBar/H/HP/Tween")
onready var coins = get_node("HUD/InfoBar/H/Money")
onready var wave_number_label = get_node("HUD/InfoBar/H/WaveNumber")

func _ready():
	get_parent().connect("wave_finished", self, "_on_wave_finished")
	
func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://Scenes/Towers/"+tower_type+".tscn").instance()
	
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff3c")
	
	var range_texture = Sprite.new()
	range_texture.position= Vector2(0,32)
	var scaling = GameData.tower_data[tower_type]["range"]/600.0
	range_texture.scale = Vector2(scaling,scaling)
	var texture = load("res://UI/range_overlay.png")
	range_texture.texture = texture
	range_texture.modulate= Color("ad54ff3c")
	
	var control = Control.new()
	control.add_child(drag_tower,true)
	control.add_child(range_texture,true)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	add_child(control,true)
	move_child(get_node("TowerPreview"),0)

func update_tower_preview(new_position,color):
	get_node("TowerPreview").rect_position=new_position
	if get_node("TowerPreview/DragTower").modulate !=Color(color):
		get_node("TowerPreview/DragTower").modulate =Color(color)
		get_node("TowerPreview/Sprite").modulate =Color(color)
		

##
##Game Control Func
##

func _on_PausePlay_pressed():
	# Verificar si no hay enemigos activos
	if get_parent().enemies_in_wave == 0:
		# Ocultamos el botón al iniciar la ola
		pause_play_button.hide()
		get_parent().start_next_wave()
	else:
		# Solo para depuración: no debería ser posible presionar si hay enemigos
		print("No puedes iniciar una nueva ola mientras hay enemigos activos.")

func _on_wave_finished(finished: bool):
	# Cuando se recibe la señal, mostrar el botón PausePlay si la ola terminó
	var pause_play_button = get_node("HUD/GameControl/PausePlay")
	print("señal recibida")
	if pause_play_button:
		if finished:
			pause_play_button.show()  # Mostrar el botón si la ola terminó
		else:
			pause_play_button.hide()  # Ocultar el botón si la ola no terminó
func _on_SpeedUp_pressed():
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0) 

func update_health_bar(base_health):
	
	hp_bar_tween.interpolate_property(hp_bar,"value",hp_bar.value,base_health,0.1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	hp_bar_tween.start()
	if base_health >=60:
		hp_bar.set_tint_progress("39e10b")
	elif base_health <=60 and base_health >=25:
		hp_bar.set_tint_progress("e1be32")
	else:
		hp_bar.set_tint_progress("e11e1e")
func update_coins(total_coins):
	coins.text = str(total_coins)
	print(coins)
func show_victory_screen():
	
	var win_screen = load("res://Scenes/SupportScenes/Win_screen.tscn").instance()
	add_child(win_screen)
	
	
func show_game_over_screen():
	var lose_screen = load("res://Scenes/SupportScenes/Lose_screen.tscn").instance()
	add_child(lose_screen)
	
func update_wave_label(current_wave, total_waves):
	wave_number_label.text = "Current wave: "+str(current_wave+1) + "/" + str(total_waves)
	
