const std = @import("std");
const types = @import("types.zig");
const Polygon = types.Polygon;
const Edge = types.Edge;
const Vertex = types.Vertex;

pub const SweepLine = struct {
    allocator: std.mem.Allocator,
    futureEvents: std.ArrayList(Vertex) = .empty,
    currentEvents: std.ArrayList(Vertex) = .empty,
    p1: Polygon,
    p2: Polygon,
    pub fn init(allocator: std.mem.Allocator, p1: Polygon, p2: Polygon) SweepLine {
        return SweepLine{
            .allocator = allocator,
            .p1 = p1,
            .p2 = p2,
        };
    }

    pub fn reset(self: *SweepLine) !void {
        self.currentEvents.clearAndFree(self.allocator);
        self.futureEvents.clearAndFree(self.allocator);

        var points = try self.allocator.alloc(Vertex, self.p1.vertexes.len + self.p2.vertexes.len);

        @memcpy(points[0..self.p1.vertexes.len], self.p1.vertexes);
        @memcpy(points[self.p1.vertexes.len..], self.p2.vertexes);
        std.mem.sort(Vertex, points, {}, compareVertexes);

        for (points) |point| {
            try self.futureEvents.insert(self.allocator, 0, point);
        }
    }
    pub fn polygonsIntersect(self : *SweepLine) !bool {

        while(self.futureEvents.pop()) |v| {
            
        }
    }
};

fn compareVertexes(_: void, v1: Vertex, v2: Vertex) bool {
    return v1.y < v2.y;
}

pub fn area(a: Vertex, b: Vertex) u64 {
    return (1 + @abs(a.x - b.x)) * (1 + @abs(a.y - b.y));
}
