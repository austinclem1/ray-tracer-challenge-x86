const std = @import("std");
const lib = @import("lib.zig");

const M4 = lib.M4;
const M3 = lib.M3;
const V4 = lib.V4;
const Environment = lib.Environment;
const Projectile = lib.Projectile;

extern const epsilon: f32;

pub fn main() !void {
    const m: M4 = [4][4]f32{
        [4]f32{-5, 2, 6, -8},
        [4]f32{1, -5, 1, 8},
        [4]f32{7, 7, -6, -7},
        [4]f32{1, -3, 7, 4},
    };
    var out: M4 = undefined;
    std.debug.print("{}\n", .{lib.cofactorM4(2, 3, &m)});
    std.debug.print("{}\n", .{lib.cofactorM4(3, 2, &m)});

    // lib.translation(1, 2, 3, &out);
    // lib.rotation_x(3.5, &out);
    lib.shearing(1, 2, 3, 4, 5, 6, &out);

    var p = lib.makeV4(1, 2, 3, 1);
    var v = lib.makeV4(1, 2, 3, 0);
    _ = lib.equV4(p, v);
    std.debug.print("{}\n", .{p});
    std.debug.print("{}\n", .{v});
    p = lib.mulM4V4(&out, p);
    v = lib.mulM4V4(&out, v);
    std.debug.print("{}\n", .{p});
    std.debug.print("{}\n", .{v});

    if (lib.inverseM4(&m, &out) >= 0) {
        for (out) |row| {
            for (row) |col| {
                std.debug.print("{}\n", .{col});
            }
        }
    } else {
        std.debug.print("not invertible\n", .{});
    }
}

export fn tick2(env: Environment, proj: Projectile) Projectile {
    var newProj = proj;
    newProj.velocity = lib.addV4(newProj.velocity, env.gravity);
    newProj.velocity = lib.addV4(newProj.velocity, env.wind);
    newProj.position = lib.addV4(newProj.position, newProj.velocity);
    return newProj;
}
