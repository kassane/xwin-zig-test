const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    buildExe(b, .{
        .filepath = "src/hello-c.c",
        .filetype = .c,
        .target = target,
        .optimize = optimize,
    });
    buildExe(b, .{
        .filepath = "src/hello-cpp.cpp",
        .filetype = .cpp,
        .target = target,
        .optimize = optimize,
    });

    // no need libc
    buildExe(b, .{
        .filepath = "src/hello-zig.zig",
        .filetype = .zig,
        .target = target,
        .optimize = optimize,
    });
}

fn buildExe(b: *std.Build, info: BuildInfo) void {
    const exe = b.addExecutable(.{
        .name = info.filename(),
        .target = info.target,
        .optimize = info.optimize,
    });
    switch (info.filetype) {
        // zig w/ msvc no has libcxx support
        // https://github.com/ziglang/zig/issues/5312
        .cpp, .c => {
            exe.addCSourceFile(info.filepath, &.{
                "-Wall",
                "-Wextra",
                // "-Werror",
            });
            exe.want_lto = false;
            exe.addSystemIncludePath(sdkPath("/.xwin/crt/include"));
            exe.addSystemIncludePath(sdkPath("/.xwin/sdk/include"));
            exe.addSystemIncludePath(sdkPath("/.xwin/sdk/include/10.0.22000/cppwinrt"));
            exe.addSystemIncludePath(sdkPath("/.xwin/sdk/include/10.0.22000/ucrt"));
            exe.addSystemIncludePath(sdkPath("/.xwin/sdk/include/10.0.22000/um"));
            exe.addSystemIncludePath(sdkPath("/.xwin/sdk/include/10.0.22000/shared"));
            exe.addLibraryPath(sdkPath("/.xwin/crt/lib/x86_64"));
            exe.addLibraryPath(sdkPath("/.xwin/sdk/lib/ucrt/x86_64"));
            exe.addLibraryPath(sdkPath("/.xwin/sdk/lib/um/x86_64"));
            exe.linkLibC();
        },
        .zig => exe.root_src = .{ .path = info.filepath },
    }
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(info.filename(), b.fmt("Run the {s} app", .{exe.name}));
    run_step.dependOn(&run_cmd.step);
}

const BuildInfo = struct {
    filepath: []const u8,
    filetype: enum {
        c,
        cpp,
        zig,
    },
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,

    fn filename(self: BuildInfo) []const u8 {
        var split = std.mem.split(u8, std.fs.path.basename(self.filepath), ".");
        return split.first();
    }
};

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("relToPath requires an absolute path!");
    return comptime blk: {
        @setEvalBranchQuota(2000);
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}
