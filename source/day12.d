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

alias Relationship = int[];

auto relationship(const char[] line) {
    return line
        .tr("<>,", "    ")
        .split
        .filter!(x => x != "-")
        .map!(to!int)
        .array
        .sort
        .array;
}

unittest {
    import fluent.asserts;

    "1 <-> 4, 3, 2".relationship.should.equal([1,2,3,4]);
}

Relationship relationship_merge(Relationship x, Relationship y) {
    return (x~y).sort.uniq.array;
}

unittest {
    import fluent.asserts;

    [1,7].relationship_merge([2,3]).should.equal([1,2,3,7]);
}

auto merge_relationships(T)(T lines) {
    Relationship[] relationships;

    auto merge = delegate(Relationship relationship) {
        auto merged = 
            relationships
            .filter!(x => x.cartesianProduct(relationship).any!(pair => pair[0] == pair[1]))
            .fold!((merged,x) => merged.relationship_merge(x))(relationship);
        relationships =
            merged
            ~relationships
            .filter!(x => x.cartesianProduct(relationship).all!(pair => pair[0] != pair[1]))
            .array
            .sort
            .uniq
            .array;
    };

    lines
        .map!relationship
        .each!merge;

    relationships = relationships.sort.array;

    return relationships;
}

unittest {
    import fluent.asserts;

    ["1 2", "2 3"].merge_relationships.should.equal([[1,2,3]]);
    ["1 2", "2 3", "3 4 5"].merge_relationships.should.equal([[1,2,3,4,5]]);
    ["1 2", "2 6", "3 4 5"].merge_relationships.should.equal([[1,2,6],[3,4,5]]);
    ["1 2 3", "4 5 6", "1 4"].merge_relationships.should.equal([[1,2,3,4,5,6]]);
}

auto part1(T)(T lines) {
    return merge_relationships(lines)
            .filter!(x => x.any!(y => y == 0))
            .map!count
            .front;
}

auto part2(T)(T lines) {
    return merge_relationships(lines)
            .count;
}
