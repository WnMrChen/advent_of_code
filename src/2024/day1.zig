const std = @import("std");
const String = @import("string").String;

const lib = @import("../lib.zig");

const Allocator = std.mem.Allocator;

pub fn run(a: Allocator) !String {
    var input = try lib.getInput(a, 2024, 1);
    const lines = try input.splitAllToStrings("\n");
    var lefts = try a.alloc([5]u8, lines.len);
    var rights = try a.alloc([5]u8, lines.len);
    for (lines, 0..) |line, i| {
        const pair = try line.splitAll(" ");
        std.debug.assert(pair.len == 4);
        std.mem.copyForwards(u8, &lefts[i], pair[0]);
        std.mem.copyForwards(u8, &rights[i], pair[3]);
    }
    std.sort.block([5]u8, lefts, {}, sort);
    std.sort.block([5]u8, rights, {}, sort);
    var int: u128 = 0;
    for (lefts, rights) |l, r| {
        int += @abs((std.fmt.parseInt(i32, &l, 10) catch unreachable) - (std.fmt.parseInt(i32, &r, 10) catch unreachable));
    }

    const result = String.init_with_contents(a, try std.fmt.allocPrint(a, "{d}", .{int}));
    return result;
}

pub fn sort(_: void, a: [5]u8, b: [5]u8) bool {
    return std.fmt.parseInt(u32, &a, 10) catch unreachable < std.fmt.parseInt(u32, &b, 10) catch unreachable;
}
