import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.string;

immutable spreadsheet_row =
    ((const char[] line) =>
        line
            .split
            .map!(x => to!int(x))
            .array
            .sort
            .array);

auto part1(T)(T lines) {
    return lines
        .map!spreadsheet_row
        .map!(row => row[$-1] - row[0])
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

immutable pairs =
    ((const int[] row) =>
        iota(0,row.length)
        .map!(first => row[first..$])
        .map!(slice => slice[0].repeat.zip(slice[1..$]))
        .joiner);

auto part2(T)(T lines) {
    return lines
        .map!spreadsheet_row
        .map!(row =>
                row
                .pairs
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
