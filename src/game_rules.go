package main

import (
	"fmt"
)

func apply_game_of_life_rules(board Board) {
	var life_board = make_blank_board(uint(len(board.cells)))
	var death_board = make_blank_board(uint(len(board.cells)))

	// Flag cells for birth and death (don't update yet)
	for i := range board.cells {
		for j := range board.cells[i] {
			n_live_neighbors := board.get_n_live_neighbors(i, j)

			// Rule
			if board.cells[i][j] && n_live_neighbors != 2 && n_live_neighbors != 3 {
				if DEBUG_PRINT {
					fmt.Printf("Cell [%d, %d] will die with %d neighbors!\n", i, j, n_live_neighbors)
				}

				death_board.cells[i][j] = true
			}
			if !board.cells[i][j] && (n_live_neighbors == 3) {
				if DEBUG_PRINT {
					fmt.Printf("Cell [%d, %d] will be born with %d neighbors!\n", i, j, n_live_neighbors)
				}

				life_board.cells[i][j] = true
			}
		}
	}

	// Now update
	for i := range board.cells {
		for j := range board.cells[i] {
			if death_board.cells[i][j] {
				board.cells[i][j] = false
			}
			if life_board.cells[i][j] {
				board.cells[i][j] = true
			}
		}
	}

}
