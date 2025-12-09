const std = @import("std");
const _09 = @import("_09");

const Point = struct {
    x: i64,
    y: i64,
    pub fn equals(self: *const Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }
};
const Edge = struct { from: Point, to: Point };
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    try readInput(alloc, "input.txt");
}
fn signedArea(p1: Point, p2: Point, p3: Point) i64 {
    return (p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y);
    // negative if clockwise; twice the area of the triangle p1-p2-p3
}

fn ccw(p1: Point, p2: Point, p3: Point) i64 {
    const a = signedArea(p1, p2, p3);
    if (a < 0)
        return -1;
    if (a > 0)
        return 1;
    return 0;
}
fn intersect(s0: Edge, s1: Edge) bool {
    if (s0.from.equals(s1.from) or
        s0.from.equals(s1.to) or
        s0.to.equals(s1.from) or
        s0.to.equals(s1.to))
        return true;

    if (ccw(s0.from, s0.to, s1.from) == 0 and
        ccw(s0.from, s0.to, s1.to) == 0)
        return (isOnSegment(s1.from, s0) or
            isOnSegment(s1.to, s0) or
            isOnSegment(s0.from, s1) or
            isOnSegment(s0.to, s1));

    return ((ccw(s0.from, s0.to, s1.from) * ccw(s0.from, s0.to, s1.to)) <= 0) and
        ((ccw(s1.from, s1.to, s0.from) * ccw(s1.from, s1.to, s0.to)) <= 0);
}

fn intersectNoOverlap(s0: Edge, s1: Edge) bool {
    return ((ccw(s0.from, s0.to, s1.from) * ccw(s0.from, s0.to, s1.to)) <= 0) and
        ((ccw(s1.from, s1.to, s0.from) * ccw(s1.from, s1.to, s0.to)) <= 0);
}
fn isOnSegment(p: Point, s: Edge) bool {
    return ccw(s.from, s.to, p) == 0 and
        p.x >= @min(s.from.x, s.to.x) and
        p.x <= @max(s.from.x, s.to.x) and
        p.y >= @min(s.from.y, s.to.y) and
        p.y <= @max(s.from.y, s.to.y);
}
fn isInPolygon(polyg: []Point, p: Point) bool {
    var count: i64 = 0;
    for (0..polyg.len) |i| {
        if (isOnSegment(p, Edge{ .from = polyg[i], .to = polyg[(i + 1) % polyg.len] }))
            return true;

        if (polyg[i].y <= p.y) {
            if (polyg[(i + 1) % polyg.len].y > p.y and
                ccw(polyg[i], polyg[(i + 1) % polyg.len], p) > 0)
                count += 1;
        } else {
            if (polyg[(i + 1) % polyg.len].y <= p.y and
                ccw(polyg[i], polyg[(i + 1) % polyg.len], p) < 0)
                count -= 1;
        }
    }
    return count != 0;
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) !void {
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    defer allocator.free(fileContents);
    var it = std.mem.splitSequence(u8, fileContents, "\n");
    var points: std.ArrayList(Point) = .empty;
    var maxArea: usize = 0;
    while (it.next()) |pointStr| {
        if (pointStr.len == 0) break;
        var ptIt = std.mem.splitSequence(u8, pointStr, ",");
        const x = try std.fmt.parseInt(i64, ptIt.next().?, 10);
        const y = try std.fmt.parseInt(i64, ptIt.next().?, 10);
        const newPoint = Point{ .x = x, .y = y };
        for (points.items) |point| {
            const newArea = area(newPoint, point);
            maxArea = @max(maxArea, newArea);
        }
        try points.append(allocator, newPoint);
    }
    std.debug.print("P1 : {}\n", .{maxArea});

    maxArea = 0;
    for (0..points.items.len) |a| {
        for (a + 1..points.items.len) |b| {
            const pointA = points.items[a];
            const pointB = points.items[b];
            if (try areaLegal(points.items, pointA, pointB)) {
                maxArea = @max(maxArea, area(pointA, pointB));
            }
        }
    }
    std.debug.print("P2 : {}\n", .{maxArea});
}

fn area(a: Point, b: Point) u64 {
    const ax: i64 = @intCast(a.x);
    const ay: i64 = @intCast(a.y);
    const bx: i64 = @intCast(b.x);
    const by: i64 = @intCast(b.y);
    return (1 + @abs(ax - bx)) * (1 + @abs(ay - by));
}

fn areaLegal(shape: []Point, a: Point, c: Point) !bool {
    const b = Point{ .x = a.x, .y = c.y };
    const d = Point{ .x = c.x, .y = a.y };

    const ab = Edge{ .from = a, .to = b };
    const bc = Edge{ .from = b, .to = c };
    const cd = Edge{ .from = c, .to = d };
    const da = Edge{ .from = d, .to = a };
    for (0..shape.len) |current| {
        const next = (current + 1) % shape.len;
        const currentEdge = Edge{ .from = shape[current], .to = shape[next] };
        if (intersectNoOverlap(currentEdge, ab) or
            intersectNoOverlap(currentEdge, bc) or
            intersectNoOverlap(currentEdge, cd) or
            intersectNoOverlap(currentEdge, da)) return false;
    }
    return true;
}
