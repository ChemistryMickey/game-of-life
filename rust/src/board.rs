use serde::Serialize;
use serde_json;
use std::io::{self, Write};

#[derive(Debug, Serialize)]
pub struct Board {
    pub cells: Vec<Vec<bool>>,
}

impl Board {
    pub fn new(n_side: usize) -> Board {
        let new_board = Board {
            cells: vec![vec![false; n_side]; n_side],
        };

        return new_board;
    }
    pub fn print(&self) -> () {
        for row in &self.cells {
            for val in row {
                if *val {
                    print!("▣  ");
                } else {
                    print!(".  ");
                }
            }
            println!();
        }
    }

    pub fn get_n_live_neighbors(&self, i: usize, j: usize) -> isize {
        let mut n_live_neighbors = 0;
        let n_side: i32 = self.cells.len() as i32;

        let steps: [i32; 3] = [-1, 0, 1];
        for i_step in steps.iter() {
            for j_step in steps.iter() {
                if *i_step == 0 && *j_step == 0 {
                    continue;
                }

                let i_comb: i32 = *i_step + (i as i32);
                let j_comb: i32 = *j_step + (j as i32);
                if (i_comb < 0) || (j_comb < 0) || (i_comb >= n_side) || (j_comb >= n_side) {
                    continue;
                }

                if self.cells[i_comb as usize][j_comb as usize] {
                    n_live_neighbors += 1;
                }
            }
        }

        return n_live_neighbors;
    }

    pub fn from_json(file_path: &str) -> Board {
        let mut new_board = Board::new(0);

        let conts = std::fs::read_to_string(file_path).expect("Could not read file!");
        let json: serde_json::Value =
            serde_json::from_str(&conts).expect("JSON not well formatted");

        if let serde_json::Value::Array(mat) = json {
            // create false vectors
            let n_side = mat.len();
            new_board.cells = vec![vec![false; n_side]; n_side];

            // Populate. This is very tortured... hm.
            for (i, row) in mat.iter().enumerate() {
                if let serde_json::Value::Array(col) = row {
                    for (j, val) in col.iter().enumerate() {
                        if let serde_json::Value::Bool(b) = val {
                            if *b {
                                new_board.cells[i][j] = true;
                            }
                        }
                    }
                }
            }
        }

        new_board.print();
        return new_board;
    }
}

pub fn interactive_create_board() -> Board {
    print!("How many lines on each side is this board: ");
    let _ = io::stdout().flush();

    let mut buffer = String::new();
    io::stdin()
        .read_line(&mut buffer)
        .expect("Unable to read line!");
    let n_sides: usize = buffer.trim().parse::<usize>().expect("Unable to parse!");

    let mut board = Board::new(n_sides);
    print!("{}", format!("Add \"live\" cell addresses in the form \"a, b\" in the range {n_sides}x{n_sides} (non-inclusive)\n(Enter -1 or a blank to continue)\n"));

    'outer: loop {
        buffer.clear();

        io::stdin()
            .read_line(&mut buffer)
            .expect("Unable to read line!");
        buffer = String::from(buffer.trim());
        if buffer == "-1" || buffer.is_empty() {
            break;
        }

        let addr_strs = buffer.split(",");
        let mut addrs: [i32; 2] = [0; 2];
        for (i, s) in addr_strs.enumerate() {
            addrs[i] = s.trim().parse::<i32>().expect("Failed to parse number");
        }

        for addr in addrs {
            if (addr >= n_sides as i32) || (addr < 0) {
                println!("Addresses must be in the range [0, {} - 1]!", n_sides);
                continue 'outer;
            }
        }

        if board.cells[addrs[0] as usize][addrs[1] as usize] {
            println!("{:?} is already alive!", addrs);
            continue;
        } else {
            board.cells[addrs[0] as usize][addrs[1] as usize] = true;
            board.print();
        }
    }

    println!("Where should this board be saved? (if blank, board won't be saved)");
    let mut save_path = String::new();
    io::stdin()
        .read_line(&mut save_path)
        .expect("Unable to read line!");
    save_path = String::from(save_path.trim());
    if !save_path.trim().is_empty() {
        let _ = std::fs::write(
            save_path,
            serde_json::to_string(&board.cells).expect("Unable to serialize!"),
        );
    }

    return board;
}
