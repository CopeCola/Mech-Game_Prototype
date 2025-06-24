extends CharacterBody2D
class_name Pilot

signal was_ejected
signal entered_mech
signal entered_small_mech
signal repaired_mech(repair_value)

@onready var pilot_gun_scene = preload("res://Scenes/Weapons/pilot_gun.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: TextureProgressBar = $TextureProgressBar


@export var pilot_speed: int = 10000

var direction: Vector2

var can_interact_with_mech:bool = false
var can_interact_with_small_mech: bool = false
var repair_value: int = 2


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("enter_mech"):
		if can_interact_with_mech:
			GameManager.in_mech = true
			GameManager.emit_signal("camera_state_changed", MainCamera.CameraState.ON_MECH)
			emit_signal("entered_mech")
			call_deferred("queue_free")
		if GameManager.in_small_mech == false and can_interact_with_small_mech:
			GameManager.in_small_mech = true
			GameManager.emit_signal("camera_state_changed", MainCamera.CameraState.ON_SMALL_MECH)
			emit_signal("entered_small_mech")
			call_deferred("queue_free")
			
	if Input.is_action_just_pressed("repair_mech"):
		repair_mech(repair_value)


func _ready() -> void:
	GameManager.pilot = self
	emit_signal("was_ejected")
	instantiate_gun(pilot_gun_scene)
	health_bar.max_value = GameManager.pilot_health
	health_bar.value = GameManager.pilot_health


func _process(delta: float) -> void:
	if not GameManager.in_mech:
		handle_movement(delta)
		GameManager.pilot_pos = global_position


func get_move_vector():
	var x_vec = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_vec = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_vec,y_vec).normalized()


func handle_movement(delta_time):
	direction = get_move_vector()
	velocity = direction * pilot_speed * delta_time
	move_and_slide()


func instantiate_gun(gun_scene: PackedScene):
	var gun_instance = gun_scene.instantiate()
	self.add_child(gun_instance)
	gun_instance.global_position = global_position


func repair_mech(amount):
	if can_interact_with_mech:
		var mech = GameManager.mech
		if mech.current_health < mech.max_health:
			mech.current_health += amount
			mech.health_bar.value += amount
			emit_signal("repaired_mech")
	if can_interact_with_small_mech:
		var small_mech = GameManager.small_mech
		if GameManager.small_mech_health < GameManager.max_small_mech_health:
			GameManager.small_mech_health += amount
			small_mech.health_bar.value += amount
			emit_signal("repaired_mech")


func collect(resource: Collectable) -> void:
	match resource.type:
		Collectable.CollectableType.AMMO:
			GameManager.current_pilot_ammo += resource.amount
		Collectable.CollectableType.FUEL:
			GameManager.current_fuel_amount += resource.amount
		Collectable.CollectableType.UPGRADE_MODULE:
			pass
	print("Collected: ",resource.amount," ", resource.description)



func take_damage(amount):
	animation_player.play("take_damage")
	await animation_player.animation_finished
	GameManager.pilot_health -= amount
	update_health()


func update_health():
	health_bar.value = GameManager.pilot_health
	if GameManager.pilot_health <= 0:
		death()


func death():
	GameManager.on_pilot_death()


func _on_interact_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mech"):
		can_interact_with_mech = true
	if area.is_in_group("small_mech"):
		can_interact_with_small_mech = true
		
	if area.is_in_group("survivor"):
		area.queue_free()
		GameManager.score += 1


func _on_interact_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("mech"):
		can_interact_with_mech = false
	if area.is_in_group("small_mech"):
		can_interact_with_small_mech = false
