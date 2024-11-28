extends Node2D

onready var UnitAnimation = $UnitAnimation  # Nodo AnimationPlayer
onready var Unit = $Unit  # Nodo Sprite o el nodo principal del personaje
onready var TowerAnimation = $TowerAnimation
onready var fire_sound = $Sound
var enemy_array = []
var enemy
var type
var flip 
var built = false
var ready = true

onready var FirePositions = {
	"up": $Unit/Up,
	"down": $Unit/Down,
	"sidel": $Unit/SideL,
	"sider": $Unit/SideR
}

func _ready() -> void:
	var tower_menu = get_node("TowerMenu")
	#var upgrade_button = tower_menu.get_node("VBoxContainer/UpgradeButton")
	#upgrade_button.connect("pressed", self, "_on_upgrade_pressed")
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]

func _physics_process(_delta: float) -> void:
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
		if ready:
			fire()
	else:
		enemy = null
		if UnitAnimation.current_animation != "Idle_down":
			UnitAnimation.play("Idle_down")
func turn():
	if enemy == null:
		return
	
	# Posiciones del enemigo y la torre
	var enemy_position = enemy.global_position
	var unit_position = Unit.global_position

	# Calcular la diferencia para determinar la dirección
	var direction = enemy_position - unit_position

	# Determinar la animación específica basada en la dirección
	if abs(direction.x) > abs(direction.y):
		# Enemigo a la derecha o izquierda
		if UnitAnimation.current_animation != "Attack_side":
			UnitAnimation.play("Attack_side")

		# Ajustar flip horizontal según la dirección de la animación
		if UnitAnimation.is_playing() and UnitAnimation.current_animation == "Attack_side":
			# Si la animación está en ejecución y es "Attack_side", ajustamos el flip
			flip = direction.x > 0  # Si la dirección es negativa (izquierda), flip será true
			Unit.flip_h = flip  # Aplica el flip al nodo, ajustando la orientación
	else:
		if direction.y < 0:
			# Enemigo arriba
			if UnitAnimation.current_animation != "Attack_up":
				UnitAnimation.play("Attack_up")
		else:
			# Enemigo abajo
			if UnitAnimation.current_animation != "Attack_down":
				UnitAnimation.play("Attack_down")

func select_enemy():
	# Limpiar enemigos muertos o que ya no están en escena
	for enemy in enemy_array:
		if enemy == null or not enemy.is_inside_tree():
			enemy_array.erase(enemy)
	
	if enemy_array.size() == 0:
		enemy = null
		return

	# Seleccionar el enemigo más avanzado (con el mayor offset)
	var enemy_progress_array = []
	for i in enemy_array:
		if i.has_method("get_offset"): 
			enemy_progress_array.append(i.offset)
		else:
			enemy_progress_array.append(0) 

	var max_offset = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_offset)
	enemy = enemy_array[enemy_index]


func fire():
	if enemy == null or !GameData.tower_data.has(type):
		return

	ready = false
	var tower_data = GameData.tower_data[type]		
	
	if tower_data["type"] == "projectile":
		# Instanciar proyectil
		var projectile_scene = preload("res://Scenes/Towers/arrow.tscn")
		var projectile = projectile_scene.instance()
		projectile.set_damage(type)

		# Determinar la posición de disparo
		var fire_position = determine_fire_position()

		# Coloca el proyectil en la posición de disparo
		projectile.global_position = fire_position.global_position

		# Configura la posición del objetivo (enemigo)
		projectile.target_position = enemy.global_position  # La flecha ahora tiene el enemigo como objetivo

		# Añadir proyectil a la escena
		get_parent().add_child(projectile)
		fire_sound.play()
		

	elif tower_data["type"] == "area":
		# Instanciar rayo en área
		create_lightning_effect(enemy.global_position, tower_data["effect_radius"])

	yield(get_tree().create_timer(tower_data["rof"]), "timeout")
	ready = true

