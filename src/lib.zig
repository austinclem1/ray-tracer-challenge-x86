pub const V3 = extern struct {
    r: f32,
    g: f32,
    b: f32,
};

pub const V4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

pub const M4 = [4][4]f32;
pub const M3 = [3][3]f32;

pub const Canvas = extern struct {
    w: usize,
    h: usize,
    data: [*]V3,
};

pub const Environment = extern struct {
    wind: V4,
    gravity: V4,
};

pub const Projectile = extern struct {
    position: V4,
    velocity: V4,
};

pub fn makeV4(comptime x: f32, comptime y: f32, comptime z: f32, comptime w: f32) V4 {
    return V4{ .x = x, .y = y, .z = z, .w = w };
}

pub extern fn equV4(a: V4, b: V4) bool;
pub extern fn addV4(a: V4, b: V4) V4;
pub extern fn subV4(a: V4, b: V4) V4;
pub extern fn negV4(v: V4) V4;
pub extern fn mulV4(a: V4, b: V4) V4;
pub extern fn mulV4Scalar(v: V4, s: f32) V4;
pub extern fn divV4(a: V4, b: V4) V4;
pub extern fn divV4Scalar(v: V4, s: f32) V4;
pub extern fn magV4(v: V4) f32;
pub extern fn normV4(v: V4) V4;
pub extern fn dotV4(a: V4, b: V4) f32;
pub extern fn cross(a: V4, b: V4) V4;
pub extern fn createCanvas(width: usize, height: usize) Canvas;
pub extern fn destroyCanvas(canvas: *Canvas) void;
pub extern fn fillCanvas(canvas: *Canvas, color: V3) void;
pub extern fn writePixel(canvas: *Canvas, x: isize, y: isize, color: V3) void;
pub extern fn printCanvasPPM(canvas: *Canvas) void;
pub extern fn equM4(a: *const M4, b: *const M4) bool;
pub extern fn doSim() void;
pub extern fn tick(env: Environment, proj: Projectile) Projectile;
pub extern fn mulM4(a: *const M4, b: *const M4, out: *M4) void;
pub extern fn mulM4V4(m: *const M4, v: V4) V4;
pub extern fn transposeM4(m: *const M4, out: *M4) void;
pub extern fn subMat4(row: usize, col: usize, inMat: *const M4, outMat: *M3) void;
pub extern fn subMat3(row: usize, col: usize, inMat: *const M3, outMat: *[2][2]f32) void;
pub extern fn determinantM2(m: *const [2][2]f32) f32;
pub extern fn determinantM3(m: *const M3) f32;
pub extern fn determinantM4(m: *const M4) f32;
pub extern fn cofactorM4(row: usize, col: usize, m: *const M4) f32;
pub extern fn inverseM4(inMat: *const M4, outMat: *M4) i32;
pub extern fn translation(x: f32, y: f32, z: f32, outMat: *M4) void;
pub extern fn scaling(x: f32, y: f32, z: f32, outMat: *M4) void;
pub extern fn rotation_x(r: f32, outMat: *M4) void;
pub extern fn rotation_y(r: f32, outMat: *M4) void;
pub extern fn rotation_z(r: f32, outMat: *M4) void;
pub extern fn shearing(x_y: f32, x_z: f32, y_x: f32, y_z: f32, z_x: f32, z_y: f32, outMat: *M4) void;
pub extern fn rayAt(ray: *const Ray, t: f32) V4;
pub extern fn sphere(sphere_count: *u32) u32;
pub extern fn intersectSphere(sphere: u32, ray: *const Ray, xs_out: *[2]f32) bool;

pub extern fn makeClock() void;

pub extern const identM4: M4;

pub const Ray = extern struct {
    point: V4,
    dir: V4,
};

pub const Color = V3;
