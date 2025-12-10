const std = @import("std");
const _09 = @import("_09");
const sls = @import("lib/sweepline.zig");
const types = @import("lib/types.zig");
const Polygon = types.Polygon;
const Vertex = types.Vertex;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    try readInput(alloc, "input.txt");
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) !void {
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    defer allocator.free(fileContents);
    var it = std.mem.splitSequence(u8, fileContents, "\n");
    var points: std.ArrayList(Vertex) = .empty;
    var maxArea: u64 = 0;
    while (it.next()) |pointStr| {
        if (pointStr.len == 0) break;
        var ptIt = std.mem.splitSequence(u8, pointStr, ",");
        const x = try std.fmt.parseInt(i64, ptIt.next().?, 10);
        const y = try std.fmt.parseInt(i64, ptIt.next().?, 10);
        const newPoint = Vertex{ .x = x, .y = y };
        for (points.items) |point| {
            const newArea = sls.area(newPoint, point);
            maxArea = @max(maxArea, newArea);
        }
        try points.append(allocator, newPoint);
    }
    std.debug.print("P1 : {any}\n", .{ maxArea});

    const p1 = try Polygon.init(allocator, points.items);
    const p2 = try Polygon.init(allocator, points.items);
    var sw = sls.SweepLine.init(allocator, p1, p2);
    try sw.reset();
}


