version(unittest) import fluent.asserts;
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

struct Position {
    int x;
    int y;
}

auto move(Position pos, const char[] direction) {
    bool xodd = (pos.x.abs % 2) == 1;
    if (direction == "n") {
        return Position(pos.x, pos.y+1);
    } else if (direction == "s") {
        return Position(pos.x, pos.y-1);
    } else if (xodd) {
        if (direction == "ne") {
            return Position(pos.x+1, pos.y+1);
        } else if (direction == "se") {
            return Position(pos.x+1, pos.y);
        } else if (direction == "nw") {
            return Position(pos.x-1, pos.y+1);
        } else if (direction == "sw") {
            return Position(pos.x-1, pos.y);
        }
    } else {
        if (direction == "ne") {
            return Position(pos.x+1, pos.y);
        } else if (direction == "se") {
            return Position(pos.x+1, pos.y-1);
        } else if (direction == "nw") {
            return Position(pos.x-1, pos.y);
        } else if (direction == "sw") {
            return Position(pos.x-1, pos.y-1);
        }
    }
    throw new Exception("Bad direction '%s'".format(direction));
}

auto distance_from_home(Position pos) {
    int count = 0;
    while (pos != Position(0,0)) {
        string direction;
        if (pos.x > 0) {
            if (pos.y >= 0) {
                direction = "sw";
            } else {
                direction = "nw";
            }
        } else if (pos.x < 0) {
            if (pos.y > 0) {
                direction = "se";
            } else {
                direction = "ne";
            }
        } else if (pos.y > 0) {
            direction = "s";
        } else {
            direction = "n";
        }
        pos = pos.move(direction);
        ++count;
    }
    return count;
}

auto part1(T)(T lines) {
    Position pos = lines
        .map!strip
        .fold!((pos, direction) => pos.move(direction))(Position(0,0));
    return distance_from_home(pos);
}

unittest {
    ["ne","ne","ne"].part1.should.equal(3);
    ["ne","ne","sw","sw"].part1.should.equal(0);
    ["ne","ne","s","s"].part1.should.equal(2);
    ["se","sw","se","sw","sw"].part1.should.equal(3);
}

auto part2(T)(T lines) {
    return lines
        .map!strip
        .cumulativeFold!((pos, direction) => pos.move(direction))(Position(0,0))
        .map!distance_from_home
        .maxElement;
}
