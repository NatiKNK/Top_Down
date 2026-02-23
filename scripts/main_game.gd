# main_game.gd (Attach to your root node)
extends Node2D

@onready var stage_label = $UI/StageLabel
@onready var enemies_left_label = $UI/EnemiesLeftLabel
@onready var stage_complete_label = $UI/StageCompleted
@onready var enemy_spawner = $EnemySpawner  # Adjust path as needed
@onready var StageManager = get_node("/root/StageManager")

func _ready():
	# Connect to StageManager signals
	StageManager.stage_started.connect(_on_stage_started)
	StageManager.stage_completed.connect(_on_stage_completed)
	StageManager.all_stages_completed.connect(_on_all_stages_completed)
	StageManager.enemies_count_updated.connect(_on_enemies_count_updated)
	
	# Hide stage complete label at start
	if stage_complete_label:
		stage_complete_label.visible = false
	
	# Start the game
	StageManager.start_stage(1)

func _on_stage_started(stage_number):
	# Update UI
	if stage_label:
		stage_label.text = "STAGE " + str(stage_number)
	
	if stage_complete_label:
		stage_complete_label.visible = false
	
	# Update enemies left count
	var data = StageManager.get_current_stage_data()
	_on_enemies_count_updated(data["enemy_count"])
	
	print("Main: Stage ", stage_number, " started")

func _on_stage_completed(stage_number):
	print("Main: Stage ", stage_number, " completed!")
	
	# Show stage complete message
	if stage_complete_label:
		stage_complete_label.text = "STAGE " + str(stage_number) + " COMPLETE!"
		stage_complete_label.visible = true
	
	# If there are more stages, start next stage after delay
	if stage_number < StageManager.total_stages:
		await get_tree().create_timer(2.0).timeout
		StageManager.go_to_next_stage()
	# If this was the last stage, show victory
	else:
		await get_tree().create_timer(2.0).timeout
		_on_all_stages_completed()

func _on_all_stages_completed():
	print("Main: ALL STAGES COMPLETED! Victory!")
	if stage_complete_label:
		stage_complete_label.text = "VICTORY! You win!"
		stage_complete_label.visible = true
	
	# You could show a victory screen here, return to menu, etc.

func _on_enemies_count_updated(count):
	if enemies_left_label:
		enemies_left_label.text = "Enemies: " + str(count)
