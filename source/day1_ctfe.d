import std.string;
import day1;

immutable input = [mixin(`"` ~ import("inputs/day1.txt") ~ `".strip`)];

immutable part1_result = part1(input);
pragma(msg, "CTFE Day 1 Part 1: ", part1_result);
static assert(1177 == part1_result);

immutable part2_result = part2(input);
pragma(msg, "CTFE Day 1 Part 2: ", part2_result);
static assert(1060 == part2_result);
