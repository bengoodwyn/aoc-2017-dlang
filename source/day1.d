import std.algorithm;
import std.range;

auto inverse_captcha(const char[] digits, ulong offset) {
    return
        digits
            .zip(digits.cycle.drop(offset))
            .filter!(pair => pair[0] == pair[1])
            .map!(pair => pair[0] - '0')
            .sum;
}

auto part1(T)(T lines) {
    return
        lines
            .map!(digits => inverse_captcha(digits, 1))
            .sum;
}

unittest {
    assert(3 == part1(["1122"]),
           "1122 produces a sum of 3 (1 + 2) because the first digit (1) matches the second digit and the third digit (2) matches the fourth digit.");
    assert(4 == part1(["1111"]),
           "1111 produces 4 because each digit (all 1) matches the next.");
    assert(0 == part1(["1234"]),
           "1234 produces 0 because no digit matches the next.");
    assert(9 == part1(["91212129"]),
           "91212129 produces 9 because the only digit that matches the next one is the last digit, 9.");
}

auto part2(T)(T lines) {
    return
        lines
            .map!(digits => inverse_captcha(digits, digits.length/2))
            .sum;
}

unittest {
    assert(6 == part2(["1212"]),
           "1212 produces 6: the list contains 4 items, and all four digits match the digit 2 items ahead.");
    assert(0 == part2(["1221"]),
           "1221 produces 0, because every comparison is between a 1 and a 2.");
    assert(4 == part2(["123425"]),
           "123425 produces 4, because both 2s match each other, but no other digit has a match.");
    assert(12 == part2(["123123"]),
           "123123 produces 12.");
    assert(4 == part2(["12131415"]),
           "12131415 produces 4.");
}
