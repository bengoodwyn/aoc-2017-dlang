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

immutable separator = ',';

string spin(const char[] programs, int distance) {
    return (programs[$-distance..$] ~ programs[0..$-distance]).to!string;
}

string swap_positions(const char[] programs, int pos0, int pos1) {
    auto swapped = programs.dup;
    swap(swapped[pos0], swapped[pos1]);
    return swapped.to!string;
}

string dance(const char[] programs, const char[] dance_move) {
    final switch (dance_move[0]) {
        case 's':
            immutable distance = dance_move[1..$].to!int;
            return programs.spin(distance);
        case 'x':
            immutable positions =
                dance_move[1..$]
                .split('/')
                .map!(to!int)
                .array;
            return programs.swap_positions(positions[0], positions[1]);
        case 'p':
            immutable positions =
                dance_move[1..$]
                .split('/')
                .map!(program => programs.indexOf(program))
                .map!(to!int)
                .array;
            return programs.swap_positions(positions[0], positions[1]);
    }
}

string dance(const char[] initial, const char[][] moves) {
    return
        moves
        .fold!((programs, dance_move) => programs.dance(dance_move))(initial)
        .to!string;
}

auto part1(T,size_t len=16)(T lines) {
    string initial =
        iota(0,len)
        .map!(i => 'a' + i)
        .map!(to!char)
        .array;
    const moves = lines.map!strip.map!dup.array;
 
    return dance(initial, moves);
}

auto part2(T,size_t len=16)(T lines) {
    string initial =
        iota(0,len)
        .map!(i => 'a' + i)
        .map!(to!char)
        .array;
    const moves = lines.map!strip.map!dup.array;

    auto cycle_length = 0;
    string programs = initial;
    string[] iterations;
    iterations ~= initial;
    do {
        programs = programs.dance(moves);
        iterations ~= programs;
        ++cycle_length;
    } while (programs != initial);

    return iterations[1_000_000_000 % cycle_length];
}

unittest {
    import fluent.asserts;

    "abcde".dance("s1").should.equal("eabcd");
    "eabcd".dance("x3/4").should.equal("eabdc");
    "eabdc".dance("pe/b").should.equal("baedc");

    immutable example = ["s1","x3/4","pe/b"];
    example.part1!(typeof(example),5).should.equal("baedc");
}

