extends BaseAgent

@export var separation_radius: float = 30.0
@export var alignment_strength: float = 0.1
@export var cohesion_strength: float = 0.05
@export var separation_strength: float = 0.2

var neighbors: Array
var velocity_change: Vector2

func _ready() -> void:
	super._ready()
	neighbors = []

func _process(delta: float) -> void:
	super._process(delta)
	if current_state == State.ACTIVE:
		_apply_pack_behaviors()
	else:
		velocity.x = 0

func _apply_pack_behaviors():
	neighbors = _get_neighbors()
	
	var separation_force = _separation()
	var alignment_force = _alignment()
	var cohesion_force = _cohesion()
	
	velocity_change = 100* (separation_force * separation_strength) + (alignment_force * alignment_strength) + (cohesion_force * cohesion_strength)
	
	# Only apply the pack algorithm to the x axis (horizontal movement)
	velocity.x += velocity_change.x

	# Let gravity, jumping, and other vertical forces handle y velocity naturally
	move_and_slide()

func _get_neighbors() -> Array:
	var agents_in_radius: Array = []
	for other in get_tree().get_nodes_in_group("pack_agents"):
		if other != self:
			var distance = global_position.distance_to(other.global_position)
			if distance < separation_radius:
				agents_in_radius.append(other)
	return agents_in_radius

func _separation() -> Vector2:
	var separation_vector = Vector2.ZERO
	for neighbor in neighbors:
		var distance_vector = global_position - neighbor.global_position
		if distance_vector.length() > 0:
			separation_vector += distance_vector.normalized() / distance_vector.length()
	return separation_vector

func _alignment() -> Vector2:
	if neighbors.is_empty():
		return Vector2.ZERO

	var average_velocity = Vector2.ZERO
	for neighbor in neighbors:
		average_velocity += neighbor.velocity
	average_velocity /= neighbors.size()
	
	return (average_velocity - velocity).normalized()

func _cohesion() -> Vector2:
	if neighbors.is_empty():
		return Vector2.ZERO
	
	var center_of_mass = Vector2.ZERO
	for neighbor in neighbors:
		center_of_mass += neighbor.global_position
	center_of_mass /= neighbors.size()
	
	return (center_of_mass - global_position).normalized()

func _on_day_state_changed(new_state):
	super._on_day_state_changed(new_state)
