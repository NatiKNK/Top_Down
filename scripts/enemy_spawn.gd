# enemy_spawn.gd
extends Node2D

@onready var StageManager = get_node("/root/StageManager")

@export var enemy_scene: PackedScene
var spawn_time := 2.0
var timer := 0.0
var enemies_to_spawn := 0
var spawn_active := false

func _ready():
	print("EnemySpawn: _ready() called")  # DEBUG
	print("StageManager found: ", StageManager != null)  # DEBUG
	
	if StageManager:
		StageManager.stage_started.connect(_on_stage_started)
		StageManager.stage_completed.connect(_on_stage_completed)
		print("EnemySpawn: Connected to StageManager signals")  # DEBUG
	else:
		print("EnemySpawn: ERROR - StageManager is null!")  # DEBUG

func _process(delta):
	if not spawn_active or enemies_to_spawn <= 0:
		return
		
	timer += delta
	if timer >= spawn_time:
		timer = 0.0
		_spawn_enemy()
		enemies_to_spawn -= 1
		print("Enemy spawned! Remaining to spawn: ", enemies_to_spawn)  # DEBUG
		
		if enemies_to_spawn <= 0:
			spawn_active = false
			print("All enemies for this stage have been spawned")  # DEBUG

func _on_stage_started(stage_number):
	print("EnemySpawn: _on_stage_started called for stage ", stage_number)  # DEBUG
	
	var data = StageManager.get_current_stage_data()
	spawn_time = data["spawn_rate"]
	enemies_to_spawn = data["enemy_count"]
	spawn_active = true
	timer = spawn_time * 0.5
	
	print("Stage ", stage_number, " setup:")  # DEBUG
	print("  - enemies_to_spawn: ", enemies_to_spawn)  # DEBUG
	print("  - spawn_time: ", spawn_time)  # DEBUG
	print("  - spawn_active: ", spawn_active)  # DEBUG

func _on_stage_completed(stage_number):
	print("EnemySpawn: Stage ", stage_number, " completed, stopping spawn")  # DEBUG
	spawn_active = false
	enemies_to_spawn = 0

func _spawn_enemy():
	if not enemy_scene:
		print("EnemySpawn: ERROR - enemy_scene is null!")  # DEBUG
		return
	
	var camera = get_viewport().get_camera_2d()
	if not camera:
		print("EnemySpawn: ERROR - camera not found!")  # DEBUG
		return
	
	print("EnemySpawn: Spawning enemy...")  # DEBUG
	
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
	
	# Set enemy stats based on current stage
	var data = StageManager.get_current_stage_data()
	enemy.health = data["enemy_health"]
	enemy.speed = data["enemy_speed"]
	
	# Connect to enemy's death signal
	enemy.died.connect(_on_enemy_died)
	
	get_parent().add_child(enemy)
	print("EnemySpawn: Enemy added to scene at position: ", enemy.global_position)  # DEBUG

func _on_enemy_died():
	print("EnemySpawn: Enemy died signal received")  # DEBUG
	StageManager.enemy_died()
