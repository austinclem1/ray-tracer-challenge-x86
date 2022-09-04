const std = @import("std");
const pi = std.math.pi;
const sqrt2 = std.math.sqrt2;
const lib = @import("lib.zig");
const Color = lib.V3;
const M4 = lib.M4;
const M3 = lib.M3;

test "create and destroy canvas" {
    const width = 20;
    const height = 10;
    var canvas = lib.createCanvas(width, height);
    try std.testing.expect(std.c.malloc_usable_size(canvas.data) >= width * height * @sizeOf(Color));
    lib.destroyCanvas(&canvas);
}

test "create and fill canvas" {
    const width = 800;
    const height = 600;
    const black = Color{ .r = 0.0, .g = 0.0, .b = 0.0 };
    const purple = Color{ .r = 1.0, .g = 0.0, .b = 1.0 };
    var canvas = lib.createCanvas(width, height);

    lib.fillCanvas(&canvas, black);
    for (canvas.data[0 .. width * height]) |pixel| {
        try std.testing.expect(pixel.r == black.r);
        try std.testing.expect(pixel.g == black.g);
        try std.testing.expect(pixel.b == black.b);
    }

    lib.fillCanvas(&canvas, purple);
    for (canvas.data[0 .. width * height]) |pixel| {
        try std.testing.expect(pixel.r == purple.r);
        try std.testing.expect(pixel.g == purple.g);
        try std.testing.expect(pixel.b == purple.b);
    }

    lib.destroyCanvas(&canvas);
}

test "check equality of M4s" {
    const a: M4 = [4][4]f32{
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 1, 2, 3, 4 },
    };

    const b: M4 = [4][4]f32{
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 1, 2, 7, 4 },
        [4]f32{ 1, 2, 3, 4 },
    };

    const c: M4 = [4][4]f32{
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 1, 2, 7, 4 },
        [4]f32{ 1, 2, 3, 4 },
    };

    try std.testing.expect(lib.equM4(&a, &b) == false);
    try std.testing.expect(lib.equM4(&b, &c));
}

test "matrix multiplication" {
    const a: M4 = [4][4]f32{
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 5, 6, 7, 8 },
        [4]f32{ 9, 8, 7, 6 },
        [4]f32{ 5, 4, 3, 2 },
    };
    const b: M4 = [4][4]f32{
        [4]f32{ -2, 1, 2, 3 },
        [4]f32{ 3, 2, 1, -1 },
        [4]f32{ 4, 3, 6, 5 },
        [4]f32{ 1, 2, 7, 8 },
    };
    var result: M4 = undefined;
    lib.mulM4(&a, &b, &result);

    const expected: M4 = [4][4]f32{
        [4]f32{ 20, 22, 50, 48 },
        [4]f32{ 44, 54, 114, 108 },
        [4]f32{ 40, 58, 110, 102 },
        [4]f32{ 16, 26, 46, 42 },
    };
    try std.testing.expect(lib.equM4(&result, &expected));
}

test "identity matrix" {
    const m: M4 = [4][4]f32{
        [4]f32{ -2, 1, 2, 3 },
        [4]f32{ 3, 2, 1, -1 },
        [4]f32{ 4, 3, 6, 5 },
        [4]f32{ 1, 2, 7, 8 },
    };
    var result: M4 = undefined;
    lib.mulM4(&m, &lib.identM4, &result);
    try std.testing.expect(lib.equM4(&m, &result));
}

test "matrix vector multiply" {
    const m: M4 = [4][4]f32{
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 2, 4, 4, 2 },
        [4]f32{ 8, 6, 4, 1 },
        [4]f32{ 0, 0, 0, 1 },
    };
    const v = lib.makeV4(1, 2, 3, 1);
    const result = lib.mulM4V4(&m, v);

    try std.testing.expect(result.x == 18 and
        result.y == 24 and
        result.z == 33 and
        result.w == 1);
}

test "matrix transpose" {
    {
        const m: M4 = [4][4]f32{
            [4]f32{ 1, 2, 3, 4 },
            [4]f32{ 5, 6, 7, 8 },
            [4]f32{ 9, 10, 11, 12 },
            [4]f32{ 13, 14, 15, 16 },
        };
        var result: M4 = undefined;
        lib.transposeM4(&m, &result);
        const expected: M4 = [4][4]f32{
            [4]f32{ 1, 5, 9, 13 },
            [4]f32{ 2, 6, 10, 14 },
            [4]f32{ 3, 7, 11, 15 },
            [4]f32{ 4, 8, 12, 16 },
        };
        try std.testing.expect(lib.equM4(&result, &expected));
    }
    {
        var result: M4 = undefined;
        lib.transposeM4(&lib.identM4, &result);
        try std.testing.expect(lib.equM4(&result, &lib.identM4));
    }
}

