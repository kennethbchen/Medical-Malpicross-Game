extends Control

@export var color: Color = Color.GOLD
@export var width: float = 2

var cursor_size_px: int = 32

var cursor_position: Vector2

func _process(delta: float) -> void:
	queue_redraw()

func set_cursor_position(pos: Vector2) -> void:
	cursor_position = pos

func _draw() -> void:
	
	if not visible: return
	
	# Highlight input cell
	var cur_size = Vector2(cursor_size_px, cursor_size_px)
	var rect: Rect2 = Rect2(cursor_position, cur_size)
	draw_rect(rect, color, false, width)
