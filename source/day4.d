version(unittest) import fluent.asserts;
import std.algorithm;
import std.array;
import std.conv;
import std.string;

auto valid(T)(T words) {
    return words.length == words.sort.uniq.count;
}

auto part1(T)(T lines) {
    return lines
        .map!split
        .filter!valid
        .count;
}

unittest {
    ["aa bb cc dd ee"].part1.should.equal(1);
    ["aa bb cc dd aa"].part1.should.equal(0).because("the word aa appears more than once");
    ["aa bb cc dd aaa"].part1.should.equal(1).because("aa and aaa count as different words");
}


auto part2(T)(T lines) {
    string[] seed;
    return lines
        .map!split
        .map!(words =>
                words
                .map!(word =>
                    word
                    .array
                    .sort
                    .fold!((accum, letter) => accum ~ to!char(letter))(""))
                .array)
        .filter!valid
        .count;
}

unittest {
    ["abcde fghij"].part2.should.equal(1);
    ["abcde xyz ecdab"].part2.should.equal(0)
        .because("the letters from the third word can be rearranged to form the first word");
    ["a ab abc abd abf abj"].part2.should.equal(1)
        .because("all letters need to be used when forming another word");
    ["iiii oiii ooii oooi oooo"].part2.should.equal(1);
    ["oiii ioii iioi iiio"].part2.should.equal(0)
        .because("any of these words can be rearranged to form any other word");
}
