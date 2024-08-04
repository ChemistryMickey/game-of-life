const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const MAX_JSON_SIZE = 2_000_000;

pub const Board = struct {
    cells: std.ArrayList(std.ArrayList(bool)),

    /// Allocates a std array list of std array lists. Use board.deinit to remove these cleanly.
    ///     This is technically non-ziggy because it allocates internally which is OO design
    pub fn fromJson(path: []const u8) !Board {
        var board = try Board.fromSize(0);
        board.deinitCells(); // clear out the cells because they're going to be replaced

        const buffer = try std.fs.cwd().readFileAlloc(allocator, path, MAX_JSON_SIZE);
        defer allocator.free(buffer);

        const parsed = try std.json.parseFromSlice([][]bool, allocator, buffer, .{});
        defer parsed.deinit();

        var bool_matrix = std.ArrayList(std.ArrayList(bool)).init(allocator); // Note: no deinit

        for (parsed.value, 0..) |arr_list, i| {
            try bool_matrix.append(std.ArrayList(bool).init(allocator));
            for (arr_list) |val| {
                try bool_matrix.items[i].append(val);
            }
        }

        board.cells = bool_matrix;

        return board;
    }

    /// Allocates a std array list of std array lists. Use board.deinit to remove these cleanly.
    ///     This is technically non-ziggy because it allocates internally which is OO design
    pub fn fromSize(side_len: usize) !Board {
        var array_list = std.ArrayList(std.ArrayList(bool)).init(allocator);
        for (0..side_len) |_| {
            var sub_array = std.ArrayList(bool).init(allocator);
            try sub_array.appendNTimes(false, @as(usize, side_len));
            try array_list.append(sub_array);
        }
        return Board{ .cells = array_list };
    }

    /// Applies the rules for game of life. They are the following:
    ///     Dies if n_neighbors is not 2 or 3
    ///     Lives/comes to life if n_neighbors is 3
    pub fn applyGameOfLifeRules(self: *Board) !void {
        const n_side = self.cells.items.len;
        var life_board = try Board.fromSize(n_side);
        defer life_board.deinitCells();
        var death_board = try Board.fromSize(n_side);
        defer death_board.deinitCells();

        for (0..n_side) |i| {
            for (0..n_side) |j| {
                const n_live_neighbors = self.getNLiveNeighbors(@intCast(i), @intCast(j));

                const should_die = (self.cells.items[i].items[j] and n_live_neighbors != 2 and n_live_neighbors != 3);
                if (should_die) death_board.cells.items[i].items[j] = true;

                const should_live = (!self.cells.items[i].items[j] and n_live_neighbors == 3);
                if (should_live) life_board.cells.items[i].items[j] = true;
            }
        }

        for (0..n_side) |i| {
            for (0..n_side) |j| {
                if (death_board.cells.items[i].items[j]) self.cells.items[i].items[j] = false;
                if (life_board.cells.items[i].items[j]) self.cells.items[i].items[j] = true;
            }
        }
    }

    /// Deallocates all sub-ArrayLists before deallocating top level ArrayList
    pub fn deinitCells(self: *Board) void {
        for (self.cells.items) |array_list| array_list.deinit();
        self.cells.deinit();
    }

    /// Gets the number of adjacent live neighbors at a cell address i and j
    pub fn getNLiveNeighbors(self: *Board, i: isize, j: isize) usize {
        var n_live_neighbors: usize = 0;
        const n_side = self.cells.items.len;
        const steps = [_]isize{ -1, 0, 1 };

        for (steps) |i_step| {
            for (steps) |j_step| {
                const is_self = ((i_step == 0) and (j_step == 0));
                if (is_self) continue;

                const out_of_bounds = ((i + i_step < 0) or (j + j_step < 0) or (i + i_step >= n_side) or (j + j_step >= n_side));
                if (out_of_bounds) continue;

                if (self.cells.items[@intCast(i + i_step)].items[@intCast(j + j_step)])
                    n_live_neighbors += 1;
            }
        }
        return n_live_neighbors;
    }

    pub fn print(self: *Board) !void {
        const stdout = std.io.getStdOut().writer();
        for (self.cells.items) |array_list| {
            for (array_list.items) |val| {
                if (val == true) {
                    try stdout.writeAll("▣  ");
                } else {
                    try stdout.writeAll(".  ");
                }
            }
            try stdout.writeAll("\n");
        }
    }
};

