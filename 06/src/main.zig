const std = @import("std");
const _06 = @import("_06");

const CumulativeOperator = struct {
    value: u64,
    operation: *const fn (a: u64, b: u64) u64,
    pub fn apply(self: *CumulativeOperator, n: u64) void {
        self.value = self.operation(self.value, n);
    }
};

fn multiply(a: u64, b: u64) u64 {
    return a * b;
}

fn getMultiplication() CumulativeOperator {
    return CumulativeOperator{ .value = 1, .operation = &multiply };
}

fn add(a: u64, b: u64) u64 {
    return a + b;
}

fn getAddition() CumulativeOperator {
    return CumulativeOperator{ .value = 0, .operation = &add };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    try solve(alloc, "input.txt");
}

fn solve(allocator: std.mem.Allocator, filename: []const u8) !void {
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(allocator, filename, 1000000);
    defer allocator.free(fileContents);
    try partOne(allocator, fileContents);
    try partTwo(allocator, fileContents);
}

fn partOne(allocator: std.mem.Allocator, fileContents: []const u8) !void {
    var it = std.mem.splitBackwardsSequence(u8, fileContents, "\n");
    var operatorsLine: []const u8 = undefined;
    // Skip empty line(s)
    while (true) {
        operatorsLine = it.next().?;
        if (operatorsLine.len > 0) {
            break;
        }
    }
    const operatorsStrings = try getCharGroups(allocator, operatorsLine);
    var operators = try allocator.alloc(CumulativeOperator, operatorsStrings.len);
    for (0..operatorsStrings.len) |i| {
        if (std.mem.eql(u8, operatorsStrings[i], "*")) {
            operators[i] = getMultiplication();
        } else {
            operators[i] = getAddition();
        }
    }
    while (it.next()) |line| {
        const numbers = try getCharGroups(allocator, line);
        for (0..numbers.len) |i| {
            operators[i].apply(try std.fmt.parseInt(u64, numbers[i], 10));
        }
    }
    var res: u64 = 0;
    for (operators) |op| {
        res += op.value;
    }
    std.debug.print("{}\n", .{res});
}
fn getCharGroups(allocator: std.mem.Allocator, line: []const u8) ![][]u8 {
    var groups: std.ArrayList([]u8) = .empty;
    var current: std.ArrayList(u8) = .empty;
    defer groups.deinit(allocator);
    defer current.deinit(allocator);
    for (line) |char| {
        if (char == ' ') {
            if (current.items.len > 0) {
                const buffer = try allocator.alloc(u8, current.items.len);
                @memcpy(buffer, current.items);
                try groups.append(allocator, buffer);
                current = .empty;
            }
            continue;
        }
        try current.append(allocator, char);
    }
    if (current.items.len > 0) {
        const buffer = try allocator.alloc(u8, current.items.len);
        @memcpy(buffer, current.items);
        try groups.append(allocator, buffer);
        current = .empty;
    }
    const buffer = try allocator.alloc([]u8, groups.items.len);
    @memcpy(buffer, groups.items);
    return buffer;
}
fn partTwo(allocator: std.mem.Allocator, fileContents: []const u8) !void {
    var it = std.mem.splitSequence(u8, fileContents, "\n");
    var res: u64 = 0;
    const columns = it.peek().?.len;
    const lines = fileContents.len / (columns + 1);

    var currentOperator: CumulativeOperator = undefined;
    for (0..columns) |i| {
        var currentDigit: std.ArrayList(u8) = .empty;
        for (0..lines) |j| {
            const char = getCharAt(fileContents, i, j, columns + 1);
            switch (char) {
                ' ' => {
                    continue;
                },
                '+' => {
                    currentOperator = getAddition();
                    std.debug.print("Add : \n", .{});
                    break;
                },
                '*' => {
                    currentOperator = getMultiplication();
                    std.debug.print("Mul : \n", .{});
                    break;
                },
                else => {
                    try currentDigit.append(allocator, char);
                },
            }
        }
        if (currentDigit.items.len == 0) {
            res += currentOperator.value;
            std.debug.print("= {}\n", .{currentOperator.value});
            currentOperator = undefined;
            continue;
        }
        const number = try std.fmt.parseInt(u64, currentDigit.items, 10);
        currentOperator.apply(number);
        std.debug.print("   {}\n", .{number});
    }
    res += currentOperator.value;
    std.debug.print("= {}\n", .{currentOperator.value});
    std.debug.print("{}", .{res});
}
fn getCharAt(string: []const u8, column: usize, line: usize, linelength: usize) u8 {
    return string[line * linelength + column];
}
