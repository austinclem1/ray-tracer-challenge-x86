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
extern fn destroyCanvas(canvas: *Canvas) void;
extern fn writePixel(canvas: *Canvas, x: isize, y: isize, color: V3) void;
extern fn printCanvasPPM(canvas: *Canvas) void;

extern fn doPrint() void;
extern fn doSim() void;

const V4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

const Environment = extern struct {
    wind: V4,
    gravity: V4,
};

const Projectile = extern struct {
    position: V4,
    velocity: V4,
};

pub fn main() void {
    doSim();
    const env = Environment{
        .wind = V4{
            .x = 0.0,
            .y = 0.0,
            .z = 0.0,
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
            .x = 1.0,
            .y = 3.0,
            .z = 0.0,
            .w = 0.0,
        },
    };

    proj = tick2(env, proj);

    // var canvas = createCanvas(80, 60);

    // while (proj.position.y > 0.0) : (proj = tick(env, proj)) {
    //     const white = V3{ .r = 1, .g = 1, .b = 1 };
    //     const canvas_x = @floatToInt(isize, proj.position.x);
    //     const canvas_y = canvas.w - @floatToInt(isize, proj.position.y);
    //     writePixel(&canvas, canvas_x, canvas_y, white);
    // }

    // printCanvasPPM(&canvas);
    // destroyCanvas(&canvas);
}

export fn tick2(env: Environment, proj: Projectile) Projectile {
    var newProj = proj;
    newProj.velocity = addV4(newProj.velocity, env.gravity);
    newProj.velocity = addV4(newProj.velocity, env.wind);
    newProj.position = addV4(newProj.position, newProj.velocity);
    return newProj;
}
