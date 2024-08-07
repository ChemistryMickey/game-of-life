const std = @import("std");
const board_pkg = @import("./board.zig");
const utils = @import("./utils.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const WAIT_TIME_SEC = 0.1;

pub fn main() !void {
    var board = createBoardFromInputArguments() catch |err| {
        if (err == board_pkg.BoardConstructionErrors.HelpTextRequest) {
            try _printHelpText();
            return;
        }
        return err;
    };
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
            if (args.len < i + 1)
                return board_pkg.BoardConstructionErrors.ExpectedArgument;

            return board_pkg.Board.fromJson(args[i + 1]);
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            return board_pkg.BoardConstructionErrors.HelpTextRequest;
        } else if (std.mem.eql(u8, arg, "--random_board")) {
            if (args.len < i + 1)
                return board_pkg.BoardConstructionErrors.ExpectedArgument;

            const n_sides: usize = try std.fmt.parseInt(usize, args[i + 1], 10);
            const rand_threshold: f64 = try std.fmt.parseFloat(f64, args[i + 2]);

            if (rand_threshold > 1 or rand_threshold < 0)
                return board_pkg.BoardConstructionErrors.ValueOutOfBounds;
            return board_pkg.Board.randomBoard(n_sides, rand_threshold);
        }
    }

    return board_pkg.BoardConstructionErrors.UnrecognizedArguments;
}

fn _printHelpText() !void {
    const stdout = std.io.getStdOut().writer();
    const help_str =
        \\ Simple Game of Life (zig 0.13.0 version)
        \\ CLI Options:
        \\      --create_board - Interactively create a board (recommend just using the board-creator)
        \\      --board_json <path_to_board_json> - Load and run a board defined by a JSON
        \\      --random_board <n_squares_per_side [1, N]> <random_threshold [0, 1]> - Create a board with random live cells. 
        \\      -h or --help - Show this help text
        \\
    ;

    try stdout.writeAll(help_str);
}
