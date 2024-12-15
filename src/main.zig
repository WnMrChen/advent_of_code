const std = @import("std");
const String = @import("string").String;

const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator(.{});
const info = std.log.info;

const aoc2024 = .{
    @import("./2024/day1.zig"),
};

pub fn main() !void {
    var gpa = GeneralPurposeAllocator{};
    defer {
        if (gpa.deinit() == .leak)
            info("内存泄漏！", .{});
    }
    const a = gpa.allocator();
    inline for (aoc2024) |puzzle| {
        var allocator = std.heap.ArenaAllocator.init(a);
        errdefer allocator.deinit();
        defer allocator.deinit();
        const result = try puzzle.run(allocator.allocator());
        info("{s}:", .{@typeName(puzzle)});
        info("{s}\n", .{result.str()});
    }
}
