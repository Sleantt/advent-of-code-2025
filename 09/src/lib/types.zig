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

