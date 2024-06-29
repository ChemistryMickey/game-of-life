package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func clear_terminal() {
	fmt.Print("\x1b[H\x1b[2J")
}

type Board struct {
	cells [][]bool
}

func (b *Board) get_n_live_neighbors(i int, j int) int {
	n_live_neighbors := 0
	steps := []int{-1, 0, 1}
	for _, i_step := range steps {
		for _, j_step := range steps {
			if i_step == 0 && j_step == 0 {
				continue
			}

			// Boundries
			if (i+i_step < 0) || (j+j_step < 0) || (i+i_step >= len(b.cells)) || (j+j_step >= len(b.cells)) {
				continue
			}

			// Neighbor check
			if b.cells[i+i_step][j+j_step] {
				n_live_neighbors += 1
			}
		}
	}
	return n_live_neighbors
}

func (b *Board) from_json(file_name string) error {
	data, err := os.ReadFile(file_name)
	if err != nil {
		return err
	}
	var board [][]bool
	err = json.Unmarshal(data, &board)
	if err != nil {
		return err
	}

	b.cells = board // Does this survive the scope of the function?
	return nil
}

func (b *Board) print() {
	for _, row := range b.cells { //Go's range outputs an index and value (like Python's enumerate)
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

func make_blank_board(side_len uint) Board {
	out_board := Board{}
	board := make([][]bool, side_len)
	for i := range board {
		board[i] = make([]bool, side_len)
		for j := range board[i] {
			board[i][j] = false
		}
	}

	out_board.cells = board

	return out_board
}

func create_new_board() (Board, error) {
	fmt.Print("How many lines on each side is this board: ")
	reader := bufio.NewReader(os.Stdin)
	line, _, err := reader.ReadLine()
	if err != nil {
		return Board{}, err
	}

	n_side, err := strconv.ParseUint((string(line[:])), 10, 64)
	var board = make_blank_board(uint(n_side)) //oh, you can use var to not use the := Thank goodness

	fmt.Printf("Add \"live\" cell addresses (in the form \"a, b\") in range %dx%d (not inclusive)\n(Enter -1 or a blank to continue)\n", n_side, n_side)
	for {
		line, _, err := reader.ReadLine()
		if err != nil {
			return Board{}, err
		}

		var str = string(line[:])
		if str == "-1" || str == "" {
			break
		}

		var addr_strs = strings.Split(str, ",")
		addr1, err := strconv.ParseUint(strings.TrimSpace(addr_strs[0]), 10, 64)
		addr2, err := strconv.ParseUint(strings.TrimSpace(addr_strs[1]), 10, 64)

		if addr1 >= n_side || addr2 >= n_side {
			fmt.Printf("Addresses must be in range [0 - (%d - 1)]!", n_side)
			continue
		}

		if board.cells[addr1][addr2] {
			fmt.Printf("%d, %d is already alive!\n", addr1, addr2)
		} else {
			board.cells[addr1][addr2] = true
			board.print()
		}
	}

	fmt.Print("Where should this board be saved?\n")
	line, _, err = reader.ReadLine()
	if err != nil {
		fmt.Println("Unable to read line!")
		return Board{}, err
	}

	var file_path = string(line[:])
	file, err := os.Create(file_path)
	if err != nil {
		fmt.Println("Unable to create file!")
		return Board{}, err
	}

	serialized_cells, _ := json.Marshal(board.cells)
	fmt.Fprint(file, string(serialized_cells))

	return board, nil
}
