extends Node2D

# https://lisyarus.github.io/blog/posts/soft-body-physics.html

class_name PointMassSim

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
