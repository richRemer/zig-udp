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

pub const Packet = struct {
    from: Address,
    data: []u8,
};

pub const Socket = struct {
    sock: posix.socket_t,

    pub const Family = enum(u16) {
        ipv4 = INET,
        ipv6 = INET6,

        pub fn fromAddress(addr: Address) Family {
            return @enumFromInt(addr.any.family);
        }
    };

    pub const Options = packed struct {
        /// Open socket in non-blocking mode.
        nonblock: bool = false,
        /// Set close-on-execute flag on socket.
        cloexec: bool = false,

        /// Return flags to be combined bitwise with the socket type when
        /// opening the socket.
        fn getPosixType(this: Options) u32 {
            var typ: u32 = 0;
            if (this.nonblock) typ |= NONBLOCK;
            if (this.cloexec) typ |= CLOEXEC;
            return typ;
        }
    };

    pub fn bind(this: Socket, addr: Address) BindError!void {
        try posix.bind(this.sock, &addr.any, addr.getOsSockLen());
    }

    pub fn close(this: Socket) void {
        posix.close(this.sock);
    }

    pub fn open(family: Family, options: Options) SocketError!Socket {
        const typ = DGRAM | options.getPosixType();

        return .{
            .sock = try posix.socket(@intFromEnum(family), typ, UDP),
        };
    }

    pub fn recv(this: Socket, buf: []u8) RecvFromError!Packet {
        var addr: Address = undefined;
        var addr_len: posix.socklen_t = @sizeOf(Address);

        const len = try posix.recvfrom(this.sock, buf, 0, &addr.any, &addr_len);

        return .{
            .from = addr,
            .data = buf[0..len],
        };
    }

    pub fn send(this: Socket, addr: Address, msg: []const u8) SendToError!void {
        _ = try posix.sendto(this.sock, msg, 0, &addr.any, addr.getOsSockLen());
    }
};
