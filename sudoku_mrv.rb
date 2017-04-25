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
# Brian Schroeder (2005) PriorityQueue (0.1.2) ruby-gem. https://rubygems.org/gems/PriorityQueue/versions/0.1.2.
# 	Used to hold a queue of items based on a given priority value
require 'priority_queue'

## Globals 

# Grid size
$N = 9
# Region size
$n = 3
# Grid of Sudoku Values
$value_grid = Array.new($N, Array.new($N, 0))
# Grid of Sudoku Domain Values
$domain_grid = Array.new($N) { Array.new($N) {Set.new([1,2,3,4,5,6,7,8,9])}}
# Number of Steps Taken
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

# Find a cell with no assigned value
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

# Determine if a cell can take a specified value based on its constraints
def can_take_value(cell_r,cell_c,num)
	return num_in_row(cell_r, num) && num_in_col(cell_c, num) && num_in_region(cell_r - (cell_r % $n), cell_c - (cell_c % $n), num)
end

# Remove a value from all of a cell's neighbours
def remove_from_neighbours(row,col,num)

	# Remove num from all row neighbours
	#puts "removing from row neighbours"
	for c in (0..$N-1)
		$domain_grid[row][c].delete(num)
	end

	# Remove num from all col neighbours
	#puts "removing from col neighbours"
	for r in (0..$N-1)
		$domain_grid[r][col].delete(num)
	end

	# Remove num from all region neighbours

	norm_row = row - (row % $n)
	norm_col = col - (col % $n)

	#puts "removing from region now"

	(0..2).each do |nr|
		(0..2).each do |nc|
			$domain_grid[nr+norm_row][nc+norm_col].delete(num)
		end
	end
end

# Remove all values from neighbour domains if it came "default" with the grid
def restrict_neighbours()
	# The grid starts out with values already. 
	# Need to change the domain_grid to reflect the neighbours that can't 
	# be certain values due to starting values

	$domain_grid.each_with_index do |row, index_r|
		row.each_with_index do |col, index_c|
			val = $value_grid[index_r][index_c]
			
			if val != 0 
				remove_from_neighbours(index_r,index_c,val)
			end
		end
	end
end

# Find the most constraining variable
def find_most_constraining_variable(min_list)

	max_constrained = -1
	max_constrainer = [$N,$N]

	#puts min_list.inspect

	min_list.each do |constrainer|

		row = constrainer[0]
		col = constrainer[1]

		n_constrained = 0

		# Check rows
		for c in (0..$N-1)
			# If the neighbour hasn't be assigned, add to count
			# NOTE: Need to worry about counting ourselves, since our value is zero
			if c != col && $value_grid[row][c] == 0
				n_constrained += 1
			end
		end

		# Check columns
		for r in (0..$N-1)
			if r != row && $value_grid[r][col] == 0
				n_constrained += 1
			end
		end

		# Check region
		norm_row = row - (row % $n)
		norm_col = col - (col % $n)

		(0..2).each do |nr|
			(0..2).each do |nc|

				# Check to make sure hasn't been counted by row / col already 
				if !(nr+norm_row == row || nc + norm_col == col)  && $value_grid[nr+norm_row][nc+norm_col] == 0
					#puts "row, col" + row.to_s + " " + col.to_s
					#puts "cell row, col: " + (nr+norm_row).to_s + " " + (nc+norm_col).to_s
					n_constrained += 1
				end

			end
		end		

		if n_constrained > max_constrained
			max_constrained = n_constrained
			max_constrainer = constrainer
		end

	end

	return max_constrainer
end

# Find the most restricted variable
def find_most_restricted_variable()

	# Set min value to a value larger than any domain list
	min = $N + 1
	min_list = []

	# For each variable in the domain grid, check if its len is <= min and add 
	# to the min_list
	$domain_grid.each_with_index do |row, index_r|
		row.each_with_index do |col, index_c|

			if $value_grid[index_r][index_c] == 0 && col.length == min
				min_list.push([index_r,index_c])
				next
			end

			if $value_grid[index_r][index_c] == 0 && col.length < min
				min_list.clear
				min = col.length
				min_list.push([index_r,index_c])
			end
		end
	end

	# FReturn the most constrained variable in the list
	if (min_list.length > 0)
		return find_most_constraining_variable(min_list)
		#return min_list.first
	else
		# If there are NO domains left then return an index out of range
		#puts "No domains left"
		return [$N,$N]
	end

end

# Get the order of a cell's value based on which one is least constrained
def get_value_order(current_cell)
	row = current_cell[0]
	col = current_cell[1]

	poss_values = Marshal.load(Marshal.dump($domain_grid[current_cell[0]][current_cell[1]]))
	queue = PriorityQueue.new

	poss_values.each do |val|
		n_constrained = 0

		# Check rows
		for c in (0..$N-1)
			# If the neighbour has val in their domain count it
			if c != col && $domain_grid[row][c].include?(val)
				n_constrained += 1
			end
		end

		# Check columns
		for r in (0..$N-1)
			if r != row && $domain_grid[r][col].include?(val)
				n_constrained += 1
			end
		end

		# Check region
		norm_row = row - (row % $n)
		norm_col = col - (col % $n)

		(0..2).each do |nr|
			(0..2).each do |nc|

				# Check to make sure hasn't been counted by row / col already 
				if !(nr+norm_row == row || nc + norm_col == col)  && $domain_grid[nr+norm_row][nc+norm_col].include?(val)
					n_constrained += 1
				end

			end
		end	

		# Add to prority queue
		queue.push(val,n_constrained)
	end	

	return queue
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

	current_cell = find_most_restricted_variable()

	# If there are no more current cells, return true
	if current_cell == [$N,$N]
		#puts "no more in domain"
		return true
	end

	# For all possible legal values...
	queue = get_value_order(current_cell)

	while !queue.empty?

		num_and_val = queue.delete_min
		num = num_and_val[0]

		# Check if the current_cell can take this value
		if can_take_value(current_cell[0],current_cell[1],num)

			# Possible assignment

			# Save domain_grid
			tmp_domain_grid = Marshal.load(Marshal.dump($domain_grid))

			# Assign domain
			$value_grid[current_cell[0]][current_cell[1]] = num
			$steps += 1

			# Remove num from neighbours
			remove_from_neighbours(current_cell[0], current_cell[1], num)

			# Move onto the next cell...
			if sudoku_solve()
				# If the solver returns true, that means this node with this num works
				return true
			else
				# Reverse possible assignment
				$value_grid[current_cell[0]][current_cell[1]] = 0

				# Restore domain_grid from BEFORE change 
				$domain_grid = Marshal.load(Marshal.dump(tmp_domain_grid))
				# After load
			end
		end

	end

	# We've gotten to a terminal state (aka a cell has no more possible values)
	# Thus we need to backtrack
	return false
end

## MAIN
init_grid(ARGV[0])
restrict_neighbours()
sudoku_solve()

#pretty_print_grid()
puts $steps