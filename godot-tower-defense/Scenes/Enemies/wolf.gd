extends PathFollow2D

onready var UnitAnimation = $wolf_enemy_body/UnitAnimation
onready var Unit = $wolf_enemy_body/Unit
var previous_position = Vector2.ZERO
signal base_damage(damage)
signal coins_dropped(coins)
signal died
var base_damage = 10

onready var health_bar = $HealthBar
var speed = 65
var hp = 105
var coins_dropped = 20
var dying = false


func _ready():
	previous_position = global_position
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_toplevel(true)

func _physics_process(delta):
	if unit_offset == 1.0:
		emit_signal("base_damage", base_damage)
		emit_signal("died",self)
		queue_free()
	if not dying:
		move(delta)

func move(delta):
	set_offset(get_offset() + speed * delta)
	health_bar.set_position(position - Vector2(19, 19))

	var current_position = global_position
	var velocity = current_position - previous_position
	previous_position = current_position

	if abs(velocity.x) > abs(velocity.y):
		if UnitAnimation.current_animation != "Walk_side":
			UnitAnimation.play("Walk_side")
		Unit.flip_h = velocity.x > 0
	else:
		if velocity.y < 0:
			if UnitAnimation.current_animation != "Walk_up":
				UnitAnimation.play("Walk_up")
		elif velocity.y > 0:
			if UnitAnimation.current_animation != "Walk_down":
				UnitAnimation.play("Walk_down")

func on_hit(damage):
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		
		if UnitAnimation.current_animation == "Walk_down":
			dying = true
			UnitAnimation.play("Death_down")
			print("Animacion muerte hacia abajo")
		elif UnitAnimation.current_animation == "Walk_side":
			dying = true
			UnitAnimation.play("Death_side")
			print("Animacion muerte hacia el lado")
		elif UnitAnimation.current_animation == "Walk_up":
			dying = true
			UnitAnimation.play("Death_up")
			print("Animacion muerte hacia arriba")
		else:
			dying = true
			UnitAnimation.play("Death_down")
			print("Animacion por defecto")
		yield(get_tree().create_timer(0.8), "timeout")
		emit_signal("coins_dropped", coins_dropped)
		on_destroy()

func on_destroy(): 
	emit_signal("died", self)  # Emitir la señal cuando el enemigo muere
	queue_free()


