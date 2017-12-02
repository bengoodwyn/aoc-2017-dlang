import std.string;
import day2;

immutable input = mixin(`"` ~ import("inputs/day2.txt") ~ `"`).splitLines;

immutable part1_result = part1(input);
pragma(msg, "CTFE Day 2 Part 1: ", part1_result);
static assert(48357 == part1_result);

immutable part2_result = part2(input);
pragma(msg, "CTFE Day 2 Part 2: ", part2_result);
static assert(351 == part2_result);
