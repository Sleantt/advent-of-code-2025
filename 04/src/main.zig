const std = @import("std");
const _04 = @import("_04");

const State = enum { roll, removed, empty };
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readInput(alloc, "input.txt");
    var res = solve(input);
    std.debug.print("{}\n", .{res});

    while(true) {
        const res2 = solve(input);
        if (res2 == 0) break;
        res += res2;
    }
    std.debug.print("{}\n", .{res});
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) ![][]State {
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    defer allocator.free(fileContents);

    var it = std.mem.splitSequence(u8, fileContents, "\n");
    var lines: usize = 2;
    const columns: usize = it.peek().?.len + 2;
    while (it.next()) |item| {
        if (item.len == 0) break;
        lines += 1;
    }
    it.reset();
    var res: [][]State = undefined;
    res = try allocator.alloc([]State, lines);
    for (res) |*row| {
        row.* = try allocator.alloc(State, columns);
        @memset(row.*, State.empty);
    }
    for (1..lines - 1) |i| {
        const item = it.next().?;
        for (1..columns - 1) |j| {
            if (item[j - 1] == '@') {
                res[i][j] = .roll;
            }
        }
    }
    return res;
}

fn solve(input: [][]State) u64 {
    var res: u64 = 0;
    for (0..input.len) |i| {
        for (0..input[i].len) |j| {
            var neighbors: i8 = 0;
            if (input[i][j] != State.roll) continue;
            for (0..3) |k| {
                for (0..3) |l| {
                    if (input[i + k - 1][j + l - 1] != State.empty) neighbors += 1;
                }
            }
            if (neighbors < 5) {
                input[i][j] = .removed;
                res += 1;
            }
        }
    }
    for (0..input.len) |i| {
        for (0..input[i].len) |j| {
            if (input[i][j] == State.removed) input[i][j] = .empty;
        }
    }
    return res;
}
