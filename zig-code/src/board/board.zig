const std = @import("std");

const BoardErrors = error{
    INVALID_PLACEMENT,
};

pub const Board = struct {
    _board: []i8,
    _scratch: []i8,
    width: i8,
    height: i8,

    pub fn init(gpa: std.mem.Allocator, width: i8, height: i8) !Board {
        const uHeight: usize = @intCast(height);
        const uWidth: usize = @intCast(width);
        const cells = try gpa.alloc(i8, uHeight * uWidth);
        const scratchCells = try gpa.alloc(i8, uHeight * uWidth);
        @memset(cells, 0);
        return .{
            ._board = cells,
            ._scratch = scratchCells,
            .width = width,
            .height = height,
        };
    }

    pub fn setCell(self: *Board, x: u8, y: u8, value: i8) BoardErrors!void {
        if (x >= self.width or y >= self.height) {
            return BoardErrors.INVALID_PLACEMENT;
        }
        const uWidth: u8 = @intCast(self.width);
        self._board[y * uWidth + x] = value;
    }
    pub fn printBoard(self: *const Board) void {
        std.debug.print("\x1B[2J\x1B[H", .{});
        const uHeight: usize = @intCast(self.height);
        const uWidth: usize = @intCast(self.width);
        for (0..uHeight) |y| {
            for (0..uWidth) |x| {
                const char = if (self._board[y * uWidth + x] > 0) "#" else ".";
                std.debug.print("{s}", .{char});
            }
            std.debug.print("\n", .{});
        }
    }
    pub fn step(self: *Board) void {
        const uHeight: usize = @intCast(self.height);
        const uWidth: usize = @intCast(self.width);
        for (0..uHeight) |y| {
            for (0..uWidth) |x| {
                const ix: i8 = @intCast(x);
                const iy: i8 = @intCast(y);
                const aliveNeighbors = self.countAliveNeighbors(ix, iy);
                switch (self.isCellAlive(ix, iy)) {
                    0 => {
                        //cell is dead
                        self._scratch[y * uWidth + x] = if (aliveNeighbors == 3) 1 else 0;
                    },
                    1...255 => {
                        //cell is alive
                        self._scratch[y * uWidth + x] = if (aliveNeighbors == 2 or aliveNeighbors == 3) 1 else 0;
                    },
                }
            }
        }
        std.mem.swap([]i8, &self._board, &self._scratch);
    }
    fn isCellAlive(self: *const Board, x: i8, y: i8) u8 {
        if (x < 0 or y < 0) {
            return 0;
        }
        const ux: u8 = @intCast(x);
        const uy: u8 = @intCast(y);
        const uWidth: usize = @intCast(self.width);
        return if (self._board[uy * uWidth + ux] > 0) 1 else 0;
    }
    pub fn countAliveNeighbors(self: *const Board, x: i8, y: i8) u8 {
        const minusx: i8 = if (x - 1 < 0) x - 1 + self.width else x - 1;
        const minusy: i8 = if (y - 1 < 0) y - 1 + self.height else y - 1;
        const maxx: i8 = @mod((x + 1), self.width);
        const maxy: i8 = @mod((y + 1), self.height);
        return self.isCellAlive(minusx, minusy) + self.isCellAlive(x, minusy) + self.isCellAlive(maxx, minusy) +
            self.isCellAlive(minusx, y) + self.isCellAlive(maxx, y) +
            self.isCellAlive(minusx, maxy) + self.isCellAlive(x, maxy) + self.isCellAlive(maxx, maxy);
    }
};

var board: Board = Board.init();
