const std = @import("std");
const String = @import("string").String;

const Allocator = std.mem.Allocator;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator(.{});
const log = std.log;

const aoc2024 = .{
    @import("./2024/day1.zig"),
    @import("./2024/day2.zig"),
};

pub fn main() !void {
    var gpa = GeneralPurposeAllocator{};
    defer {
        if (gpa.deinit() == .leak)
            log.err("memory leak!", .{});
    }
    const a = gpa.allocator();
    try run(a, aoc2024);
}

fn run(a: Allocator, aoc: anytype) !void {
    inline for (aoc) |puzzle| {
        var allocator = std.heap.ArenaAllocator.init(a);
        defer allocator.deinit();
        const aa = allocator.allocator();
        var start = std.time.nanoTimestamp();
        const result = puzzle.run(aa) catch |e| {
            log.err("{s}", .{@errorName(e)});
            return e;
        };
        var end = std.time.nanoTimestamp();
        log.info("{s}", .{@typeName(puzzle)});
        log.info("time[{d}]={s}", .{ end - start, result.str() });
        if (@hasDecl(puzzle, "extra")) {
            start = std.time.nanoTimestamp();
            const extra_result = puzzle.extra(aa) catch |e| {
                log.err("{s}", .{@errorName(e)});
                return e;
            };
            end = std.time.nanoTimestamp();
            log.info("{s}.extra", .{@typeName(puzzle)});
            log.info("time[{d}]={s}", .{ end - start, extra_result.str() });
        }
        
    }
}
