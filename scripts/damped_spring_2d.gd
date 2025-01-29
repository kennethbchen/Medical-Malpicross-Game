@tool
extends Node2D

@export var damping_ratio: float = 0
@export var angular_frequency: float = 20

@export var draw_spring: bool = false

var spring_position: Vector2
var spring_velocity: Vector2

func _ready() -> void:
	spring_position = global_position

func _physics_process(delta: float) -> void:

	simulate_spring(delta)
	queue_redraw()
	
"""
	Implementation of:
	https://github.com/TheAllenChou/numeric-springing

	damping_ratio = zeta
	angular_frequency = omega
"""
func simulate_spring(delta: float):
	
	
	var target_position: Vector2 = global_position
	
	var f = 1.0 + 2.0 * delta * damping_ratio * angular_frequency
	var oo = angular_frequency * angular_frequency
	var hoo = delta * oo
	var hhoo = delta * hoo
	
	var det_inv = 1.0 / (f + hhoo)
	var det_x = f * spring_position + delta * spring_velocity + hhoo * target_position
	var det_v = spring_velocity + hoo * (target_position - spring_position)
	spring_position = det_x * det_inv
	spring_velocity = det_v * det_inv
	
func _draw() -> void:
	if draw_spring:
		draw_circle(spring_position - global_position, 2, Color.WHITE)
		draw_line(spring_position - global_position, Vector2.ZERO, Color.WHITE)
