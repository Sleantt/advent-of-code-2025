const std = @import("std");
const _07 = @import("_07");

const Point = struct { x: usize, y: usize };
const TileState = enum { START, EMPTY, SPLITTER, RAY };
const Tile = struct { state: TileState, value: u64 = 0 };
const Puzzle = struct {
    start: Point,
    board: [][]Tile,
    pub fn print(self: *const Puzzle) void {
        for (self.board) |line| {
            for (line) |tile| {
                switch (tile.state) {
                    TileState.SPLITTER => std.debug.print("^", .{}),
                    TileState.EMPTY => std.debug.print(".", .{}),
                    TileState.START => std.debug.print("S", .{}),
                    TileState.RAY => std.debug.print("|", .{}),
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const input = try readInput(alloc, "input.txt");
    std.debug.print("{}\n", .{solve(input, input.start)});
    input.print();
    const input2 = try readInput(alloc, "input.txt");
    std.debug.print("{}\n", .{solveP2(input2, input2.start)});
}

fn readInput(allocator: std.mem.Allocator, filename: []const u8) !Puzzle {
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    defer allocator.free(fileContents);
    var it = std.mem.splitSequence(u8, fileContents, "\n");

    var start: Point = undefined;
    var tmp: std.ArrayList([]Tile) = .empty;

    var i: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) break;

        try tmp.append(allocator, try allocator.alloc(Tile, line.len));
        for (0..line.len, line) |j, c| {
            var tile: TileState = undefined;
            switch (c) {
                '.' => tile = TileState.EMPTY,
                'S' => {
                    start = Point{ .x = i, .y = j };
                    tile = TileState.START;
                },
                else => tile = TileState.SPLITTER,
            }
            tmp.getLast()[j] = Tile{ .state = tile };
        }
        i += 1;
    }
    var board = try allocator.alloc([]Tile, tmp.items.len);
    for (0..tmp.items.len) |id| {
        board[id] = tmp.items[id];
    }
    return Puzzle{ .start = start, .board = board };
}
fn solve(puzzle: Puzzle, from: Point) u64 {
    var currentX = from.x;
    var split: u64 = 0;
    while (currentX < puzzle.board.len and puzzle.board[currentX][from.y].state != .RAY) {
        if (puzzle.board[currentX][from.y].state == .SPLITTER) {
            split += 1;
            split += solve(puzzle, Point{ .x = currentX, .y = from.y - 1 });
            split += solve(puzzle, Point{ .x = currentX, .y = from.y + 1 });
            return split;
        }
        puzzle.board[currentX][from.y].state = .RAY;
        currentX += 1;
    }
    return 0;
}
fn solveP2(puzzle: Puzzle, from: Point) u64 {
    var currentX = from.x;
    std.debug.print("[{};{}]\n", .{ from.x, from.y });
    while (currentX < puzzle.board.len) {
        if (puzzle.board[currentX][from.y].value > 0) {
            return puzzle.board[currentX][from.y].value;
        }
        if (puzzle.board[currentX][from.y].state == .SPLITTER) {
            const lSplit = solveP2(puzzle, Point{ .x = currentX, .y = from.y - 1 });
            const rSplit = solveP2(puzzle, Point{ .x = currentX, .y = from.y + 1 });
            puzzle.board[currentX][from.y].value = lSplit + rSplit;
            return lSplit + rSplit;
        }
        currentX += 1;
    }
    currentX -= 1;
    puzzle.board[currentX][from.y].value = 1;
    return puzzle.board[currentX][from.y].value;
}
