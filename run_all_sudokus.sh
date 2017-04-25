#!/bin/bash
sudoku_solver=$1
for problem_set in {1..71}; do
	total_output=0
	for instance in {1..10}; do
		#echo "Running set $problem_set, problem $instance"
		output="$(ruby $sudoku_solver.rb problems/$problem_set/$instance.sd)"
		total_output=`expr $total_output + $output`
	done
	average=`expr $total_output / 10`
	#echo "average for set $problem_set: $average"
	echo $average
done
