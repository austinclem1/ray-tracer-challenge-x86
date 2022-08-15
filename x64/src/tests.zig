const std = @import("std");
const lib = @import("lib.zig");
const Color = lib.V3;
pub usingnamespace lib;

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
