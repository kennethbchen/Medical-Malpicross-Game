extends Node

enum STATE {IDLE, COOLDOWN}

@export var cursor: Node3D
@export var cursor_particles_scene: PackedScene
@export var cursor_sfx_player: AudioStreamPlayer3D

@export_group("SFX")
@export var knife_swoosh_sounds: AudioStream
@export var knife_impact_sounds: AudioStream

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

	# Wind up
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(cursor, "position:y", cursor_hover_height + 0.75, 0.08)
	tween.parallel().tween_callback(func():
		cursor_sfx_player.stream = knife_swoosh_sounds
		cursor_sfx_player.play()
		)
	# Attack
	
	# The timing of when the knife contacts the body is slightly before
	# the timing of when the tween is done, so we need to time things
	# in parallel like this to make it look seamless
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func():
		puzzle.toggle_input_colored(row, col)
		
		cursor_sfx_player.stream = knife_impact_sounds
		cursor_sfx_player.play()
		
		
		EventBus.screen_shake_requested.emit(0.8)
		).set_delay(0.03)
	tween.parallel().tween_callback(func():
		var new_particles = cursor_particles_scene.instantiate()
		get_tree().root.add_child(new_particles)
		new_particles.global_position = cursor.global_position + Vector3(0, 0.5, 0)
		new_particles.finished.connect(func():
			new_particles.queue_free()
		)
		new_particles.emitting = true
		).set_delay(0.06)
	tween.parallel().tween_property(cursor, "position:y", -1.5, 0.2)
	
	# Hold
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(cursor, "position:y", cursor_hover_height, 0.3).set_delay(0.2)
	
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
	
