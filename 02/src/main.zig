const std = @import("std");
const math = @import("math");
const _02 = @import("_02");

const Input = struct { from: u64, to: u64 };
pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const fileContents = try readInput(alloc, "input.txt");
    defer alloc.free(fileContents);
    var inputs = try parseInput(alloc, fileContents);
    defer inputs.deinit(alloc);

    var outputs = try findInvalidIds(alloc, inputs);
    defer outputs.deinit(alloc);
    var sum: u64 = 0;
    for (outputs.items) |val| {
        sum += val;
    }
    std.debug.print("{}\n", .{sum});

    var outputsP2 = try findInvalidIdsP2(alloc, inputs);
    defer outputsP2.deinit(alloc);
    var sumP2: u128 = 0;
    for (outputsP2.items) |val| {
        sumP2 += val;
    }
    std.debug.print("{}\n", .{sumP2});
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) ![]u8 {
    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 4096);

    // Print file contents
    return fileContents;
}

fn parseInput(allocator: std.mem.Allocator, fileContents: []u8) !std.ArrayList(Input) {
    var result: std.ArrayList(Input) = .empty;
    var it = std.mem.splitAny(u8, fileContents, ",");
    while (it.next()) |item| {
        const dash = findDashId(item);
        const partOne = item[0..dash];
        var partTwo = item[dash + 1 ..];
        if (partTwo[partTwo.len - 1] < 48) partTwo = partTwo[0 .. partTwo.len - 1];
        const from = try std.fmt.parseInt(u64, partOne, 10);
        const to = try std.fmt.parseInt(u64, partTwo, 10);
        try result.append(allocator, .{ .from = from, .to = to });
    }
    return result;
}

fn findDashId(text: []const u8) usize {
    for (text, 0..) |char, i| {
        if (char == '-') return i;
    }
    return 0;
}

fn findInvalidIds(allocator: std.mem.Allocator, values: std.ArrayList(Input)) !std.ArrayList(u64) {
    var result: std.ArrayList(u64) = .empty;
    for (values.items) |value| {
        for (value.to..value.from + 1) |i| {
            if (numberHalvesIdentical(i)) try result.append(allocator, i);
        }
    }
    return result;
}

fn findInvalidIdsP2(allocator: std.mem.Allocator, values: std.ArrayList(Input)) !std.ArrayList(u64) {
    var result: std.ArrayList(u64) = .empty;
    for (values.items) |value| {
        for (value.to..value.from + 1) |i| {
            if (numberSegmentsIdentical(i)) try result.append(allocator, i);
        }
    }
    return result;
}
fn stringsEqual(s1: []const u8, s2: []const u8) bool {
    if (s1.len != s2.len) return false;
    for (s1, s2) |c1, c2| {
        if (c1 != c2) return false;
    }
    return true;
}

fn numberHalvesIdentical(n: u64) bool {
    const digits: u64 = @intFromFloat(@floor(@log10(@as(f32, @floatFromInt(n)))) + 1);
    if (digits % 2 != 0) return false;
    const a = std.math.pow(u64, 10, digits / 2);
    const firstHalf = n / a;
    const secondHalf = n - (firstHalf * a);
    return firstHalf == secondHalf;
}
fn numberSegmentsIdentical(n: u64) bool {
    const digits: u64 = @intFromFloat(@floor(@log10(@as(f32, @floatFromInt(n)))) + 1);
    for (2..digits + 1) |s| {
        if (digits % s != 0) continue;
        if (compareSegments(digits, s, n)) {
            return true;
        }
    }
    return false;
}

fn compareSegments(digits: u64, segments: u64, n: u64) bool {
    const digitsPerPart = digits / segments;
    var parts: [1024]u64 = undefined;
    var number = n;
    var div = std.math.pow(u64, 10, digitsPerPart);
    parts[0] = number - ((number / div) * div);
    number /= div;
    for (1..segments) |i| {
        div = std.math.pow(u64, 10, digitsPerPart);
        parts[i] = number - ((number / div) * div);
        number /= div;
        if (parts[i] != parts[i - 1]) {
            return false;
        }
    }
    return true;
}
