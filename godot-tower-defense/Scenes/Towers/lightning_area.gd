extends Node2D

onready var animation_player = $AnimationPlayer 
var duration = 1  

func _ready():
	
	if animation_player:
		animation_player.play("lightning")
	
	yield(get_tree().create_timer(duration), "timeout")
	queue_free()  
