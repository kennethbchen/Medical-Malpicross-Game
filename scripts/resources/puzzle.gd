extends Resource

class_name Puzzle
	
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

## (rows, columns) [br]
## dimension of [member input_size] + dimensions of the hints 
## if each hint number was its own cell
var board_size: Vector2i

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
	var max_hint_column_size: int = 0
	var max_hint_row_size: int = 0
	
	for column_hint in hints[0]:
		if column_hint.size() > max_hint_column_size:
			max_hint_column_size = column_hint.size()
		
	for row_hint in hints[1]:
		if row_hint.size() > max_hint_row_size:
			max_hint_row_size = row_hint.size()
			
	board_size = Vector2i(input_size.x + max_hint_column_size, input_size.y + max_hint_row_size)
	
	# Create cell data
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
				var hint_row_index: int = (board_size.y - input_size.y) - row
				
				var hint_column_index: int = col - (board_size.x - input_size.x) + 1
				
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
				
		_cells.append(row_data)
		
func get_cell(row, column) -> bool:
	return _solution[row][column]
	
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
			
			if get_cell(row,col):
				# the line continues
				line_count += 1
			elif not get_cell(row,col) and line_count != 0:
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
			
			if get_cell(row,col):
				# the line continues
				line_count += 1
			elif not get_cell(row,col) and line_count != 0:
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

class PuzzleCell:
	extends RefCounted

class EmptyCell:
	extends PuzzleCell
	
	func _to_string() -> String:
		return "EmptyCell"

class InputCell:
	extends PuzzleCell
	
	enum INPUT_TYPE {EMPTY, CROSSED, COLORED}
	
	var true_value_is_colored: bool
	var player_input: INPUT_TYPE
	
	func _init(correct_input_value: bool) -> void:
		true_value_is_colored = correct_input_value
		player_input = INPUT_TYPE.EMPTY
	
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
