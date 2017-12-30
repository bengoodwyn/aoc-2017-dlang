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

struct Coordinates {
    int x;
    int y;
};

enum Direction {
    Up = 0,
    Left = 1,
    Down = 2,
    Right = 3,
}

Direction left(Direction dir) {
    return to!Direction((dir+1)%4);
}

Direction right(Direction dir) {
    return to!Direction((dir+3)%4);
}

Coordinates move(Coordinates from, Direction dir) {
    final switch (dir) with (Direction) {
        case Up:        return Coordinates(from.x,   from.y+1);
        case Left:      return Coordinates(from.x-1, from.y);
        case Down:      return Coordinates(from.x,   from.y-1);
        case Right:     return Coordinates(from.x+1, from.y);
    }
}

alias InfectedNodes = char[Coordinates];

auto part1(T)(T lines) {
    InfectedNodes infected;
    auto input = lines.map!dup.array;
    foreach (dy; 0..input.length.to!int) {
        foreach (x; 0..input[dy].length.to!int) {
            if ('#' == input[dy][x]) {
                auto pos = Coordinates(x,input.length.to!int-dy-1);
                infected[pos] = true;
            }
        }
    }
    auto pos = Coordinates((input[0].length/2).to!int, (input.length/2).to!int);
    auto dir = Direction.Up;
    int infections = 0;
    foreach (burst; 0..10000) {
        if (pos in infected) {
            dir = dir.right;
            infected.remove(pos);
        } else {
            dir = dir.left;
            infected[pos] = '#';
            ++infections;
        }
        pos = pos.move(dir);
    }
    return infections;
}

auto part2(T)(T lines) {
    InfectedNodes infected;
    auto input = lines.map!dup.array;
    foreach (dy; 0..input.length.to!int) {
        foreach (x; 0..input[dy].length.to!int) {
            if ('#' == input[dy][x]) {
                auto pos = Coordinates(x,input.length.to!int-dy-1);
                infected[pos] = '#';
            }
        }
    }
    auto pos = Coordinates((input[0].length/2).to!int, (input.length/2).to!int);
    auto dir = Direction.Up;
    int infections = 0;
    foreach (burst; 0..10000000) {
        auto state = infected.get(pos, '.');
        if (state == '#') {
            dir = dir.right;
            infected[pos] = 'F';
        } else if (state == 'W') {
            ++infections;
            infected[pos] = '#';
        } else if (state == 'F') {
            dir = dir.right.right;
            infected.remove(pos);
        } else {
            dir = dir.left;
            infected[pos] = 'W';
        }
        pos = pos.move(dir);
    }
    return infections;
}

unittest {
    import fluent.asserts;

    immutable example = [
        "..#",
        "#..",
        "..."
    ];

    example.part1.should.equal(5587);
    example.part2.should.equal(2511944);
}
