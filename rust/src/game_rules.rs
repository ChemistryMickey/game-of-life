use crate::board::Board;

pub fn apply_game_of_life_rules(board: &mut Board) -> () {
    let (life_board, death_board) = get_life_death_boards(board);
    update_board(board, life_board, death_board);
}

fn update_board(board: &mut Board, life_board: Board, death_board: Board) -> () {
    let n_side = board.cells.len();
    for i in 0..n_side {
        for j in 0..n_side {
            if death_board.cells[i][j] {
                board.cells[i][j] = false;
            }
            if life_board.cells[i][j] {
                board.cells[i][j] = true;
            }
        }
    }
}

fn get_life_death_boards(board: &mut Board) -> (Board, Board) {
    let n_side = board.cells.len();

    let mut life_board = Board::new(n_side);
    let mut death_board = Board::new(n_side);

    for i in 0..n_side {
        for j in 0..n_side {
            let n_live_neighbors = board.get_n_live_neighbors(i, j);

            if board.cells[i][j] && n_live_neighbors != 2 && n_live_neighbors != 3 {
                death_board.cells[i][j] = true;
            }
            if !board.cells[i][j] && n_live_neighbors == 3 {
                life_board.cells[i][j] = true;
            }
        }
    }

    return (life_board, death_board);
}
