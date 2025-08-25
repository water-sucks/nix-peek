const std = @import("std");

const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const zignix = @import("zignix");

const Model = @import("./model.zig").Model;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }

    const allocator = gpa.allocator();

    var app = try vxfw.App.init(allocator);
    defer app.deinit();

    const model = try allocator.create(Model);
    defer allocator.destroy(model);
    model.* = .{
        .lhs = .{ .text = "Left hand side" },
        .rhs = .{ .text = "right hand side" },
        .split = .{ .lhs = undefined, .rhs = undefined, .width = 10 },
    };

    model.split.lhs = model.lhs.widget();
    model.split.rhs = model.rhs.widget();

    try app.run(model.widget(), .{});
}

test {
    std.testing.refAllDecls(@This());
}
