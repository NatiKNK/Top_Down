extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_time := 2.0  # sekundy między spawnem

var timer := 0.0

func _process(delta):
	timer += delta
	if timer >= spawn_time:
		timer = 0.0
		_spawn_enemy()

func _spawn_enemy():
	if not enemy_scene:
		return
	
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Spawn poza ekranem
	var screen = get_viewport().get_visible_rect().size
	var cam_pos = camera.global_position
	
	# Losowa krawędź ekranu
	var pos = Vector2()
	var side = randi() % 4
	
	match side:
		0: # góra
			pos = Vector2(randf_range(-200, screen.x+200), -100)
		1: # dół
			pos = Vector2(randf_range(-200, screen.x+200), screen.y+100)
		2: # lewo
			pos = Vector2(-100, randf_range(-200, screen.y+200))
		3: # prawo
			pos = Vector2(screen.x+100, randf_range(-200, screen.y+200))
	
	# Stwórz przeciwnika
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos + cam_pos - screen/2
	get_parent().add_child(enemy)
