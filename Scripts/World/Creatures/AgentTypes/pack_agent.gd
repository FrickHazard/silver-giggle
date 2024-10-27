extends BaseAgent

@export var pack_leader : Node2D

func _ready() -> void:
	super._ready()

func _process(delta) -> void:
	super._process(delta)
	
	if pack_leader != null:
		pathfinding.target_position = pack_leader.position
		super._follow_path()
	
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
