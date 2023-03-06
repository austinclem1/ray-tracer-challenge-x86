const std = @import("std");
const lib = @import("lib.zig");

const M4 = lib.M4;
const M3 = lib.M3;
const V4 = lib.V4;
const Environment = lib.Environment;
const Projectile = lib.Projectile;

extern const epsilon: f32;

pub fn main() !void {
    lib.makeClock();
}

export fn tick2(env: Environment, proj: Projectile) Projectile {
    var newProj = proj;
    newProj.velocity = lib.addV4(newProj.velocity, env.gravity);
    newProj.velocity = lib.addV4(newProj.velocity, env.wind);
    newProj.position = lib.addV4(newProj.position, newProj.velocity);
    return newProj;
}