test "submatrix" {
    const m: M4 = [4][4]f32{
        [4]f32{ 1, 2, 3, 4 },
        [4]f32{ 5, 6, 7, 8 },
        [4]f32{ 9, 10, 11, 12 },
        [4]f32{ 13, 14, 15, 16 },
    };
    var sub: M3 = undefined;
    const expected: M3 = [3][3]f32{
        [3]f32{ 1, 2, 4 },
        [3]f32{ 9, 10, 12 },
        [3]f32{ 13, 14, 16 },
    };
    lib.subMat4(1, 2, &m, &sub);
    var col: usize = 0;
    while (col < 3) : (col += 1) {
        var row: usize = 0;
        while (row < 3) : (row += 1) {
            try std.testing.expect(sub[col][row] == expected[col][row]);
        }
    }

    var sub_sub: [2][2]f32 = undefined;
    lib.subMat3(1, 2, &sub, &sub_sub);
    try std.testing.expect(sub_sub[0][0] == 1);
    try std.testing.expect(sub_sub[0][1] == 2);
    try std.testing.expect(sub_sub[1][0] == 13);
    try std.testing.expect(sub_sub[1][1] == 14);

    try std.testing.expect(lib.determinantM2(&sub_sub) == -12.0);
}

test "determinant" {
    const m: M3 = [3][3]f32{
        [3]f32{11, 12, 13},
        [3]f32{4, 6, 2},
        [3]f32{3, 4, 3},
    };

    try std.testing.expect(lib.determinantM3(&m) == 12.0);

    const m4: M4 = [4][4]f32{
        [4]f32{-2, -8, 3, 5},
        [4]f32{-3, 1, 7, 3},
        [4]f32{1, 2, -9, 6},
        [4]f32{-6, 7, 7, -9},
    };
    try std.testing.expect(lib.determinantM4(&m4) == -4071);
}

test "inverse matrix" {
    const m: M4 = [4][4]f32{
        [4]f32{8, -5, 9, 2},
        [4]f32{7, 5, 6, 1},
        [4]f32{-6, 0, 9, 6},
        [4]f32{-3, 0, -9, -4},
    };
    var out: M4 = undefined;
    try std.testing.expect(lib.inverseM4(&m, &out) == 0);
    const expected: M4 = [4][4]f32{
        [4]f32{-0.15385 , -0.15385 , -0.28205 , -0.53846},
        [4]f32{-0.07692 ,  0.12308 ,  0.02564 ,  0.03077},
        [4]f32{ 0.35897 ,  0.35897 ,  0.43590 ,  0.92308},
        [4]f32{-0.69231 , -0.69231 , -0.76923 , -1.92308},
    };
    // try std.testing.expect(lib.equM4(&out, &expected));
    for (out) |row, i| {
        for (row) |col, j| {
            try std.testing.expect(std.math.approxEqAbs(f32, col, expected[i][j], 0.000005));
        }
    }
}

test "translation" {
    var translation_mat: M4 = undefined;
    var inverse_translation_mat: M4 = undefined;
    lib.translation(3, 4, -5, &translation_mat);
    _ = lib.inverseM4(&translation_mat, &inverse_translation_mat);
    const p1 = lib.makeV4(9, 8, 7, 1);
    const p2 = lib.mulM4V4(&translation_mat, p1);
    const p3 = lib.mulM4V4(&inverse_translation_mat, p2);
    try std.testing.expect(lib.equV4(p2, lib.makeV4(12, 12, 2, 1)));
    try std.testing.expect(lib.equV4(p1, p3));

    const v1 = lib.makeV4(1, 2, 3, 0);
    const v2 = lib.mulM4V4(&translation_mat, v1);
    try std.testing.expect(lib.equV4(v1, v2));
}

test "scaling" {
    const p1 = lib.makeV4(2, 3, 4, 1);
    const v1 = lib.makeV4(7, -3, -4, 0);

    var transform: M4 = undefined;
    lib.scaling(1, 2, -3, &transform);
    var inv_transform: M4 = undefined;
    _ = lib.inverseM4(&transform, &inv_transform);

    const p2 = lib.mulM4V4(&transform, p1);
    const v2 = lib.mulM4V4(&transform, v1);

    try std.testing.expect(lib.equV4(p2, lib.makeV4(2, 6, -12, 1)));
    try std.testing.expect(lib.equV4(v2, lib.makeV4(7, -6, 12, 0)));

    const p3 = lib.mulM4V4(&inv_transform, p2);
    const v3 = lib.mulM4V4(&inv_transform, v2);

    try std.testing.expect(lib.equV4(p1, p3));
    try std.testing.expect(lib.equV4(v1, v3));
}

