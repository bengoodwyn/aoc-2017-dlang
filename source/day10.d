version(unittest) import fluent.asserts;
import std.algorithm;
import std.array;
import std.ascii;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

int[] twist_hash(const int[] initial_nums, ref int current, ref int skip, const int[] lengths) {
    int[] nums = initial_nums.dup;

    foreach (length; lengths) {
        int start = current;
        int end = current + length - 1;
        while (end > start) {
            swap(nums[start%nums.length], nums[end%nums.length]);
            ++start;
            --end;
        }
        current = current + length + skip;
        ++skip;
    }
    return nums;
}

auto part1(T)(T lines) {
    int current = 0;
    int skip = 0;

    auto result = iota(0,256)
        .array
        .twist_hash(
            current,
            skip,
            lines.front.split(",")
            .map!strip
            .map!(to!int)
            .array)
        .take(2)
        .array;
    return result[0] * result[1];
}

unittest {
    immutable example = [3, 4, 1, 5];

    int current=0;
    int skip=0;
    auto result = iota(0,5).array.twist_hash(current, skip, example).take(2).array;
    (result[0] * result[1]).should.equal(12);
}

auto parse_input_bytes(const char[] input) {
    return input.strip.map!(x => x.to!int).array;
}

unittest {
    "1,2,3\n".parse_input_bytes.should.equal([49,44,50,44,51]);
}

immutable standard_suffix = [17, 31, 73, 47, 23];

auto final_lengths(const char[] input) {
    return input.parse_input_bytes ~ standard_suffix;
}

unittest {
    "1,2,3\n".final_lengths.should.equal([49,44,50,44,51,17,31,73,47,23]);
}

auto rounds(const char[] input) {
    immutable lengths = final_lengths(input);
    int current = 0;
    int skip = 0;
    auto nums = iota(0,256).array;
    iota(0,64)
        .each!(round => nums = nums.twist_hash(current, skip, lengths));
    return nums;
}

auto dense_hash(const int[] sparse_hash) {
    return iota(0,16)
        .map!(x => x*16)
        .map!(x => sparse_hash[x..x+16]
                    .fold!((xored,num) => xored ^ num)(0))
        .array;
}

auto hex_hash(const int[] dense_hash) {
    return dense_hash
        .map!(x => "%02x".format(x))
        .fold!((x,y) => x~y)("");
}

auto part2(T)(T lines) {
    auto sparse_hash = rounds(lines.front);
    return sparse_hash.dense_hash.hex_hash;
}

unittest {
    [""].part2.should.equal("a2582a3a0e66e6e86e3812dcb672a272");
    ["AoC 2017"].part2.should.equal("33efeb34ea91902bb2f59c9920caa6cd");
    ["1,2,3"].part2.should.equal("3efbe78a8d82f29979031a4aa0b16a9d");
    ["1,2,4"].part2.should.equal("63960835bcdc130f0b66d7ff4f6a5a8e");
}
