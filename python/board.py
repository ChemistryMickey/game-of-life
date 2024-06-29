from __future__ import annotations
import json


class Board:
    def __init__(self) -> Board:
        self.cells = [[]]  # placeholder

    def print(self) -> None:
        for row in self.cells:
            for val in row:
                if val:
                    print("▣", end="  ")
                else:
                    print(".", end="  \033[39m")
            print()

    def get_n_live_neighbors(self, i: int, j: int) -> int:
        n_live_neighbors = 0
        n_side = self.cells.__len__()
        steps = [-1, 0, 1]
        for i_step in steps:
            for j_step in steps:
                if i_step == 0 and j_step == 0:
                    continue

                if (
                    (i + i_step < 0)
                    or (j + j_step < 0)
                    or (i + i_step >= n_side)
                    or (j + j_step >= n_side)
                ):
                    continue

                if self.cells[i + i_step][j + j_step]:
                    n_live_neighbors += 1

        return n_live_neighbors

    # Class Functions
    def from_json(file_path: str) -> Board:
        new_board = Board()
        with open(file_path, "r") as f:
            deser = json.load(f)

        new_board.cells = deser
        return new_board

    def make_blank(side_len: int) -> Board:
        new_board = Board()
        new_board.cells = [[False for _ in range(side_len)] for _ in range(side_len)]

        return new_board


def interactive_create_board() -> Board:
    n_side = int(input("How many lines on each side is this board: "))
    board: Board = Board.make_blank(
        n_side
    )  # for some reason __future__'s annotation doesn't fill in properties for LSP?

    print(
        f'Add "live" cell addresses in the form "a, b" in the range {n_side}x{n_side} (non-inclusive)\n(Enter -1 or a blank to continue)'
    )
    while True:
        line = input()
        if line.strip() == "-1" or line == "":
            break

        addrs = [int(s) for s in line.split(",")]
        if any([addr >= n_side for addr in addrs]):
            print(f"Addresses must be in the range [0, {n_side} - 1]!")
            continue

        if board.cells[addrs[0]][addrs[1]]:
            print(f"{addrs} is already alive!")
        else:
            board.cells[addrs[0]][addrs[1]] = True
            board.print()

    save_path = input("Where should this board be saved? (blank for no save): ")
    if save_path != "":
        with open(save_path, "w") as f:
            json.dump(board.cells, f)

    return board
