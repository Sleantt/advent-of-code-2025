const std = @import("std");
const pow = std.math.pow;
const _08 = @import("_08");
const set = @import("ziglangSet");

var id: usize = 0;
const Point = struct {
    x: u64,
    y: u64,
    z: u64,
    id: usize,
    distances: std.AutoHashMap(Point, f64),
    pub fn distanceTo(self: *const Point, other: *Point) f64 {
        const x1: i64 = @intCast(self.x);
        const x2: i64 = @intCast(other.x);
        const y1: i64 = @intCast(self.y);
        const y2: i64 = @intCast(other.y);
        const z1: i64 = @intCast(self.z);
        const z2: i64 = @intCast(other.z);
        return @sqrt(@as(f64, @floatFromInt(pow(i64, x2 - x1, 2) + pow(i64, y2 - y1, 2) + pow(i64, z2 - z1, 2))));
    }
};
const Game = struct {
    allocator: std.mem.Allocator,
    points: std.ArrayList(Point) = .empty,
    groups: std.ArrayList(set.Set(Point)) = .empty,
    pub fn init(allocator: std.mem.Allocator) Game {
        return Game{ .allocator = allocator };
    }
    pub fn mergeGroups(a: *Point, b: *Point) !void {
        if (a.group.eql(b.group)) return;
        try a.group.unionUpdate(b.group);

        b.group = a.group;
    }
    pub fn addPoint(self: *Game, x: u64, y: u64, z: u64) !void {
        const ptDist = std.AutoHashMap(Point, f64).init(self.allocator);
        var pt = Point{ .id = id, .x = x, .y = y, .z = z,  .distances = ptDist };
        id += 1;

        for (self.points.items) |*other| {
            const dist = pt.distanceTo(other);
            var otherDists = &(other.distances);
            try otherDists.put(pt, dist);
        }
        try self.points.append(self.allocator, pt);
    }
};
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readInput(alloc, "input.txt");
    try solve(alloc, input, 1000);
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) !Game {
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    defer allocator.free(fileContents);
    var it = std.mem.splitSequence(u8, fileContents, "\n");
    var game = Game.init(allocator);
    while (it.next()) |pointStr| {
        if (pointStr.len == 0) break;
        var ptIt = std.mem.splitSequence(u8, pointStr, ",");
        const x = try std.fmt.parseInt(u46, ptIt.next().?, 10);
        const y = try std.fmt.parseInt(u46, ptIt.next().?, 10);
        const z = try std.fmt.parseInt(u46, ptIt.next().?, 10);
        try game.addPoint(x, y, z);
    }
    return game;
}
const Pair = struct {
    a: Point,
    b: Point,
    dist: f64,
};
fn comparePair(_: void, a: Pair, b: Pair) bool {
    return a.dist < b.dist;
}
fn solve(allocator: std.mem.Allocator, game: Game, maxLinks: usize) !void {
    var handledPoints = set.Set(Point).init(allocator);
    var pairsWithDistances: std.ArrayList(Pair) = .empty;
    for (game.points.items) |point| {
        var it = point.distances.iterator();
        while (it.next()) |entry| {
            const other = entry.key_ptr.*;
            if (handledPoints.contains(other)) continue;
            const dist = entry.value_ptr.*;

            try pairsWithDistances.append(allocator, Pair{ .a = point, .b = other, .dist = dist });
        }
        _ = try handledPoints.add(point);
    }
    const sorted = pairsWithDistances.items;
    std.mem.sort(Pair, sorted, {}, comparePair);
    var groups = try allocator.alloc(u64, game.points.items.len);

    for (0..groups.len) |i| {
        groups[i] = i;
    }
    for (sorted[0..maxLinks]) |pair| {
        const groupA = groups[pair.a.id];
        const groupB = groups[pair.b.id];
        if (groupA == groupB) {
            continue;
        }
        for (0..groups.len) |i| {
            if (groups[i] == groupB) {
                groups[i] = groupA;
            }
        }
    }

    var counts = try allocator.alloc(u64, groups.len);
    @memset(counts, 0);
    for (0..groups.len) |i| {
        counts[groups[i]] += 1;
    }
    var res: u64 = 1;
    std.mem.sort(u64, counts, {}, std.sort.desc(u64));
    for (counts[0..3]) |n| {
        res *= n;
    }
    std.debug.print("{any}\n", .{res});
    var last : Pair = undefined;
    for (sorted[maxLinks..]) |pair| {
        const groupA = groups[pair.a.id];
        const groupB = groups[pair.b.id];
        if (groupA == groupB) {
            continue;
        }
        for (0..groups.len) |i| {
            if (groups[i] == groupB) {
                groups[i] = groupA;
            }
        }
        last = pair;
    }
    std.debug.print("{}", .{last.a.x * last.b.x});
}
