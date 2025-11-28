extends CharacterBody2D


var speed = 200

@onready var player = get_node("/root/GameLevel/Player")



func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
