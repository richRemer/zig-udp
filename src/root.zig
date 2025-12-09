const std = @import("std");
const posix = std.posix;
const net = std.net;
const SendToError = posix.SendToError;
const SocketError = posix.SocketError;
const DGRAM = posix.SOCK.DGRAM;

/// Send a datagram message to an address.  The address family must be valid
/// for a datagram socket, such as IPv4 or IPv6.  Returns the number of bytes
/// written to the socket.
pub fn sendto(
    addr: net.Address,
    msg: []const u8,
) (SocketError || SendToError)!usize {
    const fd = try posix.socket(addr.any.family, DGRAM, 0);
    defer posix.close(fd);

    return try posix.sendto(fd, msg, 0, &addr.any, addr.getOsSockLen());
}