test "rotation" {
    // const p2 = lib.makeV4(0, 0, 1, 1);
    // const p3 = lib.makeV4(0, 1, 0, 1);
    // var half_quarter_y: M4 = undefined;
    // var full_quarter_y: M4 = undefined;
    // var half_quarter_z: M4 = undefined;
    // var full_quarter_z: M4 = undefined;

    // lib.rotation_y(pi / 4.0, &half_quarter_y);
    // lib.rotation_y(pi / 2.0, &full_quarter_y);
    // lib.rotation_z(pi / 4.0, &half_quarter_z);
    // lib.rotation_z(pi / 2.0, &full_quarter_z);

    {
        const p1 = lib.makeV4(0, 1, 0, 1);

        var half_quarter_x: M4 = undefined;
        lib.rotation_x(pi / 4.0, &half_quarter_x);
        var full_quarter_x: M4 = undefined;
        lib.rotation_x(pi / 2.0, &full_quarter_x);
        var inv_half_quarter_x: M4 = undefined;
        _ = lib.inverseM4(&half_quarter_x, &inv_half_quarter_x);

        const p2 = lib.mulM4V4(&half_quarter_x, p1);
        const expected_p2 = lib.makeV4(0, sqrt2 / 2.0, sqrt2 / 2.0, 1);

        const p3 = lib.mulM4V4(&full_quarter_x, p1);
        const expected_p3 = lib.makeV4(0, 0, 1, 1);

        const p4 = lib.mulM4V4(&inv_half_quarter_x, p2);

        try std.testing.expect(lib.equV4(p2, expected_p2));
        try std.testing.expect(
            lib.equV4(p3, expected_p3)
        );
        try std.testing.expect(lib.equV4(p4, p1));
    }

    {
        const p1 = lib.makeV4(0, 0, 1, 1);

        var half_quarter_y: M4 = undefined;
        lib.rotation_y(pi / 4.0, &half_quarter_y);
        var full_quarter_y: M4 = undefined;
        lib.rotation_y(pi / 2.0, &full_quarter_y);
        var inv_half_quarter_y: M4 = undefined;
        _ = lib.inverseM4(&half_quarter_y, &inv_half_quarter_y);

        const p2 = lib.mulM4V4(&half_quarter_y, p1);
        const expected_p2 = lib.makeV4(sqrt2 / 2.0, 0, sqrt2 / 2.0, 1);

        const p3 = lib.mulM4V4(&full_quarter_y, p1);
        const expected_p3 = lib.makeV4(1, 0, 0, 1);

        const p4 = lib.mulM4V4(&inv_half_quarter_y, p2);

        try std.testing.expect(lib.equV4(p2, expected_p2));
        try std.testing.expect(
            lib.equV4(p3, expected_p3)
        );
        try std.testing.expect(lib.equV4(p4, p1));
    }

    {
        const p1 = lib.makeV4(0, 1, 0, 1);

        var half_quarter_z: M4 = undefined;
        lib.rotation_z(pi / 4.0, &half_quarter_z);
        var full_quarter_z: M4 = undefined;
        lib.rotation_z(pi / 2.0, &full_quarter_z);
        var inv_half_quarter_z: M4 = undefined;
        _ = lib.inverseM4(&half_quarter_z, &inv_half_quarter_z);

        const p2 = lib.mulM4V4(&half_quarter_z, p1);
        const expected_p2 = lib.makeV4(-sqrt2 / 2.0, sqrt2 / 2.0, 0, 1);

        const p3 = lib.mulM4V4(&full_quarter_z, p1);
        const expected_p3 = lib.makeV4(-1, 0, 0, 1);

        const p4 = lib.mulM4V4(&inv_half_quarter_z, p2);

        try std.testing.expect(lib.equV4(p2, expected_p2));
        try std.testing.expect(
            lib.equV4(p3, expected_p3)
        );
        try std.testing.expect(lib.equV4(p4, p1));
    }
}

test "shearing" {
    var transform: M4 = undefined;
    lib.shearing(1, 0, 0, 0, 0, 0, &transform);
    const p1 = lib.makeV4(2, 3, 4, 1);
    const p2 = lib.mulM4V4(&transform, p1);
    const expected_p2 = lib.makeV4(5, 3, 4, 1);
    try std.testing.expect(lib.equV4(p2, expected_p2));
}
