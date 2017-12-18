import std.algorithm;
import std.array;
import std.ascii;
import std.container;
import std.conv;
import std.exception;
import std.math;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

import assem;

auto part1(T)(T lines) {
    auto code =
        lines
        .collect_instructions;
    return code.execute[0][2];
}

auto part2(T)(T lines) {
    auto code =
        lines
        .map!(x => x.replace("snd","send"))
        .map!(x => x.replace("rcv","recv"))
        .collect_instructions;
    return code.execute[1][3];
}

unittest {
    import fluent.asserts;
}
