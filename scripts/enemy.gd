# Enemy.gd
extends CharacterBody2D

@export var speed := 200
var health := 67

func _ready():
	add_to_group("Enemies")

func _physics_process(_delta):
	var player = get_tree().get_root().get_node("GameLevel/Player")
	if not player:
		return
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func take_damage(amount):
	health -= amount
	print("Wróg otrzymał obrażenia! HP:", health)
	if health <= 0:
		queue_free()
