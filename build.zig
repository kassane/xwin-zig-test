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
        .cpp => {
            exe.addCSourceFile(.{
                .file = b.path(info.filepath),
                .flags = &.{
                    "-Wall",
                    "-Wextra",
                },
            });
            exe.want_lto = false;
            if (exe.rootModuleTarget().abi == .msvc) {
                xWin(b, exe);
                exe.linkLibC();
            } else {
                exe.linkLibCpp();
            }
        },
        .c => {
            exe.addCSourceFile(.{
                .file = b.path(info.filepath),
                .flags = &.{
                    "-Wall",
                    "-Wextra",
                },
            });
            if (exe.rootModuleTarget().abi == .msvc) {
                xWin(b, exe);
            }
            exe.linkLibC();
        },
        .zig => exe.root_module.root_source_file = b.path(info.filepath),
    }
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(info.filename(), b.fmt("Run the {s} app", .{info.filename()}));
    run_step.dependOn(&run_cmd.step);
}

const BuildInfo = struct {
    filepath: []const u8,
    filetype: enum {
        c,
        cpp,
        zig,
    },
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    fn filename(self: BuildInfo) []const u8 {
        var split = std.mem.splitSequence(u8, std.fs.path.basename(self.filepath), ".");
        return split.first();
    }
};
fn xWin(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const arch: []const u8 = switch (exe.rootModuleTarget().cpu.arch) {
        .x86_64 => "x64",
        .x86 => "x86",
        .arm, .armeb => "arm",
        .aarch64 => "arm64",
        else => @panic("Unsupported Architecture"),
    };

    exe.subsystem = .Console;

    exe.setLibCFile(.{ .cwd_relative = sdkPath("/libc.txt") });
    exe.addSystemIncludePath(.{ .cwd_relative = sdkPath("/.xwin/crt/include") });
    exe.addSystemIncludePath(.{ .cwd_relative = sdkPath("/.xwin/sdk/include") });
    exe.addSystemIncludePath(.{ .cwd_relative = sdkPath("/.xwin/sdk/include/10.0.22000/cppwinrt") });
    exe.addSystemIncludePath(.{ .cwd_relative = sdkPath("/.xwin/sdk/include/10.0.22000/ucrt") });
    exe.addSystemIncludePath(.{ .cwd_relative = sdkPath("/.xwin/sdk/include/10.0.22000/um") });
    exe.addSystemIncludePath(.{ .cwd_relative = sdkPath("/.xwin/sdk/include/10.0.22000/shared") });
    exe.addLibraryPath(.{ .cwd_relative = b.fmt(sdkPath("/.xwin/crt/lib/{s}"), .{arch}) });
    exe.addLibraryPath(.{ .cwd_relative = b.fmt(sdkPath("/.xwin/sdk/lib/ucrt/{s}"), .{arch}) });
    exe.addLibraryPath(.{ .cwd_relative = b.fmt(sdkPath("/.xwin/sdk/lib/um/{s}"), .{arch}) });
}
fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("relToPath requires an absolute path!");
    return comptime blk: {
        @setEvalBranchQuota(2000);
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}
