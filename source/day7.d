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
    immutable string name;
    immutable int weight;
    immutable string[] children;
}

alias ProgramRef = RefCounted!Program;

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
    return ProgramRef(Program(name.dup, weight, children.dup));
}

unittest {
    "foo (21) -> bar, baz".program.name.should.equal("foo");
    "foo (21) -> bar, baz".program.weight.should.equal(21);
    "foo (21) -> bar, baz".program.children.should.equal(["bar","baz"]);
    "ben (22)".program.name.should.equal("ben");
    "ben (22)".program.weight.should.equal(22);
    "ben (22)".program.children.length.should.equal(0);
}

auto part1(T)(T lines) {
    ProgramRef[string] programs;
    bool[string] children;
    lines
        .each!(delegate(const char[] line) {
            ProgramRef program = program(line);
            program.children
                .each!(delegate(const char[] child) {
                    children[child] = true;
                });
            programs[program.name] = program;
        });

    return programs
        .byKey()
        .filter!(name => name !in children)
        .front;
}

int total_weight(const ProgramRef program, const ref ProgramRef[string] programs) {
    return program.weight
        + program.children
            .map!(child => total_weight(programs[child], programs))
            .sum;
}

auto is_disc_unbalanced(ProgramRef program, const ref ProgramRef[string] programs) {
    if (program.children.length < 2) {
        return false;
    } else {
        auto first_weight = total_weight(programs[program.children[0]], programs);
        return program.children
                .map!(child_name => total_weight(programs[child_name], programs))
                .any!(child_weight => child_weight != first_weight);
    }
}

auto part2(T)(T lines) {
    ProgramRef[string] programs;
    lines
        .each!(delegate(const char[] line) {
            ProgramRef program = program(line);
            programs[program.name] = program;
        });

    auto unbalanced =
        programs
        .byKey()
        .filter!(name => is_disc_unbalanced(programs[name], programs))
        .filter!(name => programs[name].children
                            .all!(child_name => !is_disc_unbalanced(programs[child_name], programs)))
        .map!(name => programs[name])
        .take(1)
        .front;

    auto desired_stack_weight =
        unbalanced.children
        .map!(child_name => total_weight(programs[child_name], programs))
        .array
        .sort
        .group
        .filter!(freq => freq[1] > 1)
        .map!(freq => freq[0])
        .take(1)
        .front;

    auto node_to_fix =
        unbalanced.children
        .filter!(child_name => total_weight(programs[child_name], programs) != desired_stack_weight)
        .map!(child_name => programs[child_name])
        .take(1)
        .front;

    auto weight_of_nodes_children =
        node_to_fix.children
        .map!(child_name => total_weight(programs[child_name], programs))
        .sum;

    return desired_stack_weight - weight_of_nodes_children;
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
    
    immutable simple_example = [
        "root (10) -> a, b, c",
        "a (1)",
        "b (1)",
        "c (2)"
    ];

    simple_example.part2.should.equal(1);
    example.part2.should.equal(60);
}
