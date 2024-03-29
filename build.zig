const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("lib", null);
    {
        const nasm_cmd = b.addSystemCommand(&[_][]const u8{
            "nasm",
            "-felf64",
            "src/lib.asm",
            "-o",
            "obj/lib.o",
        });

        lib.step.dependOn(&nasm_cmd.step);
        lib.addObjectFile("obj/lib.o");
        lib.addObjectFile("other.o");
        lib.linkLibC();
    }

    const emit_asm = b.option(bool, "emit-asm", "emit assembly") orelse false;

    const exe = b.addExecutable("x64", "src/main.zig");
    {
        exe.emit_asm = if (emit_asm) .emit else .default;

        exe.linkLibrary(lib);

        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();
    }

    {
        const fuzz_test_exe = b.addExecutable("fuzz_test_runner", "src/fuzz_test_runner.zig");

        fuzz_test_exe.linkLibrary(lib);

        fuzz_test_exe.setTarget(target);
        fuzz_test_exe.setBuildMode(mode);
        fuzz_test_exe.install();

        const fuzz_test_cmd = fuzz_test_exe.run();
        fuzz_test_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            fuzz_test_cmd.addArgs(args);
        }

        const fuzz_test_step = b.step("fuzz", "Run fuzz tests");
        fuzz_test_step.dependOn(&fuzz_test_cmd.step);
    }

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Runs the test suite");
    {
        const test_suite = b.addTest("src/tests.zig");
        test_suite.linkLibrary(lib);
        test_suite.linkLibC();

        test_step.dependOn(&test_suite.step);
    }
}