func create_lightning_effect(position: Vector2, radius: float):
	# Instanciar la escena de lightning_area (solo para efectos visuales)
	var lightning_effect = preload("res://Scenes/Towers/lightning_area.tscn").instance()
	lightning_effect.global_position = position  # Colocar el rayo en la posición de ataque

	# Opcional: Aquí podrías iniciar la animación del rayo, si tienes un AnimationPlayer
	if lightning_effect.has_node("AnimationPlayer"):
		lightning_effect.get_node("AnimationPlayer").play("lightning")

	# Añadir el efecto al árbol de nodos
	get_parent().add_child(lightning_effect)

	# Aplicar el daño a los enemigos dentro del radio, usando tu código de detección
	apply_area_damage(position, radius, GameData.tower_data[type]["damage"])

	yield(get_tree().create_timer(1), "timeout") 
	lightning_effect.queue_free()

func apply_area_damage(center: Vector2, radius: float, damage: int):
	for body in get_tree().get_nodes_in_group("enemies"):
		print(body)
		if body.global_position.distance_to(center) <= radius:
			if body.has_method("on_hit"):
				body.on_hit(damage)

func determine_fire_position() -> Position2D:
	if UnitAnimation.current_animation == "Attack_up":
		return FirePositions["up"]
	elif UnitAnimation.current_animation == "Attack_down":
		return FirePositions["down"]
	else:
		if flip:
			return FirePositions["sider"]
		else:
			return FirePositions["sidel"]

func _on_Range_body_entered(body: Node2D) -> void:
	var enemy = body.get_parent()  # Obtener al enemigo completo (no solo la colisión)
	enemy_array.append(enemy)
	
	# Conectar la señal "died" del enemigo para eliminarlo del array al morir
	if enemy.has_signal("died"):
		enemy.connect("died", self, "_on_enemy_died")

func _on_Range_body_exited(body: Node2D) -> void:
	var enemy = body.get_parent()
	enemy_array.erase(enemy)

func _on_enemy_died(enemy: Node2D) -> void:
	enemy_array.erase(enemy)  # Eliminar al enemigo del array cuando muera
	if enemy == self.enemy:
		self.enemy = null  # Limpiar referencia si el enemigo actual murió

func _on_AreaClickTorre_input_event(viewport, event, shape_idx):
	var tower_menu = get_node("TowerMenu")
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if tower_menu:
				tower_menu.visible = !tower_menu.visible 
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			if tower_menu.visible:
				!tower_menu.visible
func hide_menu():
	var tower_menu = get_node("TowerMenu")
	if tower_menu:
		tower_menu.visible = false  # Oculta el menú
func _on_upgrade_pressed():
	if built:
		if can_upgrade():
			apply_upgrade()
			hide_menu()  # Ocultar el menú después de la mejora
		else:
			print("No tienes suficiente dinero para mejorar la torre.")
	else:
		print("La torre no está construida todavía.")
# En el script de la torre (por ejemplo, Towers.gd)
func can_upgrade() -> bool:
	if not built:
		return false
	
	var tower_data = GameData.tower_data.get(type, null)  # Obtener los datos de la torre según su tipo

	if tower_data == null:
		return false  # Si no existe la torre, no puede mejorarse

	var current_upgrade_cost = tower_data.get("upgrade_cost", 0)  # Obtener el costo de mejora de la torre
	
	# Obtener la escena activa
	var game_scene = get_tree().root.get_child(0)  # Esto obtiene el primer hijo de la raíz (generalmente la escena principal)

	if game_scene == null:
		print("Error: No se pudo acceder a la GameScene.")
		return false  # Si no podemos acceder a GameScene, no hacemos nada
	
	var total_coins = game_scene.total_coins  # Obtener el dinero del jugador desde GameScene

	return total_coins >= current_upgrade_cost  # Verificar si el jugador tiene suficiente dinero

func apply_upgrade():
	var game_scene = get_tree().current_scene  # Accede a la escena actual (GameScene)
	
	if game_scene != null:
		var total_coins = game_scene.total_coins  # Accede a total_coins de GameScene
		var upgrade_cost = GameData.tower_data[type].get("upgrade_cost", 0)

		if total_coins >= upgrade_cost:
			game_scene.total_coins -= upgrade_cost  # Resta el costo de la mejora
			game_scene.upgrade_tower()  # Realiza la mejora de la torre
		else:
			print("No tienes suficiente dinero para mejorar la torre.")
	else:
		print("Error: No se pudo acceder a GameScene.")

