extends CharacterBody2D
class_name Player
signal healthChanged
@export var speed := 200
@export var maxHealth = 5
var invincible := false
var invincible_timer := 0.0
@onready var currentHealth: int = maxHealth
@onready var sprite = $AnimatedSprite2D  # LUB $Sprite2D jeśli nie masz animacji

func _ready():
	add_to_group("player")
	name = "Player"
	
	# Upewnij się że sprite istnieje
	if sprite == null:
		print("UWAGA: Nie znaleziono sprite'a! Dodaj AnimatedSprite2D lub Sprite2D")
		sprite = Sprite2D.new()

func _physics_process(delta):
	# Odliczanie niewrażliwości
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false
			# Przywróć normalny kolor
			if sprite.has_method("set_modulate"):
				sprite.modulate = Color.WHITE
	
	# Ruch
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# ANIMACJE - TO JEST NAJWAŻNIEJSZE
	if input.length() > 0:
		input = input.normalized()
		velocity = input * speed
		
		# Animacja chodzenia
		if sprite is AnimatedSprite2D:
			if sprite.animation != "walk":
				sprite.play("walk")
		# LUB dla zwykłego Sprite2D - obrót
		sprite.flip_h = input.x < 0 if input.x != 0 else sprite.flip_h
	else:
		# Stoi w miejscu
		velocity = Vector2.ZERO
		if sprite is AnimatedSprite2D:
			if sprite.animation != "idle":
				sprite.play("idle")
	
	move_and_slide()
	
	# Sprawdź kolizje z przeciwnikami
	_check_enemy_collisions()

func _check_enemy_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("Enemies"):
			take_damage(1, collider)

func take_damage(amount, enemy = null):
	if invincible:
		return
	currentHealth -= amount
	print("Gracz trafiony! HP:", currentHealth)
	healthChanged.emit()
	
	# Efekt otrzymania obrażeń
	if sprite.has_method("set_modulate"):
		sprite.modulate = Color.RED
	
	# Odsuń gracza
	if enemy:
		var push = (global_position - enemy.global_position).normalized() * 100
		velocity += push
	
	# Włącz niewrażliwość
	invincible = true
	invincible_timer = 1.0
	
	if currentHealth <= 0:
		die()

func die():
	print("GAME OVER")
	queue_free()

# Opcjonalnie: atakowanie
func _input(event):
	if event.is_action_pressed("attack"):
		attack()

func attack():
	# Prosty atak wokół gracza
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) < 80:
			enemy.take_damage(1)
			print("Atak trafiony!")
