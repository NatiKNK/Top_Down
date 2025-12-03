# Player.gd
extends CharacterBody2D

@export var speed := 300
@export var attack_damage := 1
@export var attack_range := 75

var health := 3
var invincible_time := 1.0
var invincible_timer := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta):
	# Update invincibility timer
	if invincible_timer > 0:
		invincible_timer -= _delta

	# Movement input
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		# Flip sprite
		sprite.flip_h = input_direction.x < 0
		# Play walk animation
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		# Idle animation
		if sprite.animation != "idle":
			sprite.play("idle")

	# Move the player
	velocity = input_direction * speed
	move_and_slide()

	# Check collisions with enemies
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("Enemies"):
			hit_by_enemy(collider)

	# Check attack input
	if Input.is_action_just_pressed("attack"):
		attack()


func hit_by_enemy(enemy):
	if invincible_timer > 0:
		return  # currently invincible

	health -= 1
	print("Gracz został trafiony! Życie:", health)

	# Pushback
	var pushback = (global_position - enemy.global_position).normalized() * 50
	velocity += pushback

	# Start invincibility
	invincible_timer = invincible_time

	if health <= 0:
		die()


func attack():
	# Check all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) <= attack_range:
			enemy.take_damage(attack_damage)
			print("Atak trafiony!")


func die():
	print("Gracz umarł!")
	queue_free()  # remove player from scene
