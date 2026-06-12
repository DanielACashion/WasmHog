const std = @import("std");

const height = 10;
const width = 10;

pub fn main(init: std.process.Init) !void {
    std.debug.print("Hello\n", .{});
    var game_board = Board.init();
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

const BoardErrors = error{
    INVALID_PLACEMENT,
};

const Board = struct {
    _board: [height * width]i8,

    fn init() Board {
        return .{
            ._board = [_]i8{0} ** (height * width),
        };
    }
    fn setCell(self: *Board, x: u8, y: u8, value: i8) BoardErrors!void {
        if (x >= width or y >= height) {
            return BoardErrors.INVALID_PLACEMENT;
        }
        self._board[y * width + x] = value;
    }
    fn printBoard(self: *const Board) void {
        std.debug.print("\x1B[2J\x1B[H", .{});
        for (0..height) |y| {
            for (0..width) |x| {
                const char = if (self._board[y * width + x] > 0) "#" else ".";
                std.debug.print("{s}", .{char});
            }
            std.debug.print("\n", .{});
        }
    }
    fn step(self: *Board) void {
        var newBoard = self._board;
        for (0..height) |y| {
            for (0..width) |x| {
                const ix: i8 = @intCast(x);
                const iy: i8 = @intCast(y);
                const aliveNeighbors = self.countAliveNeighbors(ix, iy);
                switch (self.isCellAlive(ix, iy)) {
                    0 => {
                        //cell is dead
                        newBoard[y * width + x] = if (aliveNeighbors == 3) 1 else 0;
                    },
                    1...255 => {
                        //cell is alive
                        newBoard[y * width + x] = if (aliveNeighbors == 2 or aliveNeighbors == 3) 1 else 0;
                    },
                }
            }
        }
        self._board = newBoard;
    }
    fn isCellAlive(self: *const Board, x: i8, y: i8) u8 {
        if (x < 0 or y < 0) {
            return 0;
        }
        const ux: u8 = @intCast(x);
        const uy: u8 = @intCast(y);
        return if (self._board[uy * width + ux] > 0) 1 else 0;
    }
    fn countAliveNeighbors(self: *const Board, x: i8, y: i8) u8 {
        const minusx: i8 = if (x - 1 < 0) x - 1 + width else x - 1;
        const minusy: i8 = if (y - 1 < 0) y - 1 + height else y - 1;
        const maxx: i8 = @mod((x + 1), width);
        const maxy: i8 = @mod((y + 1), height);
        return self.isCellAlive(minusx, minusy) + self.isCellAlive(x, minusy) + self.isCellAlive(maxx, minusy) +
            self.isCellAlive(minusx, y) + self.isCellAlive(maxx, y) +
            self.isCellAlive(minusx, maxy) + self.isCellAlive(x, maxy) + self.isCellAlive(maxx, maxy);
    }
};
