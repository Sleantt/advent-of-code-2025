const std = @import("std");
pub const Vertex = struct {
    x: i64,
    y: i64,
    pub fn equals(self: *const Vertex, other: Vertex) bool {
        return self.x == other.x and self.y == other.y;
    }
};
fn signedArea(v1: Vertex, v2: Vertex, v3: Vertex) i64 {
    return (v2.x - v1.x) * (v3.y - v1.y) - (v3.x - v1.x) * (v2.y - v1.y);
    // negative if clockwise; twice the area of the triangle p1-p2-p3
}

fn ccw(v1: Vertex, v2: Vertex, v3: Vertex) i64 {
    const a = signedArea(v1, v2, v3);
    if (a < 0)
        return -1;
    if (a > 0)
        return 1;
    return 0;
}

fn isOnSegment(v: Vertex, from: Vertex, to: Vertex) bool {
    return ccw(from, to, v) == 0 and
        v.x >= @min(from.x, to.x) and
        v.x <= @max(from.x, to.x) and
        v.y >= @min(from.y, to.y) and
        v.y <= @max(from.y, to.y);
}
fn intersect(s0from: Vertex, s0to: Vertex, s1from: Vertex, s1to: Vertex) bool {
    return ((ccw(s0from, s0to, s1from) * ccw(s0from, s0to, s1to)) <= 0) and
        ((ccw(s1from, s1to, s0from) * ccw(s1from, s1to, s0to)) <= 0);
}

pub const Polygon = struct {
    allocator: std.mem.Allocator,
    vertexes: []Vertex,
    pub fn init(allocator: std.mem.Allocator, vertexes: []Vertex) !Polygon {
        const verts = try allocator.alloc(Vertex, vertexes.len);
        @memcpy(verts, vertexes);
        return Polygon{ .allocator = allocator, .vertexes = verts };
    }
    pub fn area() i64 {}
};

pub fn polygonArea(vertices: []const Vertex) i64 {
    if(vertices.len == 0) return 0;
    var sum1: f64 = 0;
    var sum2: f64 = 0;

    for (0..vertices.len) |current| {
        const next = (current + 1) % vertices.len;
        sum1 += @floatFromInt(vertices[current].x * vertices[next].y);
        sum2 += @floatFromInt(vertices[current].y * vertices[next].x);
    }

    sum1 += @floatFromInt(vertices[vertices.len-1].x * vertices[0].y);
    sum2 += @floatFromInt(vertices[vertices.len-1].y * vertices[0].x);
    return @intFromFloat(@abs(sum1 - sum2) / 2);
}
