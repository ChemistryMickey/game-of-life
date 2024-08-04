const std = @import("std");

pub fn clear_terminal() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("\x1b[H\x1b[2J");
}
