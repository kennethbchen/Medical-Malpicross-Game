extends Node2D

@export var length: float = 40

@export var iterations: int = 10

@export var node_count: int = 18

var gravity: Vector2 = Vector2(0, 900)

var nodes: Array[VerletNode]
var segments: Array[VerletSegment]

func _ready() -> void:
	
	var pos: = Vector2(30, 30)
	for i in range(node_count):
		nodes.append(VerletNode.new(pos))
		pos.x += length
	
	nodes[-1].fixed = true
	
	for i in range(len(nodes) - 1):
		segments.append(VerletSegment.new(self, nodes[i], nodes[i + 1]))
	


func _physics_process(delta: float) -> void:
	
	simulate(delta)
	
	for _i in range(iterations):
		apply_constraints()
		
	queue_redraw()
	
func simulate(delta: float):
	
	for i in range(len(nodes)):
		
		if nodes[i].fixed:
			continue
			
		var temp: Vector2 = nodes[i].position
		nodes[i].position += (nodes[i].position - nodes[i].old_position) + (gravity * delta * delta)
		nodes[i].old_position = temp

func apply_constraints():
	
	for i in range(0, len(segments)):
		
		var segment: VerletSegment = segments[i]
		
		var center: Vector2 = (segment.point_a.position + segment.point_b.position) / 2
		var dir: Vector2 = (segment.point_a.position - segment.point_b.position).normalized()
		var cur_length: float = segment.point_a.position.distance_to(segment.point_b.position)
		
		# Constrain points based on the original length of this segment
		
		if !segment.point_a.fixed:
			segment.point_a.position = center + dir * segment.original_length / 2
			
		if !segment.point_b.fixed:
			segment.point_b.position = center - dir * segment.original_length / 2

func _draw():
	draw_line(position, position + Vector2(10, 0), Color.RED)

	for i in range(len(segments)):
		var color: Color = Color.WHITE
		draw_line(segments[i].point_a.position, segments[i].point_b.position, color, 4)
		
	for i in range(len(nodes)):
		draw_circle(nodes[i].position, 4, Color.LIGHT_GREEN, 5)
		
# https://toqoz.fyi/game-rope.html
# https://github.com/SebLague/Cloth-and-IK-Test/blob/main/Assets/Scripts/Simulation/Simulation.cs

class VerletNode:
	extends RefCounted
	
	var position: Vector2
	var old_position: Vector2
	
	var fixed: bool = false
	
	func _init(init_position: Vector2) -> void:
		position = init_position
		old_position = init_position

class VerletSegment:
	extends RefCounted
		
	var point_a: VerletNode
	var point_b: VerletNode
	
	var original_length: float
	
	var current_length: float:
		get:
			return point_a.position.distance_to(point_b.position)
	
	func _init(parent_node: Node, a: VerletNode, b: VerletNode):
		point_a = a
		point_b = b
		original_length = a.position.distance_to(b.position)
		
