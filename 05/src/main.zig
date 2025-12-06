const std = @import("std");
const _05 = @import("_05");
const set = @import("ziglangSet");

const Range = struct {
    from: u64,
    to: u64,
    pub fn contains(self: *const Range, item: u64) bool {
        return item >= self.from and item <= self.to;
    }

    pub fn overlaps(self: *const Range, with: Range) bool {
        return self.contains(with.from) or with.contains(self.from);
    }
};
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    _ = try readInput(alloc, "input.txt");
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) !u64 {
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    defer allocator.free(fileContents);
    var it = std.mem.splitSequence(u8, fileContents, "\n");

    var res: u64 = 0;
    var ranges: std.ArrayList(Range) = .empty;
    var item = it.next().?;

    while (item.len > 0) {
        try ranges.append(allocator, try lineToRange(item));
        item = it.next().?;
    }
    ranges = try mergeAllRanges(allocator, ranges);
    while (it.next()) |line| {
        if (line.len == 0) break;
        for (ranges.items) |range| {
            if ((&range).contains(try std.fmt.parseInt(u64, line, 10))) {
                res += 1;
                break;
            }
        }
    }
    std.log.debug("Result P1 : {}\n", .{res});

    var resP2: u64 = 0;
    for (ranges.items) |range| {
        resP2 += 1 + range.to - range.from;
    }
    std.log.debug("Result P2 : {any}\n", .{resP2});
    return res;
}

fn lineToRange(line: []const u8) !Range {
    var it = std.mem.splitSequence(u8, line, "-");
    const from = try std.fmt.parseInt(u64, it.next().?, 10);
    const to = try std.fmt.parseInt(u64, it.next().?, 10);

    return Range{ .from = from, .to = to };
}
fn mergeAllRanges(allocator: std.mem.Allocator, ranges: std.ArrayList(Range)) !std.ArrayList(Range) {
    var res: std.ArrayList(Range) = .empty;
    var ignoreIds = set.Set(usize).init(allocator);
    for (0..ranges.items.len, ranges.items) |i, range| {
        if (ignoreIds.contains(i)) continue;
        var changed: bool = true;
        var merged = range;
        _ = try ignoreIds.add(i);
        while (changed) {
            changed = false;
            for (i + 1..ranges.items.len) |j| {
                std.debug.print("Comparing [{}-{}] and [{}-{}]\n", .{ merged.from, merged.to, ranges.items[j].from, ranges.items[j].to });
                if (ignoreIds.contains(j)) continue;
                if (merged.overlaps(ranges.items[j])) {
                    changed = true;
                    _ = try ignoreIds.add(j);
                    merged = mergeRanges(merged, ranges.items[j]);
                    std.debug.print("-> Merged to [{}-{}]\n", .{ merged.from, merged.to });
                }
            }
            var iter = ignoreIds.iterator();
            while (iter.next()) |el| {
                std.debug.print("{d} ", .{el.*});
            }

            std.debug.print("\n", .{});
        }
        try res.append(allocator, merged);
    }
    return res;
}
fn mergeRanges(r1: Range, r2: Range) Range {
    return Range{ .from = @min(r1.from, r2.from), .to = @max(r1.to, r2.to) };
}
