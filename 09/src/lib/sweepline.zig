const std = @import("std");

pub const Vertex = struct {
    x: i64,
    y: i64,
};

pub const Edge = struct {
    vertexes: [2]Vertex,
};

pub const Polygon = struct {
    vertexEdges: std.AutoHashMap(Vertex, std.ArrayList(Edge)),
    vertexes: []Vertex,
    edges: []Edge,
    pub fn init(allocator: std.mem.Allocator, vertexes: []Vertex) !Polygon {
        const verts = try allocator.alloc(Vertex, vertexes.len);
        const edges = try allocator.alloc(Edge, vertexes.len);
        var vertexEdges = std.AutoHashMap(Vertex, std.ArrayList(Edge)).init(allocator);
        @memcpy(verts, vertexes);
        for (0..verts.len) |i| {
            const j = (i + 1) % verts.len;
            const current = verts[i];
            const next = verts[j];
            const edge = Edge{ .vertexes = .{ current, next } };
            edges[i] = edge;

            var currentEdges = try vertexEdges.getOrPutValue(
                current,
                std.ArrayList(Edge).empty,
            );
            var nextEdges = try vertexEdges.getOrPutValue(
                next,
                std.ArrayList(Edge).empty,
            );
            try currentEdges.value_ptr.append(allocator, edge);
            try nextEdges.value_ptr.append(allocator, edge);
        }
        return Polygon{ .vertexEdges = vertexEdges, .vertexes = verts, .edges = edges };
    }
};

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

    pub fn reset(self: *const SweepLine) !void {
        self.currentEvents = .empty;
        self.futureEvents = .empty;

        var points = try self.allocator.alloc(Vertex, self.p1.vertexes.len + self.p2.vertexes.len);

        @memcpy(points[0..self.p1.vertexes.len], self.p1.vertexes);
        @memcpy(points[self.p1.vertexes.len + 1 ..], self.p2.vertexes);
        std.mem.sort(Vertex, points, {}, &compareVertexes);

        for (points) |point| {
            self.futureEvents.insert(self.allocator, 0, point);
        }
        for (self.futureEvents.items) |v| {
            std.debug.print("{}\n", .{v.y});
        }
    }
};

fn compareVertexes(_: void, v1: Vertex, v2: Vertex) bool {
    return v1.y < v2.y;
}

pub fn area(a: Vertex, b: Vertex) u64 {
    const ax: i64 = @intCast(a.x);
    const ay: i64 = @intCast(a.y);
    const bx: i64 = @intCast(b.x);
    const by: i64 = @intCast(b.y);
    return (1 + @abs(ax - bx)) * (1 + @abs(ay - by));
}
