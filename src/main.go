package main

import (
	"flag"
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

Second time asking:
	1. Lone cell dies
	2. 2-3 live neighbors, it remains alive
	3. >3 neighbors, dies
	4. Dead cell with 3 live neighbors, comes to life.
That sounds much closer to the real ones. I don't know if these are wrong.
But it's not clear what happens when a cell has 1 live neighbor.
I'll assume that's a death case as well.
*/

const DEBUG_PRINT bool = false

func main() {

	var (
		create_board = flag.Bool("create_board", false, "Create new board mode")
		board_source = flag.String("board_json", "boards/spinner.json", "Source for board JSON. If you create a new board, that new board will be used.")
	)
	flag.Parse()

	var board Board
	var err error
	if *create_board {
		board, err = create_new_board()
		if err != nil {
			fmt.Print(err)
			os.Exit(1)
		}
	} else {
		board = Board{}
		err = board.from_json(*board_source)
		if err != nil {
			fmt.Print(err)
			os.Exit(1)
		}
	}

	const time_per_frame time.Duration = 100 // check Sleep for units
	for {
		clear_terminal()
		board.print()

		apply_game_of_life_rules(board)

		time.Sleep(time_per_frame * time.Millisecond)
	}
}
