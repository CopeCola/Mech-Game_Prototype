extends Node2D

@onready var basic_enemy = preload("res://Scenes/Enemies/basic_enemy.tscn")
@onready var spawn_pos_container: Node2D = $SpawnPosContainer
@onready var enemy_container: Node2D = get_tree().get_first_node_in_group("enemy_container")

func get_enemy_count():
	return enemy_container.get_child_count()


func spawn_enemy(enemy_scene:PackedScene):
	if get_enemy_count() < 20:
		var enemy_instance = enemy_scene.instantiate()
		enemy_container.add_child(enemy_instance)
		var random_spawn_pos = spawn_pos_container.get_children().pick_random().global_position
		enemy_instance.global_position = random_spawn_pos


func _on_timer_timeout() -> void:
	spawn_enemy(basic_enemy)
