const std = @import("std");
const String = @import("string").String;

const lib = @import("../lib.zig");

const Allocator = std.mem.Allocator;

pub fn run(a: Allocator) !String {
    var input = try lib.getInput(a, 2024, 2);
    const lines = try input.lines();
    var count: u16 = 0;
    for (lines) |line| {
        const reports = try line.splitAll(" ");
        if (try check(a, reports, 0))
            count += 1;
    }
    return try String.init_with_contents(a, try std.fmt.allocPrint(a, "{d}", .{count}));
}

pub fn extra(a: Allocator) !String {
    var input = try lib.getInput(a, 2024, 2);
    const lines = try input.lines();
    var count: u16 = 0;
    for (lines) |line| {
        const reports = try line.splitAll(" ");
        if (try check(a, reports, 1))
            count += 1;
    }
    return try String.init_with_contents(a, try std.fmt.allocPrint(a, "{d}", .{count}));
}

fn check(a: Allocator, reports: [][]const u8, fix: u7) !bool {
    var i: usize = 0;
    var flag: bool = undefined;
    var last: i32 = undefined;
    while (lib.s2i(i32, reports, i, 10)) |num| : (i += 1) {
        defer last = num;
        if (i == 0) continue;
        if (i == 1) {
            if (last > num) {
                flag = true;
            } else {
                flag = false;
            }
        }
        var differ: i32 = undefined;
        if (flag) {
            differ = last - num;
        } else {
            differ = num - last;
        }
        if (differ < 1 or differ > 3) {
            if (fix != 0) {
                const new_reports = try lib.concatArrays(a, reports[0..i], reports[i + 1 ..]);
                std.debug.print("{s}\n", .{new_reports});
                defer a.free(new_reports);
                if (try check(a, new_reports, fix - 1)) {
                    return true;
                }
                if (i == 1) {
                    if (try check(a, reports[1..], fix - 1)) {
                        return true;
                    }
                }
            }
            break;
        }
    }
    return i == reports.len;
}
