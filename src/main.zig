const std = @import("std");
const print = std.debug.print;

const zignix = @import("zignix");

pub fn main() !void {
    print("Goodbye, cruel world!\n", .{});
    print("nix version :: {s}\n", .{zignix.util.version()});
}

test {
    std.testing.refAllDecls(@This());
}
