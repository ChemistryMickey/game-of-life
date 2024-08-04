const std = @import("std");
const board_pkg = @import("./board.zig");
const utils = @import("./utils.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const WAIT_TIME_SEC = 0.1;

pub fn main() !void {
    var board = try board_pkg.Board.fromJson("../boards/acorn.json");
    defer board.deinitCells();

    while (true) {
        try utils.clearTerminal();
        try board.print();

        try board.applyGameOfLifeRules();

        std.time.sleep(WAIT_TIME_SEC * 1e9);
    }
}
