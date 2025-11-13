const std = @import("std");
const posix = std.posix;
const net = std.net;
const SendToError = posix.SendToError;
const SocketError = posix.SocketError;
const INET = posix.AF.INET;
const INET6 = posix.AF.INET6;
const DGRAM = posix.SOCK.DGRAM;

/// Socket for sending stateless datagrams over the network, e.g., for UDP.
pub fn DatagramSocket(family: posix.sa_family_t) type {
    return struct {
        fd: posix.socket_t,

        /// Open a new socket.
        pub fn open() SocketError!@This() {
            return .{ .fd = try posix.socket(family, DGRAM, 0) };
        }

        /// Close this socket.
        pub fn close(this: @This()) void {
            posix.close(this.fd);
        }

        /// Send a datagram message to an address.  The address family must
        /// match the address family of this socket.
        pub fn sendto(
            this: @This(),
            addr: net.Address,
            msg: []const u8,
        ) SendToError!void {
            _ = try posix.sendto(this.fd, msg, 0, &addr.any, addr.getOsSockLen());
        }
    };
}

/// Socket for sending stateless datagrams over IPv4.
pub const DatagramSocketv4 = DatagramSocket(posix.AF.INET);
/// Socket for sending stateless datagrams over IPv6.
pub const DatagramSocketv6 = DatagramSocket(posix.AF.INET6);
