extends Node2D
class_name PilotGun

@onready var basic_bullet = preload("res://Scenes/Weapons/basic_bullet.tscn")
@onready var barrel_end = $BarrelEnd


var can_shoot:bool = true 
var single_shot_cooldown_time: float = .1


var single_shot_damage = 2


func _ready() -> void:
	GameManager.current_pilot_ammo = GameManager.max_pilot_ammo

func _input(event: InputEvent) -> void:
	if not GameManager.in_mech:
		if event.is_action_pressed("reload"):
			reload_gun()


func _process(_delta: float) -> void:
	if not GameManager.in_mech:
		look_at(get_global_mouse_position())
		if Input.is_action_pressed("shoot") and GameManager.current_pilot_ammo > 0:
			shoot_pilot_weapon(basic_bullet)


func shoot_pilot_weapon(bullet_scene:PackedScene):
	if can_shoot:
			can_shoot = false
			var bullet_instance = bullet_scene.instantiate()
			bullet_instance.damage = single_shot_damage
			bullet_instance.scale = Vector2(.3,.3)
			bullet_instance.global_position = barrel_end.global_position
			bullet_instance.global_rotation = global_rotation
			GameManager.current_pilot_ammo -= 1
			get_tree().get_first_node_in_group("bullet_container").add_child(bullet_instance)
			await get_tree().create_timer(single_shot_cooldown_time).timeout
			can_shoot = true
	
	#if can_tripple_shot and can_shoot:
		#for i in 3:
			#can_shoot = false
			#var bullet_instance = bullet_scene.instantiate()
			#var inc = (i - 1) * 0.5
			#bullet_instance.scale = Vector2(2,2)
			#bullet_instance.global_position = barrel_end.global_position
			#bullet_instance.global_rotation = (global_rotation + inc)
			#get_tree().get_first_node_in_group("bullet_container").add_child(bullet_instance)
		#await get_tree().create_timer(triple_shot_cooldown_time).timeout
		#can_shoot = true


func reload_gun():
	GameManager.current_pilot_ammo = GameManager.max_pilot_ammo
