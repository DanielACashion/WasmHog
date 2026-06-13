const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const board_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/board/board.zig"),
    });

    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "board", .module = board_mod },
        },
    });
    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = main_mod,
    });
    const wasm_lib = b.addExecutable(
        .{
            .name = "board",
            .root_module = board_mod,
        },
    );
    exe.rdynamic = true;

    b.installArtifact(exe);
    b.installArtifact(wasm_lib);

    const run_step = b.step("run", "");
    const run_artifact = b.addRunArtifact(exe);
    run_step.dependOn(&run_artifact.step);
}
