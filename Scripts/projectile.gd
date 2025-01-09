extends RigidBody2D

@export var damage: int = 1
@export var is_dangerous : bool = true

@export var particles : GPUParticles2D
@export var collider : CollisionShape2D

@export var sound_player : AudioStreamPlayer2D
@export var collision_sound : AudioStream

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if !is_dangerous: 
		return
	
	particles.emitting = true
	sound_player.stream = collision_sound
	sound_player.play()
	is_dangerous = false
	#collider.visible = false
	

	for child in body.get_children():
		if !is_instance_valid(child):
			return
		if child.has_method("_take_damage"):
			child._take_damage(damage)

	await get_tree().create_timer(1).timeout
	queue_free()
	
	pass
