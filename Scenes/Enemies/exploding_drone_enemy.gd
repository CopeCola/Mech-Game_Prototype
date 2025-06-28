extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed: float = 150.0
@export var zigzag_frequency: float = 10.0  # How often they zigzag
@export var zigzag_amount: float = 5.0   # How far they deviate
@export var turn_speed: float = 5.0      # How quickly they adjust direction

var pilot 
var mech
var small_mech

var direction: Vector2

var damage: int = 2
var time: float = 0.0

var max_health: int = 1
var current_health: int

var current_target: CharacterBody2D


func _ready():
	current_health = max_health
	pilot = GameManager.pilot
	small_mech = GameManager.small_mech
	mech = GameManager.mech



func _process(delta):
	time += delta

	if is_instance_valid(pilot):
		direction = (GameManager.pilot_pos - global_position).normalized()

	elif is_instance_valid(small_mech):
		direction = (GameManager.small_mech_pos - global_position).normalized()

	else:
		direction = (GameManager.mech_pos - global_position).normalized()


		# Add perpendicular offset for zigzag effect
	var perpendicular = Vector2(-direction.y, direction.x)
	var zigzag_offset = perpendicular * sin(time * zigzag_frequency) * zigzag_amount
		# Combine directions
	var final_direction = (direction + zigzag_offset).normalized()
	
		# Move with rotation toward movement direction
	rotation = lerp_angle(rotation, final_direction.angle(), turn_speed * delta)
	position += final_direction * speed * delta
	move_and_slide()


func get_closest_valid_target():
	pass

func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		death()


func explode():
	if is_instance_valid(pilot):
		animation_player.play("explode")
		await animation_player.animation_finished
		sprite_2d.queue_free()
		cpu_particles_2d.emitting = true
		await get_tree().create_timer(.3).timeout
		if is_instance_valid(pilot):
			pilot.take_damage(damage)
			queue_free()
	if is_instance_valid(mech):
		animation_player.play("explode")
		await animation_player.animation_finished
		sprite_2d.queue_free()
		cpu_particles_2d.emitting = true
		await get_tree().create_timer(.3).timeout
		if is_instance_valid(mech):
			mech.take_damage(damage)
			queue_free()
	if is_instance_valid(small_mech):
		animation_player.play("explode")
		await animation_player.animation_finished
		sprite_2d.queue_free()
		cpu_particles_2d.emitting = true
		await get_tree().create_timer(.3).timeout
		if is_instance_valid(small_mech):
			small_mech.take_damage(damage)
			queue_free()
	


func death():
	animation_player.play("explode")
	await animation_player.animation_finished
	queue_free()


func _on_explode_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("pilot") :
		explode()
	if body.is_in_group("mech"):
		explode()
	if body.is_in_group("small_mech"):
		explode()
