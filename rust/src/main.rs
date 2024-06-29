use clap::Parser;
use std::{thread::sleep, time::Duration};

pub mod board;
pub mod game_rules;

use board::Board;

#[derive(Parser, Debug, Default)]
struct CLI {
    #[arg(long, short, default_value_t = false)]
    create_board: bool,

    #[arg(long, short, default_value_t = String::from("../boards/glider.json"))]
    board_json: String,
}

fn main() {
    let args = CLI::parse();
    let mut board: Board;
    if args.create_board {
        board = board::interactive_create_board();
    } else {
        board = Board::from_json(args.board_json.as_str());
    }

    const TIME_PER_FRAME: Duration = Duration::new(0, 100_000_000); //[s]
    loop {
        clear_terminal();
        board.print();

        game_rules::apply_game_of_life_rules(&mut board);

        sleep(TIME_PER_FRAME);
    }
}

fn clear_terminal() -> () {
    print!("\x1b[H\x1b[2J");
}
