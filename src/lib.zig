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
    const cookie = try cwd().readFileAlloc(a, "cookie", 1024);
    defer a.free(cookie);
    var client = Client{ .allocator = a };
    defer client.deinit();
    var server_header_buffer: [1024]u8 = undefined;
    const uri = try std.fmt.allocPrint(a, "https://adventofcode.com/{d}/day/{d}/input", .{ year, day });
    defer a.free(uri);
    var req = try client.open(.GET, try Uri
        .parse(uri), .{
        .extra_headers = &[_]Header{.{
            .name = "Cookie",
            .value = cookie,
        }},
        .server_header_buffer = server_header_buffer[0..],
    });
    defer req.deinit();
    try req.send();
    try req.finish();
    try req.wait();
    const text = try req.reader().readAllAlloc(a, std.math.maxInt(usize));
    defer a.free(text);
    const input = try String.init_with_contents(a, text);
    return input;
}

// pub fn bubbleSort(arr: []u8) void {
//     const len = arr.len;

//     for (0..len) |i| {
//         for (0..len - i - 1) |j| {
//             if (arr[j] > arr[j + 1]) {
//                 // 交换
//                 // const temp = arr[j];
//                 // arr[j] = arr[j + 1];
//                 // arr[j + 1] = temp;
//                 std.mem.swap(u8, &arr[j], &arr[j + 1]);
//             }
//         }
//     }
// }
