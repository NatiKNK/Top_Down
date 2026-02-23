# stage_manager.gd (Autoload)
extends Node

signal stage_started(stage_number)
signal stage_completed(stage_number)
signal all_stages_completed
signal enemies_count_updated(count)

var current_stage: int = 1
var total_stages: int = 5  # Change this to your desired number
var enemies_in_current_stage: int = 0
var enemies_defeated_in_stage: int = 0

# Stage configuration - customize this!
var stage_data = {
	1: {
		"enemy_count": 5,
		"spawn_rate": 2.0,
		"enemy_health": 2,
		"enemy_speed": 150
	},
	2: {
		"enemy_count": 8,
		"spawn_rate": 1.8,
		"enemy_health": 2,
		"enemy_speed": 160
	},
	3: {
		"enemy_count": 10,
		"spawn_rate": 1.5,
		"enemy_health": 3,
		"enemy_speed": 170
	},
	4: {
		"enemy_count": 12,
		"spawn_rate": 1.2,
		"enemy_health": 3,
		"enemy_speed": 180
	},
	5: {
		"enemy_count": 15,
		"spawn_rate": 1.0,
		"enemy_health": 4,
		"enemy_speed": 200
	}
}

func _ready():
	# Automatically reset when game starts
	reset()

func start_stage(stage: int = current_stage):
	current_stage = stage
	enemies_in_current_stage = stage_data[current_stage]["enemy_count"]
	enemies_defeated_in_stage = 0
	emit_signal("stage_started", current_stage)
	print("Starting Stage ", current_stage)

func enemy_died():
	enemies_defeated_in_stage += 1
	emit_signal("enemies_count_updated", enemies_in_current_stage - enemies_defeated_in_stage)
	
	print("Enemy defeated! ", enemies_defeated_in_stage, "/", enemies_in_current_stage)
	
	if enemies_defeated_in_stage >= enemies_in_current_stage:
		complete_current_stage()

func complete_current_stage():
	emit_signal("stage_completed", current_stage)
	
	if current_stage < total_stages:
		# Don't auto-start next stage - let main scene handle it with a delay
		print("Stage ", current_stage, " complete! Ready for next stage")
	else:
		emit_signal("all_stages_completed")
		print("Congratulations! All stages completed!")

func go_to_next_stage():
	if current_stage < total_stages:
		current_stage += 1
		start_stage(current_stage)

func reset():
	current_stage = 1
	enemies_in_current_stage = 0
	enemies_defeated_in_stage = 0

func get_current_stage_data():
	return stage_data[current_stage]
