# SudokuSolver

A CSP (Constraint Satisfaction Problem) sudoku puzzle solver created for CS486 (AI) Assignment 1 (Winter 2017, Kate Larson, University of Waterloo).

There are three different versions of the solver:
1. Basic CSP using just backtracking search (sudoku.rb)
2. CSP using backtracking and forward checking (sudoku_fc.rb)
3. CSP using backtracking, forward checking, and heuristics
    * most restricted variable
    * most constraining variable
    * least constraining value

**To Run:**
        
    $sudoku.rb problems/<problem_set #>/<instance #>.sd
