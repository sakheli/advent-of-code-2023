const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());
    var r = buf.reader();

    var msg_buf: [4096]u8 = undefined;
    var msg: ?[]u8 = undefined;
    var secretCode: u32 = 0;
    while (true) {
        msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

        if (msg == null) {
            break;
        }

        var codeOptions = std.ArrayList(u8).init(allocator);
        var letterNumbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

        for (msg.?, 0..msg.?.len) |value, i| {
            if (std.ascii.isDigit(value)) {
                try codeOptions.append(value);
                continue;
            }

            for (letterNumbers, 0..) |letter, j| {
                if (i + letter.len <= msg.?.len and std.mem.eql(u8, msg.?[i .. i + letter.len], letter)) {
                    const numberChar = try std.fmt.allocPrint(allocator, "{d}", .{@as(u32, @intCast(j)) + 1});
                    try codeOptions.append(numberChar[0]);
                    break;
                }
            }
        }

        const concatCode = [_]u8{ codeOptions.items[0], codeOptions.items[codeOptions.items.len - 1] };
        const currCode = try std.fmt.parseInt(u32, &concatCode, 10);

        secretCode += currCode;
        codeOptions.deinit();
    }

    std.debug.print("{d}\n", .{secretCode});
}
