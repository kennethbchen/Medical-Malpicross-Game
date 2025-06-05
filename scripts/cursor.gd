extends Control

@export var cursor_color: Color = Color.GOLD
@export var hint_color: Color = Color.GRAY

@export var cursor_width: float = 2

var cursor_position: Vector2

var cell_size_px: int = 32

var row_hint_size: int
var col_hint_size: int

func _process(_delta: float) -> void:
	queue_redraw()

func init(puzzle: Puzzle, cell_size: int = 32) -> void:
	
	cell_size_px = cell_size
	
	row_hint_size = puzzle.row_hint_width * cell_size_px
	col_hint_size = puzzle.column_hint_height * cell_size_px
	

func set_cursor_position(pos: Vector2) -> void:
	cursor_position = pos

func _draw() -> void:
	if cursor_position == Vector2(-1, -1): 
		return
	
	# Highlight input cell
	var cur_size = Vector2(cell_size_px, cell_size_px)
	var rect: Rect2 = Rect2(cursor_position, cur_size)
	draw_rect(rect, cursor_color, false, cursor_width)
	
	# Highlight hints
	# Row
	var row_rect: Rect2 = Rect2(Vector2(0, cursor_position.y), Vector2(row_hint_size, cell_size_px))
	draw_rect(row_rect, hint_color, true)
	
	# Column
	var col_rect: Rect2 = Rect2(Vector2(cursor_position.x, 0), Vector2(cell_size_px, col_hint_size))
	draw_rect(col_rect, hint_color, true)
