const std = @import("std");
const base = 100;
const start = 50;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("Memory leak");
    }
    // Prints to stderr, ignoring potential errors.
    const data = try readData(allocator);
    defer allocator.free(data);
    try solve(data);
}
fn readData(allocator: std.mem.Allocator) ![]const u8 {
    var argv = try std.process.argsWithAllocator(allocator);
    defer argv.deinit();
    _ = argv.next();
    const filename = if (argv.next()) |a| std.mem.sliceTo(a, 0) else "test.txt";

    var file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();
    const stat = try file.stat();
    return try file.readToEndAlloc(allocator, stat.size);
}
fn turnDial(move: []const u8, current: *i32, zeroes: *u32) !void {
    if (move.len == 0) return;
    var offset = try std.fmt.parseInt(i32, move[1..], 10);
    if (move[0] == 'L') {
        offset = -offset;
    }
    current.* = @mod(current.* + offset, base);
    if (current.* == 0) {
        zeroes.* += 1;
    }
}

fn turnDial2(move: []const u8, current: *i32, zeroes: *u32) !void {
    if (move.len == 0) return;
    var curr = current.*;
    var offset = try std.fmt.parseInt(i32, move[1..], 10);
    if (move[0] == 'L') {
        offset = -offset;
    }

    curr = curr + offset;
    const loops = @divFloor(@abs(offset), base);
    zeroes.* += loops;

    std.debug.print("[{}, {}, {}]  ", .{ curr, offset, @divFloor(@abs(offset), base) });
    if (loops == 0 and (curr < 0 or curr >= base)) {
        zeroes.* += 1;
    }
    current.* = @mod(curr, base);
}

fn solve(data: []const u8) !void {
    var zeroesFirst: u32 = 0;
    var currentFirst: i32 = start;
    var zeroesSecond: u32 = 0;
    var currentSecond: i32 = 50;
    var it = std.mem.splitScalar(u8, data, '\n');
    while (it.next()) |move| {
        try turnDial(move, &currentFirst, &zeroesFirst);
        try turnDial2(move, &currentSecond, &zeroesSecond);
        std.debug.print("Current {}/{} ({s}) | Zeroes : {}/{}\n", .{ currentFirst, currentSecond, move, zeroesFirst, zeroesSecond });
    }
    std.debug.print("Zeroes : {}\n", .{zeroesFirst});
    std.debug.print("Zeroes : {}\n", .{zeroesSecond});
}
