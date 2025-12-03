const std = @import("std");
const _02 = @import("_02");
const qp = @import("qpEngine");

const Regex = qp.re.Regex;

const Input = struct { from: u64, to: u64 };
pub fn main() !void {
    // Initiate allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const fileContents = try readInput(alloc, "input.txt");
    defer alloc.free(fileContents);
    var inputs = try parseInput(alloc, fileContents);
    defer inputs.deinit(alloc);

    var regex = try Regex.from(
        \\^(\d+)\1$
    , false, alloc);
    defer regex.deinit();
    var outputs = try findInvalidIds(alloc, inputs, &regex);
    defer outputs.deinit(alloc);
    var sum: u64 = 0;
    for (outputs.items) |val| {
        sum += val;
    }
    std.debug.print("{}\n", .{sum});
    regex = try Regex.from(
        \\^(\d+)\1+$
    , false, alloc);

    var outputsP2 = try findInvalidIds(alloc, inputs, &regex);
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

fn findInvalidIds(allocator: std.mem.Allocator, values: std.ArrayList(Input), regex: *Regex) !std.ArrayList(u64) {
    var result: std.ArrayList(u64) = .empty;
    for (values.items) |value| {
        for (value.from..value.to + 1) |n| {
            const str = try std.fmt.allocPrint(allocator, "{d}", .{n});
            if (regex.*.search(str, null, null) != null) {
                try result.append(allocator, n);
            }
        }
    }
    return result;
}
