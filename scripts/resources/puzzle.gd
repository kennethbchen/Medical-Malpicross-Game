extends Resource

class_name Puzzle
	
# 2D array of bools
# Outer array is row, inner is column
# Assumes rectangular grid
# true if cell should be colored, false if crossed
@export var _solution: Array

func _init(puzzle_string: String):
	# Separate rows (\n delimited)
	# Separate colums (space delimeted)
	# Turn string values into bool values
	_solution = Array(
		puzzle_string.split("\n")) \
		.map(func(row): return Array(row.split(" ")) \
		.map(func(cell): return true if cell == "1" else false)
	)

## (rows, columns)
## dimensions of _solution
func input_size() -> Vector2i:
	return Vector2i(_solution.size(), _solution[0].size())

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
func get_hints() -> Array:
	var rows: int = input_size().x
	var columns: int = input_size().y
	
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

func get_cell(row, column) -> bool:
	return _solution[row][column]
