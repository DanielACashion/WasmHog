const std = @import("std");
const Board = @import("board").Board;
const height = 10;
const width = 10;

pub fn main(init: std.process.Init) !void {
    std.debug.print("Hello\n", .{});
    var game_board = try Board.init(init.gpa, width, height);
    defer game_board.deinit(init.gpa);
    try game_board.setCell(1, 0, 1);
    try game_board.setCell(2, 1, 1);
    try game_board.setCell(0, 2, 1);
    try game_board.setCell(1, 2, 1);
    try game_board.setCell(2, 2, 1);
    const clock = std.Io.Clock.awake;
    const sleep_duration = std.Io.Duration.fromMilliseconds(100);
    while (true) {
        game_board.printBoard();
        game_board.step();
        try std.Io.sleep(init.io, sleep_duration, clock);
    }

    const aliveNighbor = game_board.countAliveNeighbors(1, 4);
    std.debug.print("Alive: {d}\n", .{aliveNighbor});
}
