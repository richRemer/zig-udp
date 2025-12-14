const std = @import("std");
const posix = std.posix;
const Address = std.net.Address;
const Allocator = std.mem.Allocator;
const BindError = posix.BindError;
const RecvFromError = posix.RecvFromError;
const SendToError = posix.SendToError;
const SocketError = posix.SocketError;

const INET = posix.AF.INET;
const INET6 = posix.AF.INET6;
const DGRAM = posix.SOCK.DGRAM;
const NONBLOCK = posix.SOCK.NONBLOCK;
const CLOEXEC = posix.SOCK.CLOEXEC;
const UDP = posix.IPPROTO.UDP;

/// Discrete datagram sent over the network.  A datagram consists of one or
/// more network packets.
pub const Datagram = struct {
    /// IP address of sender.
    from: Address,
    /// Data buffer.
    data: []u8,
};

/// Wrapper for a POSIX UDP socket.
pub const Socket = struct {
    /// POSIX socket backing this UDP socket.
    sock: posix.socket_t,

    /// Network family of socket.
    pub const Family = enum(u16) {
        /// IPv4 address.
        ipv4 = INET,
        /// IPv6 address.
        ipv6 = INET6,

        /// Extract the network family from a network address.
        pub fn fromAddress(addr: Address) Family {
            return @enumFromInt(addr.any.family);
        }
    };

    /// Options used to initialize socket.
    pub const Options = packed struct {
        /// Open socket in non-blocking mode.
        nonblock: bool = false,
        /// Set close-on-execute flag on socket.
        cloexec: bool = false,

        /// Return flags to be combined bitwise with the socket type when
        /// opening the underlying POSIX socket.
        fn getPosixType(this: Options) u32 {
            var typ: u32 = 0;
            if (this.nonblock) typ |= NONBLOCK;
            if (this.cloexec) typ |= CLOEXEC;
            return typ;
        }
    };

    /// Bind the socket to a network address.
    pub fn bind(this: Socket, addr: Address) BindError!void {
        try posix.bind(this.sock, &addr.any, addr.getOsSockLen());
    }

    /// Close the socket.
    pub fn close(this: Socket) void {
        posix.close(this.sock);
    }

    /// Open a new socket.
    pub fn open(family: Family, options: Options) SocketError!Socket {
        const typ = DGRAM | options.getPosixType();

        return .{
            .sock = try posix.socket(@intFromEnum(family), typ, UDP),
        };
    }

    /// Receive next datagram from socket.
    pub fn recv(this: Socket, buf: []u8) RecvFromError!Datagram {
        var addr: Address = undefined;
        var addr_len: posix.socklen_t = @sizeOf(Address);

        const len = try posix.recvfrom(this.sock, buf, 0, &addr.any, &addr_len);

        return .{
            .from = addr,
            .data = buf[0..len],
        };
    }

    /// Send a message to the specified network address using this socket.
    pub fn send(this: Socket, addr: Address, msg: []const u8) SendToError!void {
        _ = try posix.sendto(this.sock, msg, 0, &addr.any, addr.getOsSockLen());
    }
};
