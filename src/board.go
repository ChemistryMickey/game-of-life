package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func clear_terminal() {
	fmt.Print("\x1b[H\x1b[2J")
}

func get_n_live_neighbors(i int, j int, board [][]bool) int {
	n_live_neighbors := 0
	steps := []int{-1, 0, 1}
	for _, i_step := range steps {
		for _, j_step := range steps {
			if i_step == 0 && j_step == 0 {
				continue
			}

			// Boundries
			if (i+i_step < 0) || (j+j_step < 0) || (i+i_step >= len(board)) || (j+j_step >= len(board)) {
				continue
			}

			// Neighbor check
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
