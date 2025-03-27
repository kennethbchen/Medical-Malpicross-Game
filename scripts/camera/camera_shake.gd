extends Node3D

# https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html
# https://www.youtube.com/watch?v=tu-Qe66AvtY

@export_group("Noise")
@export var pitch_noise: Noise
@export var yaw_noise: Noise
@export var roll_noise: Noise

@export_group("Shake")
@export var max_pitch: float = 10	
@export var max_yaw: float = 10
@export var max_roll: float = 10

@export var decay: float = 0.7

@export var trauma_power: float = 2

var trauma: float = 0:
	set(value):
		trauma = clamp(value, 0.0, 1.0)

func _ready() -> void:
	EventBus.screen_shake_requested.connect(add_trauma)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_shake_camera"):
		add_trauma(0.5)

func _process(delta: float) -> void:
	# trauma goes down over time
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
	
	# rotate
	var shake_amount: float = pow(trauma, trauma_power)
	rotation_degrees.x = max_pitch * shake_amount * pitch_noise.get_noise_1d(Time.get_ticks_msec())
	rotation_degrees.y = max_yaw * shake_amount * yaw_noise.get_noise_1d(Time.get_ticks_msec())
	rotation_degrees.z = max_roll * shake_amount * roll_noise.get_noise_1d(Time.get_ticks_msec())

func add_trauma(amount: float) -> void:
	trauma += amount
