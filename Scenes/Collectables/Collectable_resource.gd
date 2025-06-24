extends Resource
class_name Collectable

enum CollectableType {
	AMMO, 
	FUEL,
	UPGRADE_MODULE
}

@export var type: CollectableType
@export var texture: Texture2D
@export var description: String
@export var color: Color
@export var amount: int
