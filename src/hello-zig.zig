const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    std.debug.print("Sleep sorting\n", .{});

    const values = [_]usize{ 9, 40, 10, 1, 6, 45, 23, 50 };
    for (values) |num| std.debug.print("{} ", .{num});

    std.debug.print("\nSort numbers: ", .{});
    try sleepSort(io, &values);
    std.debug.print("\n", .{});
}

fn sleepSort(io: std.Io, comptime nums: []const usize) !void {
    var threads: [nums.len]std.Thread = undefined;
    for (nums, &threads) |num, *thread| {
        thread.* = try std.Thread.spawn(.{}, sleep, .{ io, num });
    }
    for (threads) |thread| thread.join();
}

fn sleep(io: std.Io, num: usize) void {
    io.sleep(.fromMilliseconds(@intCast(num)), .awake) catch {};
    std.debug.print("{} ", .{num});
}
