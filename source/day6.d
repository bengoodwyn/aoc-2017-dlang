version(unittest) import fluent.asserts;
import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

char separator = '\t';

void redistribute(int[] banks) {
    const max_index = banks.maxIndex;
    const length = banks.length;
    const blocks_to_distribute = banks[max_index];

    banks[max_index]=0;
    iota(0,blocks_to_distribute)
        .map!(iteration => (max_index+iteration+1) % length)
        .each!(index => ++banks[index]);
}

auto to_banks(T)(T lines) {
    return lines
            .map!strip
            .map!(to!int)
            .array;
}

auto redistribute_until_repeat(int[] banks) {
    int[string] known_banks;

    const count =
        iota(0, int.max)
        .tee!(count => {
                known_banks[banks.to!string] = count;
                redistribute(banks);
            }())
        .filter!(count => banks.to!string in known_banks)
        .front;

    return tuple(
            count,
            count - known_banks[banks.to!string]);
}

auto part1(T)(T lines) {
    return lines
        .to_banks
        .redistribute_until_repeat[0];
}

unittest {
    ["0","2","7","0"].part1.should.equal(5);
}

auto part2(T)(T lines) {
    return lines
        .to_banks
        .redistribute_until_repeat[1];
}

unittest {
    ["0","2","7","0"].part2.should.equal(4);
}
