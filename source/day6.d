version(unittest) import fluent.asserts;
import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

char separator = '\t';

void redistribute(ref int[] banks) {
    auto max_index = banks.maxIndex;
    auto length = banks.length;
    auto index = (max_index+1)%length;
    auto blocks_to_distribute = banks[max_index];
    banks[max_index]=0;
    while (blocks_to_distribute > 0) {
        ++banks[index];
        index = (index+1)%length;
        --blocks_to_distribute;
    }
}

auto to_banks(T)(T lines) {
    return lines
            .map!strip
            .map!(to!int)
            .array;
}

auto redistribute_until_repeat(int[] banks) {
    int[string] known_banks;
    int count = 0;
    do {
        known_banks[banks.to!string] = count;
        redistribute(banks);
        ++count;
    } while (banks.to!string !in known_banks);

    return tuple(count, count - known_banks[banks.to!string]);
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
