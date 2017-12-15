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

auto generator(ulong factor, ulong divisible_by = 1, ulong count = 40000000, ulong divisor = 2147483647)(ulong start) {
    static if (1 == divisible_by) {
        return iota(0, count)
            .cumulativeFold!((accumulator, i) =>
                accumulator * factor % divisor
            )(start);
    } else {
        return iota(0, ulong.max)
            .cumulativeFold!((accumulator, i) =>
                accumulator * factor % divisor
            )(start)
            .filter!(x => 0 == x%divisible_by)
            .take(count);
    }
}

auto dueling_generators(T)(T lines) {
    auto a_line = lines.front.dup;
    lines.popFront;
    auto b_line = lines.front;

    auto a_start = a_line.split.drop(4).map!(to!ulong).front;
    auto b_start = b_line.split.drop(4).map!(to!ulong).front;

    return generator!(16807)(a_start)
        .zip(generator!(48271)(b_start));
}

auto dueling_generators_v2(T)(T lines) {
    auto a_line = lines.front.dup;
    lines.popFront;
    auto b_line = lines.front;

    auto a_start = a_line.split.drop(4).map!(to!ulong).front;
    auto b_start = b_line.split.drop(4).map!(to!ulong).front;

    return generator!(16807,4,5000000)(a_start)
        .zip(generator!(48271,8,5000000)(b_start));
}

auto part1(T)(T lines) {
    return dueling_generators(lines)
        .map!(pair => tuple(pair[0]&0xffff, pair[1]&0xffff))
        .filter!(pair => pair[0] == pair[1])
        .count;
}

auto part2(T)(T lines) {
    return dueling_generators_v2(lines)
        .map!(pair => tuple(pair[0]&0xffff, pair[1]&0xffff))
        .filter!(pair => pair[0] == pair[1])
        .count;
}

unittest {
    import fluent.asserts;

    immutable a = [1092455UL,1181022009UL,245556042UL,1744312007UL,1352636452UL];
    generator!(16807, 1, 5)(65).array.should.equal(a);

    immutable b = [430625591UL,1233683848UL,1431495498UL,137874439UL,285222916UL];
    generator!(48271, 1, 5)(8921).array.should.equal(b);

    immutable a_v2 = [1352636452UL,1992081072UL,530830436UL,1980017072UL,740335192UL];
    generator!(16807, 4, 5)(65).array.should.equal(a_v2);

    immutable b_v2 = [1233683848UL,862516352UL,1159784568UL,1616057672UL,412269392UL];
    generator!(48271, 8, 5)(8921).array.should.equal(b_v2);

    immutable example = [
        "Generator A starts with 65",
        "Generator B starts with 8921"
    ];

    example.part1.should.equal(588);
    example.part2.should.equal(309);
}

