const std = @import("std");
const posix = std.posix;
const net = std.net;
const SendToError = posix.SendToError;
const SocketError = posix.SocketError;
const INET = posix.AF.INET;
const DGRAM = posix.SOCK.DGRAM;

pub const DatagramSocket = struct {
    socket: posix.socket_t,

    pub fn open() SocketError!DatagramSocket {
        return .{ .socket = try posix.socket(INET, DGRAM, 0) };
    }

    pub fn close(this: DatagramSocket) void {
        posix.close(this.socket);
    }

    pub fn sendto(
        this: DatagramSocket,
        addr: net.Address,
        msg: []const u8,
    ) SendToError!void {
        _ = try posix.sendto(this.socket, msg, 0, &addr.any, addr.getOsSockLen());
    }
};
