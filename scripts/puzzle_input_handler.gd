extends Node

enum STATE {IDLE, COOLDOWN}

@export var cursor: Node3D
@export var cursor_particles: CPUParticles3D

var cursor_travel_time: float = 0.2

var cursor_hover_height: float = 1.5

var puzzle: Puzzle

var puzzle_plane: Node3D

var cell_scale_factor: float

var current_state: STATE
# In Sim Space
var cursor_position: Vector2

func init(puzzle, puzzle_plane, cell_scale_factor) -> void:
	self.puzzle = puzzle
	self.puzzle_plane = puzzle_plane
	self.cell_scale_factor = cell_scale_factor
	
func color_cell(row, col) -> void:
	
	if current_state != STATE.IDLE:
		return
		
	current_state = STATE.COOLDOWN
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	
	# Attack
	tween.tween_property(cursor, "position:y", -1.5, cursor_travel_time)
	tween.tween_callback(func():
		puzzle.toggle_input_colored(row, col)
		EventBus.screen_shake_requested.emit(0.75)
		cursor_particles.emitting = true
		)

	# Hold
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(cursor, "position:y", cursor_hover_height, 0.5).set_delay(0.2)
	
	# Recovery
	tween.tween_callback(func():
		current_state = STATE.IDLE
		)

func cross_cell(row, col) -> void:
	puzzle.toggle_input_crossed(row, col)
	
func set_cursor_position(new_position: Vector2i) -> void:
	cursor_position = new_position
	
func _process(delta: float) -> void:
	
	match(current_state):
		STATE.IDLE:
			var new_cursor_position: Vector3 = Vector3(cursor_position.x, 0, cursor_position.y) * cell_scale_factor
			new_cursor_position.y = cursor_hover_height
			
			cursor.position = cursor.position.move_toward(new_cursor_position, delta * 20)
	
