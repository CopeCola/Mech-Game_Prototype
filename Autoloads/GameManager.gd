extends Node

signal camera_state_changed(new_state)


var pilot: CharacterBody2D
var pilot_pos: Vector2
var mech: CharacterBody2D
var mech_pos: Vector2
var small_mech: CharacterBody2D
var small_mech_pos: Vector2


@onready var score: int = 0

@onready var in_mech: bool = true
@onready var in_small_mech: bool = false

@onready var max_pilot_ammo: int = 100
@onready var current_pilot_ammo: int 

@onready var max_mech_ammo: int = 10
@onready var current_mech_ammo: int = 10

@onready var max_enemy_ammo: int
@onready var current_enemy_ammo: int

@onready var max_pilot_health: int = 10
@onready var pilot_health: int = 10

@onready var max_small_mech_health: int = 20
@onready var small_mech_health: int = 20

@onready var max_fuel_amount: int = 100
@onready var current_fuel_amount: int 



func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func on_pilot_death():
	print("pilot died")
	pilot_health = max_pilot_health
	pilot.update_health()
