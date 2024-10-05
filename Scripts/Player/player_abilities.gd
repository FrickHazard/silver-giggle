extends Node

@export var abilities: Array[BaseAbility] = []
var current_ability_index: int = 0

func _ready():

	update_current_ability()

func cycle_ability_right():
	abilities[current_ability_index].unequip()
	
	current_ability_index = (current_ability_index + 1) % abilities.size()
	update_current_ability()

func cycle_ability_left():
	abilities[current_ability_index].unequip()
	
	current_ability_index = (current_ability_index - 1 + abilities.size()) % abilities.size()
	update_current_ability()

func use_ability():
	var current_ability: BaseAbility = abilities[current_ability_index]
	current_ability.use(Input.get_vector("move_left", "move_right", "move_down", "move_up"))

func update_current_ability():
	abilities[current_ability_index].equip()

func _input(event):
	if event.is_action_pressed("cycle_ability_left"):
		cycle_ability_left()
	elif event.is_action_pressed("cycle_ability_right"):
		cycle_ability_right()
	elif event.is_action_pressed("use_ability"):
		use_ability()
