const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const str = b.dependency("zig-string", .{
        .target = target,
        .optimize = optimize,
    });

    const str_module = str.module("string");

    const lib = b.addStaticLibrary(.{
        .name = "advent_of_code",
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib.root_module.addImport("string", str_module);

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "advent_of_code",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("string", str_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
