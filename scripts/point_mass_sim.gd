extends Node2D

# https://lisyarus.github.io/blog/posts/soft-body-physics.html



var points: Array[PointMass]
var constraints: Array[SpringConstraint]

var gravity: Vector2 = Vector2(0,900)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var point_count: int = 20
	var length: float = 40

	var pos: = Vector2(30, 30)
	for i in range(point_count):
		points.append(PointMass.new(pos))
		pos.x += length
	
	points[0].fixed = true
	points[-1].fixed = true
	
	for i in range(len(points) - 1):
		constraints.append(SpringConstraint.new(points[i], points[i + 1], length, 500))


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		
class PointMass:
	extends RefCounted
	
	var position: Vector2
	var velocity: Vector2
	
	var fixed: bool = false
	
	func _init(init_position: Vector2) -> void:
		position = init_position

class SpringConstraint:
	extends RefCounted
	
	var point_a: PointMass
	var point_b: PointMass
	
	var length: float
	var spring_force: float
	var damping: float
	
	func _init(a: PointMass, b: PointMass, length: float = -1, spring_force: float = 100, damping: float = 10):
		
		self.point_a = a
		self.point_b = b
		
		if length <= 0:
			self.length = self.point_a.position.distance_to(self.point_b.position)
		else:
			self.length = length
		
		self.spring_force = spring_force
		self.damping = damping
	
	func _resolve_constraint(delta_time: float):
		
		var position_delta = self.point_b.position - self.point_a.position
		var current_distance = position_delta.length()
		var direction = position_delta / current_distance
		
		var required_delta = position_delta * (self.length / current_distance)
		var force = self.spring_force * (required_delta - position_delta)
		
		self.point_a.velocity -= force * delta_time
		self.point_b.velocity += force * delta_time
		
		# Apply damping
		var relative_velocity: float = (self.point_b.velocity - self.point_a.velocity).dot(direction)
		var damping_factor: float = exp(- self.damping * delta_time)
		var new_relative_velocity = relative_velocity * damping_factor
		var relative_velocity_delta = new_relative_velocity - relative_velocity
		
		self.point_a.velocity -= direction * (relative_velocity_delta / 2.0)
		self.point_b.velocity += direction * (relative_velocity_delta / 2.0)
