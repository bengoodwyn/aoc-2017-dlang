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

auto spinlock(int steps, int iterations) {
    auto current = 0;
    auto buffer = new int[iterations+1];
    auto len = 1;

    while (len <= iterations) {
        foreach (step; 0..steps) {
            current = buffer[current];
        }
        buffer[len] = buffer[current];
        buffer[current] = len;
        current = len;
        ++len;
    }

    return buffer;
}

auto part1(T)(T lines) {
    immutable steps = lines.map!(to!int).front;
    auto buffer = steps.spinlock(2017);

    return buffer[2017];
}

auto part2(T)(T lines) {
    immutable steps = lines.map!(to!int).front;
    auto buffer = steps.spinlock(50_000_000);

    return buffer[0];
}

unittest {
    import fluent.asserts;

    ["3"].part1.should.equal(638);
}

