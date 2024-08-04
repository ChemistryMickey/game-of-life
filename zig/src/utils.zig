const std = @import("std");

pub fn clearTerminal() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("\x1b[H\x1b[2J");
}