pub const BoardConstructionErrors = error{ ExpectedArgument, UnrecognizedArguments, CommaNotFound, AddressOutOfBounds };

pub fn interactiveCreateBoard() !Board {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    try stdout.writeAll("How many lines on each side is this board: ");

    const buffer = try allocator.alloc(u8, 20);
    defer allocator.free(buffer);

    var raw_line = try stdin.readUntilDelimiter(buffer, '\n');
    const n_sides = try std.fmt.parseInt(usize, raw_line, 10);
    var board = try Board.fromSize(n_sides);

    try stdout.print("Add 'live' cell addresses in the form 'a, b' in the range [{}, {})\nEnter blank or -1 to continue\n", .{ 0, n_sides });
    while (true) {
        try stdout.writeAll("Address: ");

        raw_line = try stdin.readUntilDelimiter(buffer, '\n');
        if (std.mem.eql(u8, raw_line, "-1") or std.mem.eql(u8, raw_line, "")) break;
        const address: [2]usize = getAddress(&raw_line, n_sides) catch |err| {
            try stdout.print("\nInvalid address, {any}! Enter an address in the form 'a, b' (the space is important) with a and b in the range [{}, {})\n", .{ err, 0, n_sides });
            continue;
        };

        board.cells.items[address[0]].items[address[1]] = true;
        try board.print();
    }

    return board;
}

fn getAddress(raw_line: *[]u8, n_sides: usize) ![2]usize {
    var delim_ind: isize = -1;
    for (raw_line.*, 0..) |char, i| {
        if (char == ',') {
            delim_ind = @intCast(i);
            break;
        }
    }
    if (delim_ind == -1) return BoardConstructionErrors.CommaNotFound;

    const slice_1 = raw_line.*[0..@intCast(delim_ind)];
    const slice_2 = raw_line.*[@intCast(delim_ind + 2)..];
    const ind_1 = try std.fmt.parseInt(usize, slice_1, 10);
    const ind_2 = try std.fmt.parseInt(usize, slice_2, 10);
    const arr = [2]usize{ ind_1, ind_2 };
    for (arr) |val|
        if (val > n_sides) return BoardConstructionErrors.AddressOutOfBounds;

    return arr;
}

// Tests
test "Board from size" {
    var board = try Board.fromSize(10);
    defer board.deinitCells();

    try std.testing.expect(board.cells.items[3].items[5] == false);
}

test "Board from JSON" {
    var board = try Board.fromJson("../boards/spinner.json");
    defer board.deinitCells();

    try std.testing.expect(board.cells.items[3].items[2] == true);
    try std.testing.expect(board.cells.items[3].items[3] == true);
    try std.testing.expect(board.cells.items[3].items[4] == true);
}

test "Board print" {
    var board = try Board.fromSize(3);
    defer board.deinitCells();

    board.cells.items[1].items[1] = true;

    try board.print();
}

test " Get live neighbors" {
    var board = try Board.fromSize(3);
    defer board.deinitCells();

    board.cells.items[1].items[1] = true;
    board.cells.items[1].items[2] = true;
    try std.testing.expect(board.getNLiveNeighbors(2, 1) == 2);

    board.cells.items[1].items[0] = true;
    try std.testing.expect(board.getNLiveNeighbors(2, 1) == 3);
}

test "Apply rules" {
    var board = try Board.fromSize(3);
    defer board.deinitCells();

    // Create a horizontal "Spinner"
    board.cells.items[1].items[0] = true;
    board.cells.items[1].items[1] = true;
    board.cells.items[1].items[2] = true;

    // Let it spin!
    try board.applyGameOfLifeRules();

    try std.testing.expect(board.cells.items[0].items[1] == true);
    try std.testing.expect(board.cells.items[2].items[1] == true);
    try std.testing.expect(board.cells.items[1].items[0] == false);
    try std.testing.expect(board.cells.items[1].items[1] == true);
    try std.testing.expect(board.cells.items[1].items[2] == false);

    try board.applyGameOfLifeRules();

    try std.testing.expect(board.cells.items[0].items[1] == false);
    try std.testing.expect(board.cells.items[2].items[1] == false);
    try std.testing.expect(board.cells.items[1].items[0] == true);
    try std.testing.expect(board.cells.items[1].items[1] == true);
    try std.testing.expect(board.cells.items[1].items[2] == true);
}
