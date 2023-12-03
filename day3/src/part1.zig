const std = @import("std");

fn isSymbol(char: u8) bool {
    return !std.ascii.isAlphabetic(char) and !std.ascii.isDigit(char) and !std.ascii.isWhitespace(char) and char != '.';
}

fn getNumber(line: []u8, index: usize) !u32 {
    var numStart: usize = index;
    var numEnd: usize = line.len;

    var i: usize = if (index > 0) index else 0;
    while (i > 0) {
        i -= 1;
        if (!std.ascii.isDigit(line[i])) {
            numStart = i + 1;
            break;
        }

        if (i == 0) {
            numStart = 0;
        }
    }

    for (numStart..line.len) |j| {
        if (!std.ascii.isDigit(line[j])) {
            numEnd = j;
            break;
        }

        if (j == line.len - 1) {
            numEnd = line.len;
        }
    }

    const number = std.fmt.parseInt(u32, line[numStart..numEnd], 10) catch {
        std.debug.print("error char: {c}\n", .{line[index]});
        std.debug.print("error line: {s}\n", .{line});
        std.debug.print("error: {s} {d} {d} {d}\n", .{ line[numStart..numEnd], numStart, numEnd, index });
        return 0;
    };
    return number;
}

fn findNumbers(prevLine: ?[]u8, currLine: []u8, nextLine: ?[]u8) !u32 {
    var sum: u32 = 0;
    for (currLine, 0..) |char, i| {
        if (isSymbol(char)) {
            const lines = [_]?[]u8{ prevLine, currLine, nextLine };
            for (lines) |line| {
                if (line == null) {
                    continue;
                }

                var skip: bool = false;
                for (0..3) |j| {
                    if ((i == 0 and j == 0) or (i + j - 1 >= line.?.len)) {
                        continue;
                    }

                    const index = (i + j) - 1;

                    if (!skip and std.ascii.isDigit(line.?[index])) {
                        const number = getNumber(line.?, index) catch 0;

                        sum += number;
                        skip = true;
                    } else if (!std.ascii.isDigit(line.?[index])) {
                        skip = false;
                    }
                }
            }
        }
    }

    return sum;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const reader = std.io.getStdIn().reader();
    var buf = std.io.bufferedReader(reader);
    var r = buf.reader();

    var msg_buf: [4096]u8 = undefined;
    var msg: ?[]u8 = undefined;

    var lines = std.ArrayList([]u8).init(allocator);
    defer lines.deinit();

    while (true) {
        msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg == null) {
            break;
        }
        const line = try std.mem.Allocator.dupe(allocator, u8, msg.?);
        try lines.append(line);
    }

    var sum: u32 = 0;
    for (lines.items, 0..) |line, i| {
        var prevLine: ?[]u8 = null;
        var nextLine: ?[]u8 = null;

        if (i > 0) {
            prevLine = lines.items[i - 1];
        }

        if (i + 1 < lines.items.len) {
            nextLine = lines.items[i + 1];
        }

        sum += findNumbers(prevLine, line, nextLine) catch 0;
    }

    std.debug.print("{d}\n", .{sum});
}
