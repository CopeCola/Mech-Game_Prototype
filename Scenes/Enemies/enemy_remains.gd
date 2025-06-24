extends Node2D

@onready var spawn_points: Node2D = $SpawnPoints
@onready var collectable = preload("res://Scenes/Collectables/Collectable.tscn")
@export var possible_drops: Array[Collectable] = []
@export var drop_count: int = 1

func _ready() -> void:
	drop_items()

func drop_items() -> void:
	for i in range(min(drop_count, possible_drops.size())):
		var random_drop = possible_drops.pick_random().duplicate()
		spawn_collectable(random_drop)


func spawn_collectable(drop_data: Collectable) -> void:
	var collectable_instance = collectable.instantiate()
	collectable_instance.resource_data = drop_data
	#print(drop_data)
	get_tree().get_first_node_in_group("collectable_container").add_child(collectable_instance)
	var rand_spawn_point = spawn_points.get_children().pick_random()
	collectable_instance.global_position = rand_spawn_point.global_position
	
