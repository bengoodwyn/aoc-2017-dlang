import std.algorithm;
import std.range;
import std.string;

immutable separator = "\\n";

auto part1(T)(T lines) {
    return lines
            .fold!((output, line) => output ~ line); 
}

unittest {
    assert("Nothing" == part1(["Not","hing"]), "Part1 works");
}

auto part2(T)(T lines) {
    return part1(lines);
}

unittest {
    assert("Nothing" == part1(["Not","hing"]), "Part2 works");
}

