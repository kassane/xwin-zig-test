const std = @import("std");

const Program = struct {
    path: []const u8,
    lang: enum { c, cpp, zig },
};

const programs = [_]Program{
    .{ .path = "src/hello-c.c", .lang = .c },
    .{ .path = "src/hello-cpp.cpp", .lang = .cpp },
    .{ .path = "src/hello-zig.zig", .lang = .zig },
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    for (programs) |program| addProgram(b, program, target, optimize);
}

fn addProgram(b: *std.Build, program: Program, target: std.Build.ResolvedTarget, optimize: std.builtin.Optimize) void {
    const name = std.fs.path.stem(program.path);
    const exe = b.addExecutable(.{
        .name = name,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = if (program.lang == .zig) b.path(program.path) else null,
        }),
    });

    if (program.lang != .zig) {
        exe.root_module.addCSourceFile(.{
            .file = b.path(program.path),
            .flags = &.{ "-Wall", "-Wextra" },
        });
        // zig ships no libc++ for the msvc abi: ziglang/zig#5312
        if (program.lang == .cpp and target.result.abi != .msvc) {
            exe.root_module.link_libcpp = true;
        } else {
            exe.root_module.link_libc = true;
        }
    }
    if (target.result.abi == .msvc) xwin(b, exe);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep()); // run from zig-out, not the cache
    run_cmd.addPassthruArgs(); // `zig build <name> -- args`

    const run_step = b.step(name, b.fmt("Run the {s} app", .{name}));
    run_step.dependOn(&run_cmd.step);
}

// zig bundles the mingw libraries only, so the msvc abi needs the SDK
// unpacked by `xwin` (see `libc.txt` and `zig libc`).
fn xwin(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const arch = switch (exe.rootModuleTarget().cpu.arch) {
        .x86 => "x86",
        .x86_64 => "x64",
        .arm, .armeb => "arm",
        .aarch64 => "arm64",
        else => @panic("unsupported architecture"),
    };

    exe.subsystem = .console;
    exe.setLibCFile(b.path("libc.txt"));

    // `libc.txt` covers the ucrt and crt headers; `um`, `shared` and atlmfc
    // are derived from them by zig.
    exe.root_module.addSystemIncludePath(b.path(".xwin/sdk/include/cppwinrt"));
    for ([_][]const u8{ ".xwin/crt/lib", ".xwin/sdk/lib/ucrt", ".xwin/sdk/lib/um" }) |dir| {
        exe.root_module.addLibraryPath(b.path(b.fmt("{s}/{s}", .{ dir, arch })));
    }
}
