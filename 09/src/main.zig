const std = @import("std");
const _09 = @import("_09");
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
            const rect = rectFromAngles(point, newPoint);
            const newArea = types.polygonArea(rect);
            maxArea = @max(maxArea, newArea);
        }
        try points.append(allocator, newPoint);
    }
    std.debug.print("P1 : {any}\n", .{maxArea});

    maxArea = 0;
    const fullArea = types.polygonArea(points.items);
    for (0..points.items.len) |i| {
        const a = points.items[i];
        for (i + 1..points.items.len) |j| {
            const c = points.items[j];
            const rect = rectFromAngles(a, c);
            const rectArea = types.polygonArea(rect);
            const p1Area = types.polygonArea(points.items[i + 1 .. j]);
            var p2 = std.ArrayList(Vertex).empty;
            for (points.items[j..]) |v| {
                try p2.append(allocator, v);
            }
            for (points.items[0..i]) |v| {
                try p2.append(allocator, v);
            }
            const p2Area = types.polygonArea(p2.items);
            if (fullArea - rectArea == p1Area + p2Area) {
                maxArea = @max(maxArea, rectArea);
            }
        }
    }
    std.debug.print("P2 : {any}\n", .{maxArea});
}

fn rectFromAngles(v1: Vertex, v2: Vertex) []const Vertex {
    const maxX = @max(v1.x,v2.x);
    const maxY = @max(v1.y,v2.y);
    const minX = @min(v1.x,v2.x);
    const minY = @min(v1.y,v2.y);

    const a = Vertex{.x=minX, .y=minY};
    const b = Vertex{.x=maxX, .y=minY};
    const c = Vertex{.x=maxX, .y=maxY};
    const d = Vertex{.x=minX, .y=maxY};
    const res : [4]Vertex = .{a,b,c,d};
    return &res;
}
