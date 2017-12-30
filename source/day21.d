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

enum Pixel {
    On = '#',
    Off = '.'
}

alias Image = const char[][];

Image image(const char[] pattern) {
    return pattern.split('/').map!(to!string).array;
}

Image flip(Image image) {
    auto flipped = image.map!dup.array;
    flipped.each!reverse;
    return flipped;
}

Image rotate(Image image) {
    auto rotated = image.map!dup.array;
    foreach (x; 0..image.length) {
        foreach (y; 0..image.length) {
            rotated[y][x] = image[image.length-x-1][y];
        }
    }
    return rotated;
}


string pattern(Image image) {
    return image.join("/").to!string;
}

immutable Image initial = image(".#./..#/###");

auto threes(const char[] str) {
    assert(str.length % 3 == 0);
    return
        iota(0,str.length/3)
        .map!(x => str[x*3..x*3+3]);
}

auto threes(Image image) {
    return
        iota(0,image.length/3)
        .map!(x => zip(
                    image[3*x].threes,
                    image[3*x+1].threes,
                    image[3*x+2].threes))
        .joiner
        .map!(x => "%s/%s/%s".format(x[0],x[1],x[2]));
}

auto twos(const char[] str) {
    assert(str.length % 2 == 0);
    return
        iota(0,str.length/2)
        .map!(x => str[x*2..x*2+2]);
}

auto twos(Image image) {
    return
        iota(0,image.length/2)
        .map!(x => zip(
                    image[2*x].twos,
                    image[2*x+1].twos))
        .joiner
        .map!(x => "%s/%s".format(x[0],x[1]));
}

alias Rules = string[string];

auto compile(T)(T lines) {
    Rules rules;

    auto add_rule = delegate(const char[][] rule){
        const output = rule[2].to!string;
        string input = rule[0].to!string;
        foreach (x; 0..2) {
            foreach (y; 0..4) {
                rules[input] = output;
                input = input.image.rotate.pattern;
            }
            input = input.image.flip.pattern;
        }
    };

    lines
    .map!split
    .each!add_rule;

    return rules;
}

string join_pattern(const char[] a, const char[] b) {
    return zip(a.split("/"), b.split("/"))
            .map!(x => x[0] ~ x[1])
            .array
            .join("/")
            .to!string;
}

auto assemble(const char[][] patterns) {
    string[] image;
    int size = patterns.length.to!double.sqrt.to!int;
    foreach (y; 0..size) {
       string row = patterns[y*size].to!string;
       foreach (x; 1..size) {
           row = row.join_pattern(patterns[y*size+x]);
       }
       image ~= row.split("/");
    }
    return image;
}

auto fractal(Rules rules, int count, Image image) {
    if (0 == count) return image;

    if (image.length % 2 == 0) {
        Image transformed = image.twos.map!(x => rules[x]).array.assemble;
        return fractal(rules, count-1, transformed);
    } else {
        Image transformed = image.threes.map!(x => rules[x]).array.assemble;
        return fractal(rules, count-1, transformed);
    }
}

auto part1(T)(T lines) {
    auto rules = compile(lines);
    return
        fractal(rules, 5, initial)
        .map!(str => str.filter!(ch => ch == Pixel.On).count)
        .sum;
}

auto part2(T)(T lines) {
    auto rules = compile(lines);
    return
        fractal(rules, 18, initial)
        .map!(str => str.filter!(ch => ch == Pixel.On).count)
        .sum;
}

unittest {
    import fluent.asserts;

    immutable example = [
        "../.# => ##./#../...",
        ".#./..#/### => #..#/..../..../#..#"
    ];

    auto rules = compile(example);

    initial
    .threes
    .map!(x => rules[x])
    .array
    .should.equal(["#..#/..../..../#..#"]);

    "#..#/..../..../#..#"
    .image
    .twos
    .map!(x => rules[x])
    .array
    .should.equal(["##./#../...","##./#../...","##./#../...","##./#../..."]);

    fractal(rules, 2, initial)
    .map!(str => str.filter!(ch => ch == Pixel.On).count)
    .sum
    .should.equal(12);
}
