extends Node2D

var k = 0.015
var d = 0.03
@export var spread = 0.0002
@export var passes = 8
var springs = []

@export var distance_between_springs = 32
@export var spring_number = 6

var water_length = distance_between_springs * spring_number
var water_spring = preload("res://Scenes/water_spring.tscn").instantiate()

@export var depth = 1000
var target_height = global_position.y
var bottom = target_height + depth

var water_polygon



func _ready():
	water_polygon = $Water_Polygon
	for i in range(spring_number):
		var x_position = distance_between_springs * i
		var w = water_spring.duplicate()
		if w:
			add_child(w)
			springs.append(w)
			w.initialize(x_position, i)
			w.set_collision_width(distance_between_springs)
			w.connect("splash", splash)
	
	splash(2,5)

func _physics_process(delta):
	for i in springs:
		i.water_update(k,d)
	var left_deltas = []
	var right_deltas = []
	
	for i in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
		pass
	
	draw_water_body()
	
	for j in range(passes):
		for i in range(springs.size()):
			if i > 0:
				left_deltas[i] = spread * (springs[i].height - springs[i-1].height)
				springs[i-1].velocity += left_deltas[i]
			if i < springs.size()-1:
				right_deltas[i] = spread * (springs[i].height - springs[i+1].height)
				springs[i+1].velocity += right_deltas[i]
func splash(index, speed):
	if index >= 0 and index < springs.size():
		springs[index].velocity += speed
	
	
	pass
	
func draw_water_body():
	var surface_points = []
	
	for i in range(springs.size()):
		surface_points.append(springs[i].position)
		
		
	var first_index = 0
	var last_index = surface_points.size()-1
	
	var water_polygon_points = surface_points
	
	water_polygon_points.append(Vector2(surface_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(surface_points[first_index].x, bottom))
	
	water_polygon_points = PackedVector2Array(water_polygon_points)
	
	water_polygon.set_polygon(water_polygon_points)
	
