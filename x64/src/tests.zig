const std = @import("std");

const V4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

const P4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

const Color = extern struct {
    r: f32,
    g: f32,
    b: f32,
};

extern fn addV4(a: V4, b: V4) V4;

// export fn dot(a: V4, b: V4) f32 {
//     return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
// }

extern fn doTrue() bool;

test "addV4" {
    const a = V4{
        .x = 0.5,
        .y = 1.0,
        .z = 2.0,
        .w = 3.0,
    };
    const b = V4{
        .x = 0.8,
        .y = 2.0,
        .z = 3.0,
        .w = 4.1,
    };
    const expected = V4{
        .x = a.x + b.x,
        .y = a.y + b.y,
        .z = a.z + b.z,
        .w = a.w + b.w,
    };
    const result = addV4(a, b);
    std.debug.print("{}\n", .{doTrue()});

    try std.testing.expect(result.x == expected.x and
        result.y == expected.y and
        result.z == expected.z and
        result.w == expected.w);
}
