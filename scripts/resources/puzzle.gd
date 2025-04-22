extends Resource

## Resource that represents a picross puzzle
class_name Puzzle

enum INPUT_TYPE {EMPTY, COLORED, CROSSED}

## 2D array of bools
## Outer array is row, inner is column
## Assumes rectangular grid
## true if cell should be colored, false if crossed
@export var _solution: Array

## 2D array of [Puzzle.PuzzleCell]
## which represents the data for each cell in the board
var _cells: Array

## Given x = number of columns, y = number of rows in the puzzle
## Returns an array of size 2 where
## array[0] contains an array of size x is the hints of the columns (top of board)
## array[0]'s hints starts at the leftmost column and ends at the rightmost
##
## array[1] contains an array of size y is the hints of the rows (left of board)
## array[1]'s hints starts at the topmost row and ends at the bottommost
##
## array[0][n] contains an array of the hint numbers for the nth column
## array[0][n]'s array is ordered starting from the bottommost hint to the topmost in appearance
##
## array[1][n] contains an array of the hint numbers for the nth row
## array[1][n]'s array is ordered starting from the rightmost hint to the leftmost in appearance
var hints: Array

## (rows, columns) [br]
## dimensions of the input space of the puzzle
var input_size: Vector2i

var row_hint_width: int

var column_hint_height: int

## (rows, columns) [br]
## dimension of [member input_size] + dimensions of the hints 
## if each hint number was its own cell
var board_size: Vector2i

# Emitted when an input cell's value changed
signal input_value_changed(cell: InputCell, row: int, col: int)

# Emitted when an input cell's value was attempted to be changed
# regardless of whether or not a value was changed
signal input_attempt_made(cell: InputCell, row: int, col: int)

func _init(puzzle_string: String):
	# Separate rows (\n delimited)
	# Separate colums (space delimeted)
	# Turn string values into bool values
	_solution = Array(
		puzzle_string.split("\n")) \
		.map(func(row): return Array(row.split(" ")) \
		.map(func(cell): return true if cell == "1" else false)
	)
	
	input_size = Vector2i(_solution.size(), _solution[0].size())
	
	hints = _calculate_hints()
	
	# Calculate board size
	var max_hint_column_size: int = 0
	var max_hint_row_size: int = 0
	
	for column_hint in hints[0]:
		if column_hint.size() > max_hint_column_size:
			max_hint_column_size = column_hint.size()
		
	for row_hint in hints[1]:
		if row_hint.size() > max_hint_row_size:
			max_hint_row_size = row_hint.size()
	
	column_hint_height =  max_hint_column_size
	row_hint_width = max_hint_row_size
	
	board_size = Vector2i(input_size.x + max_hint_column_size, input_size.y + max_hint_row_size)
	
	_cells = _create_cell_data()
	
	# Connect signals
	for row in _solution.size():
		for col in _solution[row].size():
			var cell: InputCell = get_input_cell(row, col)
			cell.in_value_changed.connect(input_value_changed.emit.bind(row, col))
			cell.input_change_attempted.connect(input_attempt_made.emit.bind(row, col))

func color_cell(row: int, col: int) -> void:
	var cell: InputCell = get_input_cell(row, col)
	
	# If cell is colored, it cannot be un-colored
	if cell.player_input == INPUT_TYPE.COLORED:
		input_attempt_made.emit(cell, row, col)
		return
		
	cell.set_input_value(INPUT_TYPE.COLORED)

func cross_cell(row: int, col: int) -> void:
	var cell: InputCell = get_input_cell(row, col)
	
	# If cell is colored, it cannot be un-colored
	if cell.player_input == INPUT_TYPE.COLORED:
		return
	
	# Toggle between empty and crossed
	if cell.player_input == INPUT_TYPE.EMPTY:
		cell.set_input_value(INPUT_TYPE.CROSSED)
	else:
		cell.set_input_value(INPUT_TYPE.EMPTY)
	
## Set input cell with input coords (row, col) to colored [br]
## Cell becomes empty if it was already colored
func toggle_input_colored(row: int, col: int) -> void:
	
	var cell: InputCell = get_input_cell(row, col)
	
	if cell.player_input == INPUT_TYPE.COLORED:
		cell.set_input_value(INPUT_TYPE.EMPTY)
	else:
		cell.set_input_value(INPUT_TYPE.COLORED)

## Set input cell with input coords (row, col) to crossed [br]
## Cell becomes empty if it was already crossed
func toggle_input_crossed(row: int, col: int) -> void:
	
	var cell: InputCell = get_input_cell(row, col)
	
	if cell.player_input == INPUT_TYPE.CROSSED:
		cell.set_input_value(INPUT_TYPE.EMPTY)
	else:
		cell.set_input_value(INPUT_TYPE.CROSSED)

## Gets cell at (row, col) in board space
func get_board_cell(row: int, column: int) -> PuzzleCell:
	return _cells[row][column]

## Gets cell at (row, col) in input space
func get_input_cell(row: int, column: int) -> InputCell:
	return _cells[row + (board_size.x - input_size.x)][column + (board_size.y - input_size.y)]

## Input: [param input_coord] (row, column) in input space  [br]
## Output: [Vector2i] (row, column) of input coordinate in board space 
func input_to_board_coordinate(input_coord: Vector2) -> Vector2i:
	return Vector2i(input_coord.x + (board_size.x - input_size.x), input_coord.y + (board_size.y - input_size.y))

