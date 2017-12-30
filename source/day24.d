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

struct Component {
    int inp;
    int outp;
}

Component swap(Component component) {
    return Component(component.outp, component.inp);
}

Component component(const char[] line) {
    const parts = line.split("/").map!(to!int).array;
    return Component(parts[0], parts[1]);
}

int strength(Component component) {
    return component.inp + component.outp;
}

int bridge(Component root, int min_length, const Component[] components) {
    int best = (min_length > 1) ? 0 : root.strength;
    foreach (i, component; components) {
        const others = components[0..i] ~ components[i+1..$];
        if (root.outp == component.inp) {
            auto current = component.bridge(min_length-1, others);
            if (current > 0) {
                best = max(best, current + root.strength);
            }
        } else if (root.outp == component.outp) {
            auto current = component.swap.bridge(min_length-1, others);
            if (current > 0) {
                best = max(best, current + root.strength);
            }
        }
    }
    return best;
}

int strongest(const Component[] components, int min_length) {
    int best = 0;
    foreach (i, root; components) {
        const others = components[0..i] ~ components[i+1..$];
        int a = (0 == root.inp) ? root.bridge(min_length, others) : 0;
        int b = (0 == root.outp) ? root.swap.bridge(min_length, others) : 0;
        best = max(best, a, b);
    }
    return best;
}

auto part1(T)(T lines) {
    auto components =
        lines
        .map!component
        .array;

    return components.strongest(0);
}

int bridge_length(Component root, const Component[] components) {
    int best = 1;
    foreach (i, component; components) {
        const others = components[0..i] ~ components[i+1..$];
        if (root.outp == component.inp) {
            auto current = 1 + component.bridge_length(others);
            best = max(best, current);
        } else if (root.outp == component.outp) {
            auto current = 1 + component.swap.bridge_length(others);
            best = max(best, current);
        }
    }
    return best;
}

int longest(const Component[] components) {
    int best = 0;
    foreach (i, root; components) {
        const others = components[0..i] ~ components[i+1..$];
        int a = (0 == root.inp) ? root.bridge_length(others) : 0;
        int b = (0 == root.outp) ? root.swap.bridge_length(others) : 0;
        best = max(best, a, b);
    }
    return best;
}

auto part2(T)(T lines) {
    auto components =
        lines
        .map!component
        .array;

    auto min_length = components.longest;

    return components.strongest(min_length);
}

unittest {
    import fluent.asserts;

    immutable example = [
        "0/2",
        "2/2",
        "2/3",
        "3/4",
        "3/5",
        "0/1",
        "10/1",
        "9/10"
    ];

    example.part1.should.equal(31);
    example.part2.should.equal(19);
}
