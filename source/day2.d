import std.algorithm;
import std.conv;
import std.range;
import std.string;

immutable ints =
    ((const char[] line) =>
        line
            .split
            .map!(x => to!int(x)));

auto part1(T)(T lines) {
    return lines
        .map!ints
        .map!(row => row.fold!max - row.fold!min)
        .sum;
}

unittest {
    immutable example = [
        "5 1 9 5",
        "7 5 3",
        "2 4 6 8"
    ];
    assert(18 == part1(example),
           "In this example, the spreadsheet's checksum would be 8 + 4 + 6 = 18.");
}

auto part2(T)(T lines) {
    return lines
        .map!ints
        .map!(row =>
                cartesianProduct(row, row)
                .filter!(pair => pair[1] > pair[0])
                .filter!(pair => 0 == (pair[1] % pair[0]))
                .front)
        .map!(x => x[1] / x[0])
        .sum;
}

unittest {
    immutable example = [
        "5 9 2 8",
        "9 4 7 3",
        "3 8 6 5"
    ];
    assert(9 == part2(example),
           "In this example, the sum of the results would be 4 + 3 + 2 = 9.");
}
