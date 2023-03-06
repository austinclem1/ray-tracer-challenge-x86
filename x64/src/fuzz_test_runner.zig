const std = @import("std");
const tests = @import("tests.zig");

const FuzzFn = fn (fuzz_seed: u64) error{TestUnexpectedResult}!void;
const fuzz_tests = [_]FuzzFn{
    tests.testCreateAndFillCanvas,
    tests.testVectorMath,
};

pub fn main() void {
    const seed = @truncate(u64, @bitCast(u128, std.time.nanoTimestamp()));
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        inline for (fuzz_tests) |t| {
            t(seed +% i) catch return;
        }
    }
}
