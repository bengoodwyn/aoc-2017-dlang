import std.algorithm;
import std.range;
import std.typecons;

auto inverse_captcha(const char[] digits) {
    return
        digits
            .zip(digits.cycle.drop(1))
            .filter!(pair => pair[0] == pair[1])
            .map!(pair => pair[0] - '0')
            .sum;
}

auto part1(T)(T lines) {
    return
        lines
            .map!inverse_captcha
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
