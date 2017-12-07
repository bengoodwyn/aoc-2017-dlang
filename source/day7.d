version(unittest) import fluent.asserts;
import std.algorithm;
import std.array;
import std.ascii;
import std.conv;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

struct Program {
    const char[] name;
    int weight;
    const char[][] children;
}

auto program(const char[] line) {
    const tokens = line.split;
    const name = tokens[0];
    const weight = tokens[1][1..$-1].to!int;
    const children = tokens.length > 2 ?
                            tokens[3..$]
                                .map!(token =>
                                    token
                                        .tr([','],[' '])
                                        .strip
                                        .dup)
                                .array :
                            [];
    return Program(name.dup, weight, children);
}

unittest {
    "foo (21) -> bar, baz".program.should.equal(Program("foo", 21, ["bar", "baz"]));
    "ben (22)".program.should.equal(Program("ben", 22, []));
}

auto part1(T)(T lines) {
    int[string] programs;
    bool[string] children;
    lines
        .map!program
        .each!(delegate(Program program) {
            programs[program.name] = program.weight;
            program.children
                .each!(delegate(const char[] child) {
                    children[child] = true;
                });
        });
    return programs
        .byKey()
        .filter!(program => program !in children)
        .front;
}

unittest {
    immutable example = [
        "pbga (66)",
        "xhth (57)",
        "ebii (61)",
        "havc (66)",
        "ktlj (57)",
        "fwft (72) -> ktlj, cntj, xhth",
        "qoyq (66)",
        "padx (45) -> pbga, havc, qoyq",
        "tknk (41) -> ugml, padx, fwft",
        "jptl (61)",
        "ugml (68) -> gyxo, ebii, jptl",
        "gyxo (61)",
        "cntj (57)"
    ];

    example.part1.should.equal("tknk");
}
