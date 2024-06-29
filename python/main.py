from __future__ import annotations
import os
import sys
from time import sleep

from board import Board, interactive_create_board
from game_rules import apply_game_of_life_rules


def main():
    # Whatevs, just use sys.argv for user input processing
    valid_options = ["--create_board", "--board_json"]
    if valid_options[1] in sys.argv:
        json_path = sys.argv[sys.argv.index(valid_options[0]) + 1]
    else:
        json_path = os.path.join(".", "boards", "glider.json")

    if valid_options[0] in sys.argv:
        board = interactive_create_board()
    else:
        board = Board.from_json(json_path)

    TIME_PER_FRAME = 0.1  # [s]
    while True:
        clear_terminal()
        board.print()

        apply_game_of_life_rules(board)

        sleep(TIME_PER_FRAME)


def clear_terminal():
    print("\x1b[H\x1b[2J")


if __name__ == "__main__":
    main()
