extends SubViewport

@onready var ui_container: Control = $PuzzleUIContainer

var cell_size_px: int = 32

var rows: int
var columns: int

# TODO
var tile_map: Dictionary[Vector2i, Control]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init(puzzle: Puzzle) -> void:
	rows = puzzle.board_size.x
	columns = puzzle.board_size.y
	
	size = Vector2(columns, rows) * cell_size_px
	
	var position_offset: = Vector2(cell_size_px / 2, cell_size_px / 2)
	# Populate puzzle UI
	for row in rows:
		for col in columns:
			var pos: Vector2 = Vector2(col, row) * cell_size_px
			
			var cell: Puzzle.PuzzleCell = puzzle.get_board_cell(row, col)
			
			if cell is Puzzle.EmptyCell:
				continue
				
			if cell is Puzzle.InputCell:
				var tile: = TextureRect.new()
				ui_container.add_child(tile)
				tile.position = pos
				var img: = PlaceholderTexture2D.new()
				img.size = Vector2(cell_size_px, cell_size_px)
				tile.texture = img
				
			if cell is Puzzle.HintCell:
				var label: = Label.new()
				ui_container.add_child(label)
				
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				label.size = Vector2(cell_size_px, cell_size_px)
				label.position = pos
				label.text = str(cell.value)
				
			
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
