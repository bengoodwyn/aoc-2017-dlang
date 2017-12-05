version(unittest) import fluent.asserts;
import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.string;

auto part1(T)(T lines) {
    auto jumps = lines.map!(to!int).array;
    int ip = 0;
    int count = 0;
    while (ip >= 0 && ip < jumps.length) {
        int new_ip = ip + jumps[ip];
        ++jumps[ip];
        ip = new_ip;
        ++count;
    }
    return count;
}

unittest {
    [0,3,0,1,-3].part1.should.equal(5);
}

auto part2(T)(T lines) {
    auto jumps = lines.map!(to!int).array;
    int ip = 0;
    int count = 0;
    while (ip >= 0 && ip < jumps.length) {
        int new_ip = ip + jumps[ip];
        if (jumps[ip] >= 3) {
            --jumps[ip];
        }
        else {
            ++jumps[ip];
        }
        ip = new_ip;
        ++count;
    }
    return count;
}

unittest {
    [0,3,0,1,-3].part2.should.equal(10);
}
