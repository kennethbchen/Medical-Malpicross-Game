extends Node2D

var points: Array[PointMassSim.PointMass]
var constraints: Array[PointMassSim.SpringConstraint]

var gravity: Vector2 = Vector2(0,900)

func _ready() -> void:
	var point_count: int = 20
	var length: float = 40

	var pos: = Vector2(30, 30)
	for i in range(point_count):
		points.append(PointMassSim.PointMass.new(pos))
		pos.x += length
	
	points[0].fixed = true
	points[-1].fixed = true
	
	for i in range(len(points) - 1):
		constraints.append(PointMassSim.SpringConstraint.new(points[i], points[i + 1], length, 500))

func _physics_process(delta: float) -> void:
	
	_simulate(delta)
	
	for constraint in constraints:
		constraint._resolve_constraint(delta)
		
	queue_redraw()

func _simulate(delta: float) -> void:
	# Gravity
	for point in points:
		point.velocity += gravity * delta
	
	# Symplectic Euler integration
	for point in points:
		
		if point.fixed:
			point.velocity = Vector2.ZERO
			continue
		
		point.position += point.velocity * delta

func _draw():

	for i in range(len(constraints)):
		var color: Color = Color.WHITE
		draw_line(constraints[i].point_a.position, constraints[i].point_b.position, color, 4)
		
	for i in range(len(points)):

		draw_circle(points[i].position, 4, Color.LIGHT_GREEN, 5)
