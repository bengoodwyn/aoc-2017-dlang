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

enum Mode {
    SeekingStart,
    IgnoringOne,
    SeekingEnd
};

auto strip_garbage(const char[] stream) {
    char[] clean;
    Mode mode = Mode.SeekingStart;
    foreach (char x; stream) {
        final switch (mode) with (Mode) {
            case SeekingStart:
                if (x == '<') {
                    mode = SeekingEnd;
                } else {
                    clean ~= x;
                }
                break;
            case IgnoringOne:
                mode = SeekingEnd;
                break;
            case SeekingEnd:
                if (x == '>') {
                    mode = SeekingStart;
                } else if (x == '!') {
                    mode = IgnoringOne;
                }
                break;
        }
    }
    return clean;
}

unittest {
    "<>".strip_garbage.should.equal("").because("empty garbage");
    "<random characters>".strip_garbage.should.equal("").because("garbage containing random characters");
    "<<<<>".strip_garbage.should.equal("").because("the extra < are ignored");
    "<{!>}>".strip_garbage.should.equal("").because("the first > is canceled");
    "<!!>".strip_garbage.should.equal("").because("the second ! is canceled, allowing the > to terminate the garbage");
    "<!!!>>".strip_garbage.should.equal("").because("the second ! and the first > are canceled");
    "<{o\"i!a,<{i<a>".strip_garbage.should.equal("").because("ends at the first >");
}

auto strip_commas(const char[] stream) {
    return stream.filter!(x => x != ',').array;
}

unittest {
    ",a,b,c,".strip_commas.should.equal("abc");
}

auto score(const char[] stream) {
    int depth = 0;
    int sum = 0;
    foreach (char x; stream.strip_garbage.strip_commas) {
        if (x == '{') {
            ++depth;
            sum += depth;
        } else if (x == '}') {
            --depth;
        } else {
            throw new Exception("Unexpected '%c'".format(x));
        }
    }
    return sum;
}

unittest {
    "{}".score.should.equal(1);
    "{{{}}}".score.should.equal(6).because("1 + 2 + 3 = 6");
    "{{},{}}".score.should.equal(5).because("1 + 2 + 2 = 5");
    "{{{},{},{{}}}}".score.should.equal(16).because("1 + 2 + 3 + 3 + 3 + 4 = 16");
    "{<a>,<a>,<a>,<a>}".score.should.equal(1);
    "{{<ab>},{<ab>},{<ab>},{<ab>}}".score.should.equal(9).because("1 + 2 + 2 + 2 + 2 = 9");
    "{{<!!>},{<!!>},{<!!>},{<!!>}}".score.should.equal(9).because("1 + 2 + 2 + 2 + 2 = 9");
    "{{<a!>},{<a!>},{<a!>},{<ab>}}".score.should.equal(3).because("1 + 2 = 3");
}

auto part1(T)(T lines) {
    return lines.take(1).front.score;
}

auto count_garbage(const char[] stream) {
    int count = 0;
    Mode mode = Mode.SeekingStart;
    foreach (char x; stream) {
        final switch (mode) with (Mode) {
            case SeekingStart:
                if (x == '<') {
                    mode = SeekingEnd;
                }
                break;
            case IgnoringOne:
                mode = SeekingEnd;
                break;
            case SeekingEnd:
                if (x == '>') {
                    mode = SeekingStart;
                } else if (x == '!') {
                    mode = IgnoringOne;
                } else {
                    ++count;
                }
                break;
        }
    }
    return count;
}

unittest {
    "<>".count_garbage.should.equal(0);
    "<random characters>".count_garbage.should.equal(17);
    "<<<<>".count_garbage.should.equal(3);
    "<{!>}>".count_garbage.should.equal(2);
    "<!!>".count_garbage.should.equal(0);
    "<!!!>>".count_garbage.should.equal(0);
    "<{o\"i!a,<{i<a>".count_garbage.should.equal(10);
}

auto part2(T)(T lines) {
    return lines.take(1).front.count_garbage;
}