## Input: [param input_coord] (row, column) in input space  [br]
## Output: [Vector2] (row, column) of input coordinate in board space 
## Allows for fractional coordinate values
func input_to_board_coordinate_fractional(input_coord: Vector2) -> Vector2:
		return Vector2(input_coord.x + (board_size.x - input_size.x), input_coord.y + (board_size.y - input_size.y))


func _calculate_hints() -> Array:
	var rows: int = input_size.x
	var columns: int = input_size.y
	
	var output: Array = [[], []]
	
	# Calculate hints for columns
	for col in range(columns):
		
		# The size of the current continuous line of colored squares
		var line_count = 0
		
		var column_hint: Array[int] = []
		
		for row in range(rows):
			
			if _solution[row][col]:
				# the line continues
				line_count += 1
			elif not _solution[row][col] and line_count != 0:
				# Current line has ended, record that in column_hint
				column_hint.append(line_count)
				line_count = 0
		
		if line_count > 0:
			# Record the last line
			column_hint.append(line_count)
		elif line_count == 0 and column_hint.size() <= 0:
			# No lines are present at all in this column
			column_hint.append(0)
		
		# Reverse so that hints appear bottom to top
		column_hint.reverse()
		
		output[0].append(column_hint)
	
	
	for row in range(rows):
		
		# The size of the current continuous line of colored squares
		var line_count = 0
		
		var row_hint: Array[int] = []
		
		for col in range(columns):
			
			if _solution[row][col]:
				# the line continues
				line_count += 1
			elif not _solution[row][col] and line_count != 0:
				# Current line has ended, record that in column_hint
				row_hint.append(line_count)
				line_count = 0
		
		if line_count > 0:
			# Record the last line
			row_hint.append(line_count)
		elif line_count == 0 and row_hint.size() <= 0:
			# No lines are present at all in this row
			row_hint.append(0)
		
		# Reverse so that hints appear right to left
		row_hint.reverse()
		output[1].append(row_hint)
		
	return output

func _create_cell_data() -> Array:
	
	var output: Array = []
	
	for row in board_size.x:
		
		var row_data: Array[PuzzleCell] = []
		
		for col in board_size.y:
			
			# Figure out quadrant that this cell is in
			var in_top_half: bool = row < board_size.x - input_size.x
			var in_left_half: bool = col < board_size.y - input_size.y
			
			# The top left quadrant is always empty (neither hint nor input)
			if in_top_half and in_left_half:
				row_data.append(EmptyCell.new())
				
			# The top right cells are either column hints or empty
			if in_top_half and not in_left_half:
				
				# convert from board row/col to hint row/col
				
				# Access rows in reverse order
				var hint_row_index: int = (board_size.x - input_size.x) - row - 1
				
				var hint_column_index: int = col - (board_size.y - input_size.y)

				if hint_row_index >= hints[0][hint_column_index].size():
					row_data.append(EmptyCell.new())
				else:
					row_data.append(HintCell.new(hints[0][hint_column_index][hint_row_index]))
			
			# The bottom left cells are either row hints or empty
			if not in_top_half and in_left_half:
				
				# convert from board row/col to hint row/col
				var hint_row_index: int = row - (board_size.x - input_size.x)
				
				# Access columns in reverse order
				var hint_column_index: int = (board_size.y - input_size.y) - col - 1
				
				if hint_column_index >= hints[1][hint_row_index].size():
					row_data.append(EmptyCell.new())
				else:
					row_data.append(HintCell.new(hints[1][hint_row_index][hint_column_index]))
			
			# The bottom right cells are input cells
			if not in_top_half and not in_left_half:
				
				# Convert from board row/col to solution row/col
				var solution_row_index: int = row - (board_size.x - input_size.x)
				var solution_col_index: int = col - (board_size.y - input_size.y)
				
				row_data.append(InputCell.new(_solution[solution_row_index][solution_col_index]))
				
		output.append(row_data)
	return output
	
class PuzzleCell:
	extends RefCounted

class EmptyCell:
	extends PuzzleCell
	
	func _to_string() -> String:
		return "EmptyCell"

class InputCell:
	extends PuzzleCell
	
	var true_value_is_colored: bool
	var player_input: INPUT_TYPE
	
	# Emitted when player_input changes value
	signal in_value_changed(cell: InputCell)
	
	# Emitted when set_input_value is called regardless
	# on whether or not it changed a value
	signal input_change_attempted(cell: InputCell)
	
	func _init(correct_input_value: bool) -> void:
		true_value_is_colored = correct_input_value
		set_input_value(INPUT_TYPE.EMPTY)
	
	func set_input_value(type: INPUT_TYPE):
		var prev: INPUT_TYPE = player_input
		player_input = type
		
		if player_input != prev:
			in_value_changed.emit(self)
		
		input_change_attempted.emit(self)
		
	func is_colored() -> bool:
		return player_input == INPUT_TYPE.COLORED

	func is_correct() -> bool:
		match player_input:
			INPUT_TYPE.EMPTY or INPUT_TYPE.CROSSED:
				return not true_value_is_colored
			INPUT_TYPE.COLORED:
				return true_value_is_colored
			_:
				return false
				
	func _to_string() -> String:
		return "InputCell(t={0})".format(["1" if true_value_is_colored else "0"])
	
class HintCell:
	extends PuzzleCell
	
	var value: int
	
	func _init(hint_value) -> void:
		value = hint_value
		
	func _to_string() -> String:
		return "HintCell({0})".format([value])
