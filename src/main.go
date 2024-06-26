package main

import (
	"encoding/json"
	"fmt"
	"os"
	"time"
)

/*
Codellama:13b's Game of Life:
	1. Any live cell with 2 or 3 neighbors stays alive, unchanged
	2. A cell can have 0-7 neighboring cells and each cell is either "dead", meaning its cell will become dead.
A "dead" cell that is connected by an edge (a corner) is also counted as one neighbor.
If there are exactly 3 or 6 neighboring live cells, a cell is born alive and the dead cell will die.

Alright, that's the game. I'm 100% sure that's incorrect and geometrically impossible. Sweet.
No googling though :D
Technically none of these results in death but I might say "if there aren't exactly 2 or 3 neighbors alive, a cell dies."
*/

func main() {
	board, err := read_json_board("input_board.json")
	if err != nil {
		fmt.Print(err)
	}

	const sec_per_frame time.Duration = 1 // [s]
	for {
		clear_terminal()
		print_board(board)

		apply_game_of_life_rules(board)

		time.Sleep(sec_per_frame * time.Second)
	}
}

func clear_terminal() {
	fmt.Print("\x1b[H\x1b[2J")
}

func apply_game_of_life_rules(board [][]bool) {
	life_board := make_blank_board(uint(len(board)))
	death_board := make_blank_board(uint(len(board)))

	// Flag cells for birth and death (don't update yet)
	for i := range board {
		for j := range board[i] {
			n_live_neighbors := get_n_live_neighbors(i, j, board)

			// Rule
			if board[i][j] && ((n_live_neighbors != 2) || (n_live_neighbors != 3)) {
				death_board[i][j] = true
			}
			if !board[i][j] && (n_live_neighbors == 3 || n_live_neighbors == 6) {
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

func get_n_live_neighbors(i int, j int, board [][]bool) int {
	n_live_neighbors := 0
	steps := []int{-1, 0, 1}
	for _, i_step := range steps {
		for _, j_step := range steps {
			if i_step == 0 && j_step == 0 {
				continue
			}

			//boundries
			if (i+i_step < 0) || (j+j_step < 0) || (i+i_step >= len(board)) || (j+j_step >= len(board)) {
				continue
			}

			if board[i+i_step][j+j_step] {
				n_live_neighbors += 1
			}
		}
	}
	return n_live_neighbors
}

func read_json_board(file_name string) ([][]bool, error) {
	data, err := os.ReadFile(file_name)
	if err != nil {
		return nil, err
	}
	var board [][]bool
	err = json.Unmarshal(data, &board)
	if err != nil {
		return nil, err
	}
	return board, nil
}

func make_blank_board(side_len uint) [][]bool {
	board := make([][]bool, side_len)
	for i := range board {
		board[i] = make([]bool, side_len)
		for j := range board[i] {
			board[i][j] = false
		}
	}

	return board
}

func print_board(mat [][]bool) {
	for _, row := range mat { //Go's range outputs an index and value (like Python's enumerate)
		for _, val := range row {
			if val == true {
				fmt.Print("▣  ")
			} else {
				fmt.Print(".  \033[39m")
			}
		}
		fmt.Println()
	}
}
