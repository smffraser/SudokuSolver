#############################################
# Assignment 1
# Question 4
# CS 486 W 17
# By Sarah Fraser
# 20458408
#############################################


# Default Ruby Gem
# 	Used in place of a unique array
require 'set'


## Gloabls

# Grid size
$N = 9
# Region size
$n = 3
# Possible Domain Values
$domain = [1,2,3,4,5,6,7,8,9]
# Grid of Sudoku Values
$value_grid = Array.new($N, Array.new($N, 0))
# Number of Steps
$steps = 0

## Functions

# Get data from file input & setup grid
def init_grid(filename)
	# Get data from the file
	$value_grid = File.open(filename, "r"){ |datafile| 
   		datafile.readlines
	}

	$value_grid -= ["\n"]

	if $value_grid.length != $N
		raise "[+] ERROR: Grid length is not as expected. Should be " + $N.to_s + " but is instead " + $value_grid.length.to_s
	end

	for index in 0..$value_grid.length-1
		$value_grid[index] = $value_grid[index].chomp.split.map(&:to_i)
		if $value_grid[index].length != $N
			raise "[+] ERROR: Grid[" + index.to_s + "] length is not as expected. Should be " + $N.to_s + " but is instead " + $value_grid[index].length.to_s
		end
	end	
end

# Finds the next exmpty cell
def find_empty_cell()
	$value_grid.each_with_index do |row, index_r|
		row.each_with_index do |col, index_c|
			if col.to_i == 0
				return [index_r,index_c]
			end
		end
	end
	return [$N,$N]
end

# If the number is not already in the row, return true
# Else, return false
def num_in_row(cell_row, num)
	$value_grid[cell_row].each do |cell|
		if cell.to_i == num
			return false
		end
	end
	return true
end

# If the number is not already in the column, return true
# Else, return false
def num_in_col(cell_c, num)
	$value_grid.each do |cell|
		if cell[cell_c].to_i == num
			return false
		end
	end
	return true
end

# If the number is not already in the region, return true
# Else, return false
def num_in_region(cell_r, cell_c, num)
	(0..2).each do |row|
		(0..2).each do |col|
			if $value_grid[row+cell_r][col+cell_c].to_i == num
				return false
			end
		end
	end
	return true
end

# Checks is a cell can take a value based on its contraints
def can_take_value(cell_r,cell_c,num)
	return num_in_row(cell_r, num) && num_in_col(cell_c, num) && num_in_region(cell_r - (cell_r % $n), cell_c - (cell_c % $n), num)
end


def pretty_print_grid()
	$value_grid.each do |line|
		print line
		print "\n"
	end
end

# Solve Sudoku
def sudoku_solve()

	if ($steps > 10000)
		puts $steps
		exit
	end

	current_cell = find_empty_cell()

	# If there are no more current cells, return true
	if current_cell == [$N,$N]
		return true
	end

	# For all possible legal values...
	for num in $domain

		# Check if the current_cell can take this value
		if can_take_value(current_cell[0],current_cell[1],num)

			# Possible assignment

			# Assign domain
			$value_grid[current_cell[0]][current_cell[1]] = num
			$steps += 1

			# Move onto the next cell...
			if sudoku_solve()
				# If the solver returns true, that means this node with this num works
				return true
			else
				# Reverse possible assignment
				$value_grid[current_cell[0]][current_cell[1]] = 0
				#$steps += 1
			end
		end
	end

	# We've gotten to a terminal state (aka a cell has no more possible values)
	# Thus we need to backtrack
	return false
end

## MAIN
init_grid(ARGV[0])
sudoku_solve()

#pretty_print_grid()
puts $steps


