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

struct Direction {
    long x;
    long y;
};

struct Location {
    long x;
    long y;
    Direction dir;
};

alias Diagram = string[];

Diagram diagram(T)(T lines) {
    return lines.map!(to!string).array;
}

Location initial(const Diagram d) {
    auto x = d[0].indexOf('|');
    return Location(x, 0, Direction(0, 1));
}

char character(Location l, const Diagram d) {
    if (l.y < 0 || l.x < 0 || l.y >= d.length || l.x >= d[l.y].length) {
        return ' ';
    }
    return d[l.y][l.x];
}

Location next(Location l, const Diagram d) {
    if ('+' == l.character(d)) {
        auto a = Location(l.x + l.dir.y, l.y + l.dir.x, Direction(l.dir.y, l.dir.x));
        auto b = Location(l.x - l.dir.y, l.y - l.dir.x, Direction(0-l.dir.y, 0-l.dir.x));
        auto wanted_char = (l.dir.x == 0) ? '-' : '|';
        if (a.character(d) == wanted_char) {
            return a;
        } else if (b.character(d) == wanted_char) {
            return b;
        } else if (a.character(d).isAlpha) {
            return a;
        } else if (b.character(d).isAlpha) {
            return b;
        }
        enforce(false, "No suitable direction for turning");
    }

    return Location(
            l.x + l.dir.x,
            l.y + l.dir.y,
            l.dir);
}

auto explore(Diagram d) {
    Location l = d.initial;

    return
        generate!(() => l = l.next(d))
        .map!(l => l.character(d))
        .until!(x => x == ' ');
}

auto part1(T)(T lines) {
    return
        lines
        .diagram
        .explore
        .filter!isAlpha
        .array;
}

auto part2(T)(T lines) {
    return
        lines
        .diagram
        .explore
        .count + 1;
}

unittest {
    import fluent.asserts;

    immutable d = [
        `     |         `, 
        `     |  +--+   `, 
        `     A  |  C   `, 
        ` F---|----E|--+`, 
        `     |  |  |  D`,
        `     +B-+  +--+`
    ];

    d.initial.should.equal(Location(5,0,Direction(0,1)));
    d.initial.character(d).should.equal('|');
    d.initial.next(d).should.equal(Location(5,1,Direction(0,1)));
    d.initial.next(d).next(d).character(d).should.equal('A');
    Location(5,5,Direction(0,1)).next(d).should.equal(Location(6,5,Direction(1,0)));
    Location(8,5,Direction(1,0)).next(d).should.equal(Location(8,4,Direction(0,-1)));
    Location(8,1,Direction(0,-1)).next(d).should.equal(Location(9,1,Direction(1,0)));
    d.part1.should.equal("ABCDEF");
    d.part2.should.equal(38);
}
