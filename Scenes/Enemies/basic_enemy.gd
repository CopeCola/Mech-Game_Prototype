extends CharacterBody2D
class_name BasicEnemy

signal enemy_died

@onready var enemy_remains = preload("res://Scenes/Enemies/enemy_remains.tscn")
@onready var exploding_drone = preload("res://Scenes/Enemies/exploding_drone_enemy.tscn")
@onready var drone_container = get_tree().get_first_node_in_group("enemy_drone_container")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var basic_enemy_gun: EnemyGun = $BasicEnemyGun
@onready var drone_deploy_marker: Marker2D = $DroneDeployPos
@onready var drone_deploy_timer: Timer = $DroneDeployTimer

@export var rush_distance: float = 500
@export var retreat_distance: float = 200
@export var stop_distance: float = 300
@export var retreat_speed_multiplier: float = 1.2
@export var rush_speed_multiplier: float = 2

@export var enemy_speed: int = 10000
@export var max_health: int = 6
var current_health: int 

var can_deploy_drones: bool = false
var is_dying:= false



func _ready() -> void:
	drone_deploy_timer.wait_time = randf_range(4,12)
	current_health = max_health


func _process(delta: float) -> void:
	if GameManager.small_mech == null:
		handle_mech_movement(delta)
	else:
		handle_small_mech_movement(delta)


func handle_mech_movement(delta):
	var distance_to_mech = global_position.distance_to(GameManager.mech_pos)
	var direction_to_mech = global_position.direction_to(GameManager.mech_pos)
	if distance_to_mech > rush_distance:
		velocity = direction_to_mech * enemy_speed * rush_speed_multiplier * delta
	
	elif distance_to_mech < retreat_distance:
		# Move away 
		velocity = -direction_to_mech * enemy_speed * retreat_speed_multiplier * delta
		
	elif distance_to_mech <= stop_distance:
		# Stop completely
		velocity = Vector2.ZERO
	
	else:
		# Move toward normally
		velocity = direction_to_mech * enemy_speed * delta

	move_and_slide()


func handle_small_mech_movement(delta):
	var distance_to_small_mech = global_position.distance_to(GameManager.small_mech_pos)
	var direction_to_small_mech = global_position.direction_to(GameManager.small_mech_pos)
	if distance_to_small_mech > rush_distance:
		velocity = direction_to_small_mech * enemy_speed * rush_speed_multiplier * delta
		
	elif distance_to_small_mech < retreat_distance:
		# Move away 
		velocity = -direction_to_small_mech * enemy_speed * retreat_speed_multiplier * delta
		
	elif distance_to_small_mech <= stop_distance:
		# Stop completely
		velocity = Vector2.ZERO
		
	else:
		# Move toward normally
		velocity = direction_to_small_mech * enemy_speed * delta

	move_and_slide()


func deploy_drones(drone_scene):
	var drone_instance = drone_scene.instantiate()
	drone_container.add_child(drone_instance)
	drone_instance.global_position = drone_deploy_marker.global_position


func take_damage(amount):
	current_health -= amount
	animation_player.play("take_damage")
	death()


func death():
	if current_health <= 0 and not is_dying:
		is_dying = true
		await animation_player.animation_finished
		call_deferred("spawn_remains")
		call_deferred("queue_free")


func spawn_remains():
	var remains_instance = enemy_remains.instantiate()
	remains_instance.global_position = global_position
	get_tree().get_first_node_in_group("dead_enemy_container").add_child(remains_instance)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("mech"):
		basic_enemy_gun.can_shoot = true
	
	if body.is_in_group("small_mech"):
		basic_enemy_gun.can_shoot = true
		can_deploy_drones = true

	elif body.is_in_group("pilot"):
		can_deploy_drones = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("mech"):
		basic_enemy_gun.can_shoot = false
	
	if body.is_in_group("small_mech"):
		basic_enemy_gun.can_shoot = false
		can_deploy_drones = false

	if body.is_in_group("pilot"):
		can_deploy_drones = false


func _on_drone_deploy_timer_timeout() -> void:
	if can_deploy_drones:
		$DroneDeployTimer.wait_time = randf_range(6,12)
		deploy_drones(exploding_drone)
