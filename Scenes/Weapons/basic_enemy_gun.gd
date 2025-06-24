extends Node2D
class_name EnemyGun

@onready var basic_enemy_bullet = preload("res://Scenes/Weapons/basic_enemy_bullet.tscn")
@onready var barrel_end = $BarrelEnd
@onready var mech = GameManager.mech
@onready var current_target: CharacterBody2D = mech

var can_shoot:bool = false

var single_shot_damage = 1


func _ready() -> void:
	pass
	

func _process(delta: float) -> void:
	if GameManager.small_mech == null:
		look_at(GameManager.mech_pos)
	else:
		look_at(GameManager.small_mech_pos)


func target_small_mech(target):
	current_target = target


func target_mech(target):
	current_target = target


func shoot_enemy_weapon(bullet_scene:PackedScene):
	var bullet_instance = bullet_scene.instantiate()
	#bullet_instance.damage = single_shot_damage
	bullet_instance.scale = Vector2(.3,.3)
	bullet_instance.global_position = barrel_end.global_position
	bullet_instance.global_rotation = global_rotation
	#GameManager.current_enemy_ammo -= 1
	get_tree().get_first_node_in_group("enemy_bullet_container").add_child(bullet_instance)



func _on_timer_timeout() -> void:
	if can_shoot:
		$Timer.wait_time = randf_range(3,6)
		shoot_enemy_weapon(basic_enemy_bullet)
