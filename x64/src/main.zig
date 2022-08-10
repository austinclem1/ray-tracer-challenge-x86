const std = @import("std");

const V3 = extern struct {
    r: f32,
    g: f32,
    b: f32,
};

const Canvas = extern struct {
    w: usize,
    h: usize,
    data: [*]V3,
};

extern const epsilon: f32;

extern fn equV4(a: V4, b: V4) bool;
extern fn addV4(a: V4, b: V4) V4;
extern fn subV4(a: V4, b: V4) V4;
extern fn negV4(v: V4) V4;
extern fn mulV4(a: V4, b: V4) V4;
extern fn mulV4Scalar(v: V4, s: f32) V4;
extern fn divV4(a: V4, b: V4) V4;
extern fn divV4Scalar(v: V4, s: f32) V4;
extern fn magV4(v: V4) f32;
extern fn normV4(v: V4) V4;
extern fn dotV4(a: V4, b: V4) f32;
extern fn cross(a: V4, b: V4) V4;
extern fn createCanvas(width: usize, height: usize) Canvas;
extern fn writePixel(canvas: *Canvas, x: usize, y: usize, color: V3) void;

extern fn doPrint() void;

const V4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

const Environment = struct {
    wind: V4,
    gravity: V4,
};

const Projectile = struct {
    position: V4,
    velocity: V4,
};

pub fn main() void {
    const env = Environment{
        .wind = V4{
            .x = 1.0,
            .y = 0.0,
            .z = 1.0,
            .w = 0.0,
        },
        .gravity = V4{
            .x = 0.0,
            .y = -0.1,
            .z = 0.0,
            .w = 0.0,
        },
    };

    var proj = Projectile{
        .position = V4{
            .x = 0.0,
            .y = 10.0,
            .z = 0.0,
            .w = 0.0,
        },
        .velocity = V4{
            .x = 0.0,
            .y = 3.0,
            .z = 1.0,
            .w = 0.0,
        },
    };

    var canvas = createCanvas(5, 5);
    writePixel(&canvas, 0, 0, V3{ .r = 1, .g = 2, .b = 3 });
    writePixel(&canvas, 1, 3, V3{ .r = 1, .g = 2, .b = 3 });
    {
        var i: usize = 0;
        while (i < canvas.w * canvas.h) : (i += 1) {
            std.debug.print("{} {}\n", .{ i, canvas.data[i] });
        }
    }
    // std.debug.print("{}\n", .{canvas[0]});
    std.debug.print("{}\n", .{canvas});

    while (proj.position.y > 0.0) {
        proj = tick(env, proj);
        std.debug.print("{d:.6} {d:.6} {d:.6}\n", .{ proj.position.x, proj.position.y, proj.position.z });
    }
}

fn tick(env: Environment, proj: Projectile) Projectile {
    var newProj = proj;
    newProj.velocity = addV4(newProj.velocity, env.gravity);
    newProj.velocity = addV4(newProj.velocity, env.wind);
    newProj.position = addV4(newProj.position, newProj.velocity);
    return newProj;
}
