const std = @import("std");

pub fn main() !void {
    std.debug.print("Sleep sorting\n", .{});
    const values = [_]usize{ 9, 40, 10, 1, 6, 45, 23, 50 };
    for (values) |num| {
        std.debug.print("{} ", .{num});
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    std.debug.print("\nSort numbers: ", .{});
    try sleepSort([values.len]usize, values, allocator);
    std.debug.print("\n", .{});
}

fn sleepSort(comptime T: type, nums: T, alloc: std.mem.Allocator) !void {
    var threadpool: std.Thread.Pool = undefined;
    try threadpool.init(.{ .allocator = alloc });
    defer threadpool.deinit();

    for (nums) |num| {
        try threadpool.spawn(sleep, .{num});
    }
}

fn sleep(num: usize) void {
    std.time.sleep(num * std.time.ns_per_ms);
    std.debug.print("{} ", .{num});
}
