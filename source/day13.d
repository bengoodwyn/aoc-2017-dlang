import std.algorithm;
import std.array;
import std.ascii;
import std.conv;
import std.exception;
import std.math;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

struct Scanner {
    int depth;
    int range;
}

auto scanner(const char[] line) {
    auto parts = line.split(":").map!strip.array;
    enforce(2 == parts.length, "Expected depth and range");
    return Scanner(parts[0].to!int, parts[1].to!int);
}

unittest {
    import fluent.asserts;

    "1: 2".scanner.should.equal(Scanner(1,2));
}

auto caught(Scanner scanner, int delay) {
    auto period = (scanner.range - 1) * 2;
    return (scanner.depth+delay) % period == 0;
}

unittest {
    import fluent.asserts;

    Scanner(0, 3).caught(0).should.equal(true);
    Scanner(1, 2).caught(0).should.equal(false);
    Scanner(4, 4).caught(0).should.equal(false);
    Scanner(6, 4).caught(0).should.equal(true);
}

auto severity(Scanner scanner) {
    return scanner.depth * scanner.range;
}

auto part1(T)(T lines) {
    return lines
            .map!scanner
            .filter!(x => x.caught(0))
            .map!severity
            .sum;
}

unittest {
    import fluent.asserts;

    ["0: 3","1: 2","4: 4","6: 4"].part1.should.equal(24);
}

auto part2(T)(T lines) {
    auto scanners = lines.map!scanner.array;
    return iota(0, int.max)
            .filter!(delay =>
                scanners
                .all!(scanner => !scanner.caught(delay)))
            .front;
}

unittest {
    import fluent.asserts;

    ["0: 3","1: 2","4: 4","6: 4"].part2.should.equal(10);
}
