extends KinematicBody2D

var speed = 1000.0  # Velocidad de la flecha
var target_position := Vector2.ZERO  # Posición del objetivo (enemigo)
var damage  # Daño de la flecha
var direction := Vector2.ZERO  # Dirección hacia la que la flecha se mueve

func _ready():
	# Inicializa la dirección y la rotación cuando la flecha es lanzada
	set_target_position()  # Inicializa la dirección de la flecha hacia el objeto
	yield(get_tree().create_timer(10.0), "timeout")
	queue_free()
func set_damage(tower_type):
	# Asegúrate de que GameData esté cargado y tenga los datos
	if GameData.tower_data.has(tower_type):
		damage = GameData.tower_data[tower_type]["damage"]
func _physics_process(delta: float):
	var velocity = direction * speed
	move_and_collide(velocity * delta)  # Mueve la flecha usando las físicas
	# Ajustar la rotación para que la flecha siempre apunte hacia su destino
	rotation = direction.angle()

func set_target_position():
	direction = (target_position - global_position).normalized()

func _on_Area2D_body_entered(body: Node):
	var enemy = body.get_parent()
	print("enemigo impactado: ")
	print(enemy)
	if "enemy" in enemy.name:
		print(enemy.hp)
		if enemy.has_method("on_hit"):
			enemy.on_hit(damage)
		queue_free()
