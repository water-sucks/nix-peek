const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const flags_dep = b.dependency("flags", .{});
    const flags_mod = flags_dep.module("flags");

    const vaxis_dep = b.dependency("vaxis", .{});
    const vaxis_mod = vaxis_dep.module("vaxis");

    const zignix_dep = b.dependency("zignix", .{});
    const zignix_mod = zignix_dep.module("zignix");

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("flags", flags_mod);
    exe_mod.addImport("vaxis", vaxis_mod);
    exe_mod.addImport("zignix", zignix_mod);

    const exe = b.addExecutable(.{
        .name = "nix-peek",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
