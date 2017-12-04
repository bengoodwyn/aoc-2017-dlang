version(unittest) import fluent.asserts;
import std.algorithm;
import std.range;

immutable inverse_captcha = (const char[] digits, ulong offset) =>
    digits
        .zip(digits.cycle.drop(offset))
        .filter!(pair => pair[0] == pair[1])
        .map!(pair => pair[0] - '0')
        .sum;

auto part1(T)(T lines) {
    return
        lines
            .map!(digits => inverse_captcha(digits, 1))
            .sum;
}

unittest {
    ["1122"].part1.should.equal(3)
        .because("1122 produces a sum of 3 (1 + 2) because the first digit (1) matches the second digit and the third digit (2) matches the fourth digit.");
    ["1111"].part1.should.equal(4)
        .because("1111 produces 4 because each digit (all 1) matches the next.");
    ["1234"].part1.should.equal(0)
        .because("1234 produces 0 because no digit matches the next.");
    ["91212129"].part1.should.equal(9)
        .because("91212129 produces 9 because the only digit that matches the next one is the last digit, 9.");
}

auto part2(T)(T lines) {
    return
        lines
            .map!(digits => inverse_captcha(digits, digits.length/2))
            .sum;
}

unittest {
    ["1212"].part2.should.equal(6)
        .because("1212 produces 6: the list contains 4 items, and all four digits match the digit 2 items ahead.");
    ["1221"].part2.should.equal(0)
        .because("1221 produces 0, because every comparison is between a 1 and a 2.");
    ["123425"].part2.should.equal(4)
        .because("123425 produces 4, because both 2s match each other, but no other digit has a match.");
    ["123123"].part2.should.equal(12)
        .because("123123 produces 12.");
    ["12131415"].part2.should.equal(4)
        .because("12131415 produces 4.");
}
