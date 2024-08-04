const std = @import("std");
const board_pkg = @import("./board.zig");
const utils = @import("./utils.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const WAIT_TIME_SEC = 0.1;

pub fn main() !void {
    var board = try board_pkg.Board.from_json("../boards/acorn.json");
    defer board.deinit_cells();

    while (true) {
        try utils.clear_terminal();
        try board.print();

        try board.apply_game_of_life_rules();

        std.time.sleep(WAIT_TIME_SEC * 1e9);
    }
}
