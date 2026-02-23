# enemy.gd (Modified)
extends CharacterBody2D

@export var speed := 150
@export var damage := 1
var health := 2  # Will be overwritten by spawner
signal died

func _ready():
	add_to_group("Enemies")
	
	# Upewnij się że Area2D istnieje
	if has_node("Hitbox"):
		$Hitbox.body_entered.connect(_on_body_entered)

func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount):
	health -= amount
	print("Enemy took damage! Health left: ", health)  # Debug
	if health <= 0:
		die()

func die():
	print("Enemy died!")  # Debug
	died.emit()  # This will notify the spawner AND StageManager
	queue_free()

func _on_body_entered(body):
	# Jeśli dotknęliśmy gracza
	if body.is_in_group("player"):
		body.take_damage(damage, self)

# Remove _on_tree_exiting() or keep it - either way works
# But if you keep it, it might emit died twice
