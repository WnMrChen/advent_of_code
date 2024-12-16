const std = @import("std");
const String = @import("string").String;

const Allocator = std.mem.Allocator;
const Dir = std.fs.Dir;
const cwd = std.fs.cwd;
const http = std.http;
const Uri = std.Uri;
const Header = http.Header;
const Client = http.Client;

const print = std.debug.print;

pub fn getInput(a: Allocator, year: u16, day: u8) !String {
    var dir = cwd();
    dir.access("input", .{}) catch |e| {
        if (e != error.FileNotFound) return e;
        try dir.makeDir("input");
    };

    var input_dir = try dir.openDir("input", .{});
    defer input_dir.close();
    const path = try std.fmt.allocPrint(a, "{d}_{d}.txt", .{ year, day });
    defer a.free(path);
    if (input_dir.openFile(path, .{ .mode = .read_only })) |f| {
        defer f.close();
        const text = try f.reader().readAllAlloc(a, std.math.maxInt(u32));
        defer a.free(text);
        const input = try String.init_with_contents(a, text);
        return input;
    } else |e| {
        if (e != error.FileNotFound) return e;
        const cookie = try dir.readFileAlloc(a, "cookie", 1024);
        defer a.free(cookie);
        var client = Client{ .allocator = a };
        defer client.deinit();
        var server_header_buffer: [1024]u8 = undefined;
        const uri = try std.fmt.allocPrint(a, "https://adventofcode.com/{d}/day/{d}/input", .{ year, day });
        defer a.free(uri);
        var req = try client.open(
            .GET,
            try Uri
                .parse(uri),
            .{
                .extra_headers = &[_]Header{
                    .{
                        .name = "Cookie",
                        .value = cookie,
                    },
                },
                .server_header_buffer = server_header_buffer[0..],
            },
        );
        defer req.deinit();
        try req.send();
        try req.finish();
        try req.wait();
        const text = try req.reader().readAllAlloc(a, std.math.maxInt(usize));
        defer a.free(text);
        var f = try input_dir.createFile(path, .{ .read = true });
        defer f.close();
        try f.writeAll(text[0 .. text.len - 1]);
        const input = try String.init_with_contents(a, text[0 .. text.len - 1]);
        return input;
    }
}

pub fn concatArrays(
    allocator: Allocator,
    array1: [][]const u8,
    array2: [][]const u8,
) ![][]const u8 {
    var new_array = try allocator.alloc([]const u8, array1.len + array2.len);

    for (array1, 0..) |item, i| {
        new_array[i] = item;
    }

    for (array2, 0..) |item, i| {
        new_array[array1.len + i] = item;
    }

    return new_array;
}

pub fn s2i(comptime T: type, buf: [][]const u8, index: usize, base: u8) ?T {
    if (index < buf.len)
        return std.fmt.parseInt(T, buf[index], base) catch return null
    else
        return null;
}
