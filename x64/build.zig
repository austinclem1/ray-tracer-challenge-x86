const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const nasm_cmd = b.addSystemCommand(&[_][]const u8{
        "nasm",
        "-felf64",
        "src/lib.asm",
        "-o",
        "obj/lib.o",
    });

    const exe = b.addExecutable("x64", "src/main.zig");
    {
        exe.step.dependOn(&nasm_cmd.step);
        exe.addObjectFile("obj/lib.o");
        exe.addObjectFile("func.o");

        exe.linkLibC();

        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();
    }

    const test_step = b.step("test", "Runs the test suite");
    {
        const test_suite = b.addTest("src/tests.zig");
        test_suite.step.dependOn(&nasm_cmd.step);
        test_suite.addObjectFile("obj/lib.o");

        test_step.dependOn(&test_suite.step);
    }

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
