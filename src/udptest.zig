const std = @import("std");
const udp = @import("udp");
const fmt = std.fmt;
const mem = std.mem;
const net = std.net;

pub fn main() !void {
    const opts = try getopts();
    const family = udp.Socket.Family.fromAddress(opts.addr);
    const socket = try udp.Socket.open(family, .{});
    var buf: [2048]u8 = undefined;

    if (opts.listen) {
        try socket.bind(opts.addr);
        const datagram = try socket.recv(&buf);
        std.debug.print("from: {any}\n", .{datagram.from});
        std.debug.print("message: {s}\n", .{datagram.data});
    } else {
        try socket.send(opts.addr, "foo\n");
    }
}

const Options = struct {
    listen: bool = false,
    addr: net.Address,
};

fn getopts() !Options {
    const argv = std.os.argv;
    const addr = try net.Address.parseIp("::1", 55555);

    var opts: Options = .{ .addr = addr };

    for (argv[1..]) |curr| {
        const arg = mem.span(curr);

        if (mem.eql(u8, arg, "-l") or mem.eql(u8, arg, "--listen")) {
            opts.listen = true;
        } else {
            if (fmt.parseInt(u16, arg, 10)) |port| {
                opts.addr.setPort(port);
            } else |_| {
                const port = opts.addr.getPort();
                opts.addr = try net.Address.parseIp(arg, port);
            }
        }
    }

    return opts;
}
