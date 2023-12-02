const std = @import("std");

const GameConfig = struct { red: u8, green: u8, blue: u8 };

fn getPower(game: []u8) u32 {
    var colon = false;
    var skips: u8 = 0;
    var currentNumber: u8 = 0;
    const zero = '0';
    var minCubes = GameConfig{ .red = 0, .green = 0, .blue = 0 };

    for (game, 0..) |value, i| {
        if (value == ':') {
            colon = true;
        }

        if (!colon) {
            continue;
        }

        if (skips > 0) {
            skips -= 1;
            continue;
        }

        if (std.ascii.isDigit(value)) {
            if (i + 1 < game.len and std.ascii.isDigit(game[i + 1])) {
                currentNumber = (value - zero) * 10 + game[i + 1] - zero;
                skips = 1;
            } else {
                currentNumber = value - zero;
                skips = 0;
            }
        } else if (std.ascii.isAlphabetic(value)) {
            inline for (std.meta.fields(@TypeOf(minCubes))) |color| {
                if (i + color.name.len <= game.len and std.mem.eql(u8, game[i .. i + color.name.len], color.name)) {
                    skips = @as(u8, @intCast(color.name.len)) - 1;
                    const colorValue: u8 = @as(color.type, @field(minCubes, color.name));

                    if (currentNumber > colorValue) {
                        @field(minCubes, color.name) = currentNumber;
                    }

                    break;
                }
            }
        }
    }

    var power: u32 = 1;
    inline for (std.meta.fields(@TypeOf(minCubes))) |cube| {
        power *= @as(u32, @field(minCubes, cube.name));
    }

    return power;
}

pub fn main() !void {
    const reader = std.io.getStdIn().reader();
    var buf = std.io.bufferedReader(reader);
    var r = buf.reader();

    var msg_buf: [4096]u8 = undefined;
    var msg: ?[]u8 = undefined;

    var gameCounter: u32 = 1;
    var sum: u32 = 0;

    while (true) : (gameCounter += 1) {
        msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg == null) {
            break;
        }

        if (msg != null) {
            sum += getPower(msg.?);
        }
    }

    std.debug.print("{d}\n", .{sum});
}
