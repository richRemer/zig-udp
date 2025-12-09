const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("udp", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const udptest = b.addExecutable(.{
        .name = "udptest",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/udptest.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "udp", .module = module },
            },
        }),
    });

    b.installArtifact(udptest);
}
