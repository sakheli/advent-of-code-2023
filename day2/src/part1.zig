const std = @import("std");

const GameConfig = struct { red: u8, green: u8, blue: u8 };

fn isValid(game: []u8, gameConfig: GameConfig) bool {
    var colon = false;
    var skips: u8 = 0;
    var currentNumber: u8 = 0;
    const zero = '0';

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
            inline for (std.meta.fields(@TypeOf(gameConfig))) |color| {
                if (i + color.name.len < game.len and std.mem.eql(u8, game[i .. i + color.name.len], color.name)) {
                    skips = @as(u8, @intCast(color.name.len)) - 1;
                    const colorValue: u8 = @as(color.type, @field(gameConfig, color.name));
                    std.debug.print("{d}\n", .{colorValue});
                    if (currentNumber > colorValue) {
                        return false;
                    }

                    break;
                }
            }
        }
    }

    return true;
}

pub fn main() !void {
    const reader = std.io.getStdIn().reader();
    var buf = std.io.bufferedReader(reader);
    var r = buf.reader();

    var msg_buf: [4096]u8 = undefined;
    var msg: ?[]u8 = undefined;

    const gameConfig = GameConfig{ .red = 12, .green = 13, .blue = 14 };
    var gameCounter: u32 = 1;
    var sum: u32 = 0;

    while (true) : (gameCounter += 1) {
        msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg == null) {
            break;
        }

        if (msg != null and isValid(msg.?, gameConfig)) {
            sum += gameCounter;
        }
    }

    std.debug.print("{d}\n", .{sum});
}
