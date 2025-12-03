const std = @import("std");
const _03 = @import("_03");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const inputs = try readInput(alloc, "input.txt");
    try solve(inputs, 12);
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) !std.ArrayList([]const u8) {
    // Read contents from file "./filename"
    var result: std.ArrayList([]const u8) = .empty;
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    var it = std.mem.splitSequence(u8, fileContents, "\n");
    while (it.next()) |item| {
        if (item.len == 0) continue;
        try result.append(allocator, item);
    }

    return result;
}
fn solve(inputs: std.ArrayList([]const u8), digits: comptime_int) !void {
    var result: u64 = 0;
    for (inputs.items) |input| {
        var candidate: [digits]u8 = undefined;
        var biggestId: usize = 0;
        for (0..input.len - (digits - 1)) |i| {
            if (input[i] > input[biggestId]) {
                biggestId = i;
            }
        }
        candidate[0] = input[biggestId];
        
        for (1..digits) |i| {
            biggestId += 1;
            for (biggestId ..input.len - (digits - 1 - i)) |j| {
                if (input[j] > input[biggestId]) {
                    biggestId = j;
                }
            }
            candidate[i] = input[biggestId];
        }
        std.debug.print("{s}\n", .{candidate});
        result += try std.fmt.parseInt(u64, &candidate, 10);
    }
    std.debug.print("{}\n", .{result});
}
