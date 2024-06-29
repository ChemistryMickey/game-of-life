from board import Board


def apply_game_of_life_rules(board: Board) -> None:
    n_side = board.cells.__len__()
    life_board: Board = Board.make_blank(n_side)
    death_board: Board = Board.make_blank(n_side)

    for i in range(n_side):
        for j in range(n_side):
            n_live_neighbors = board.get_n_live_neighbors(i, j)

            if board.cells[i][j] and n_live_neighbors != 2 and n_live_neighbors != 3:
                death_board.cells[i][j] = True
            if not board.cells[i][j] and n_live_neighbors == 3:
                life_board.cells[i][j] = True

    for i in range(n_side):
        for j in range(n_side):
            if death_board.cells[i][j]:
                board.cells[i][j] = False
            if life_board.cells[i][j]:
                board.cells[i][j] = True
