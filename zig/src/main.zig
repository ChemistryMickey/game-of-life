const std = @import("std");
const board_pkg = @import("./board.zig");
const utils = @import("./utils.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const WAIT_TIME_SEC = 0.1;

pub fn main() !void {
    var board = try createBoardFromInputArguments();
    defer board.deinitCells();

    while (true) {
        try utils.clearTerminal();
        try board.print();

        try board.applyGameOfLifeRules();

        utils.sleepSec(WAIT_TIME_SEC);
    }
}

fn createBoardFromInputArguments() !board_pkg.Board {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) return board_pkg.Board.fromJson("../boards/acorn.json");

    for (args, 0..) |arg, i| {
        if (i == 0) continue;

        if (std.mem.eql(u8, arg, "--create_board")) {
            return board_pkg.interactiveCreateBoard();
        } else if (std.mem.eql(u8, arg, "--board_json")) {
            if (args.len < i + 1) return board_pkg.BoardConstructionErrors.ExpectedArgument;

            return board_pkg.Board.fromJson(args[i + 1]);
        }
    }

    return board_pkg.BoardConstructionErrors.UnrecognizedArguments;
}
