extends Node2D
class_name MechGun

@onready var basic_bullet = preload("res://Scenes/Weapons/basic_bullet.tscn")
@onready var barrel_end = $BarrelEnd

var can_tripple_shot:bool = false
var can_shoot:bool = true 
var single_shot_cooldown_time: float = .2
var triple_shot_cooldown_time: int = 1

var single_shot_damage = 3
var triple_shot_damage = 6

func _input(event: InputEvent) -> void:
	pass
	#if GameManager.in_mech:
		#if Input.is_action_pressed("shoot"):
			#shoot_mech_weapon(basic_bullet)
		#if Input.is_action_pressed("toggle_fire_mode"):
			#can_tripple_shot = not can_tripple_shot


func _process(delta: float) -> void:
	if GameManager.in_mech:
		look_at(get_global_mouse_position())
		if Input.is_action_pressed("shoot"):
			shoot_mech_weapon(basic_bullet)
		if Input.is_action_just_pressed("toggle_fire_mode"):
			can_tripple_shot = not can_tripple_shot


func shoot_mech_weapon(bullet_scene:PackedScene):
	if can_tripple_shot and can_shoot:
		for i in 3:
			can_shoot = false
			var bullet_instance = bullet_scene.instantiate()
			bullet_instance.damage = triple_shot_damage
			var inc = (i - 1) * 0.3
			bullet_instance.scale = Vector2(2,2)
			bullet_instance.global_position = barrel_end.global_position
			bullet_instance.global_rotation = (global_rotation + inc)
			get_tree().get_first_node_in_group("bullet_container").add_child(bullet_instance)
		await get_tree().create_timer(triple_shot_cooldown_time).timeout
		can_shoot = true
	else:
		if can_shoot:
			can_shoot = false
			var bullet_instance = bullet_scene.instantiate()
			bullet_instance.damage = single_shot_damage
			bullet_instance.global_position = barrel_end.global_position
			bullet_instance.global_rotation = global_rotation
			get_tree().get_first_node_in_group("bullet_container").add_child(bullet_instance)
			await get_tree().create_timer(single_shot_cooldown_time).timeout
			can_shoot = true
