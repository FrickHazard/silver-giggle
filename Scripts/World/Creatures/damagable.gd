class_name Damagable
extends Node

@export var max_hp : int = 10
var current_hp : int

func _ready():
	current_hp = max_hp

func _take_damage(damage : int):
	current_hp -= damage
	if(current_hp <= 0):
		_die()
	pass

func _die():
	get_owner().queue_free()
	pass
