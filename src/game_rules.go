package main

import "fmt"

func apply_game_of_life_rules(board [][]bool) {
	var life_board = make_blank_board(uint(len(board)))
	var death_board = make_blank_board(uint(len(board)))

	// Flag cells for birth and death (don't update yet)
	for i := range board {
		for j := range board[i] {
			n_live_neighbors := get_n_live_neighbors(i, j, board)

			// Rule
			if board[i][j] && n_live_neighbors != 2 && n_live_neighbors != 3 {
				if DEBUG_PRINT {
					fmt.Printf("Cell [%d, %d] will die with %d neighbors!\n", i, j, n_live_neighbors)
				}

				death_board[i][j] = true
			}
			if !board[i][j] && (n_live_neighbors == 3) {
				if DEBUG_PRINT {
					fmt.Printf("Cell [%d, %d] will be born with %d neighbors!\n", i, j, n_live_neighbors)
				}

				life_board[i][j] = true
			}
		}
	}

	// Now update
	for i := range board {
		for j := range board[i] {
			if death_board[i][j] {
				board[i][j] = false
			}
			if life_board[i][j] {
				board[i][j] = true
			}
		}
	}

}
