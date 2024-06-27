package main

import (
	"fmt"
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
	board, err := read_json_board("boards/spinner.json")
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
