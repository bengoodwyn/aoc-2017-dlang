version(unittest) import fluent.asserts;
import std.algorithm;
import std.array;
import std.ascii;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

struct Instruction {
    string target_register;
    int multiple;
    int addend;
    string source_register;
    string operator;
    int value;
}

auto instruction(const char[] line) {
    auto tokens = line.split;
    enforce(tokens.length == 7, "There must be seven tokens");
    enforce(tokens[1] == "inc" || tokens[1] == "dec", "Only inc or dec supported");
    return Instruction(
            tokens[0].dup,
            tokens[1] == "inc" ? 1 : -1,
            tokens[2].to!int,
            tokens[4].dup,
            tokens[5].dup,
            tokens[6].to!int);
}

bool condition(Instruction instruction, const ref int[string] registers) {
    if (instruction.operator=="==") {
        return registers.get(instruction.source_register, 0) == instruction.value;
    } else if (instruction.operator=="<") {
        return registers.get(instruction.source_register, 0) < instruction.value;
    } else if (instruction.operator==">") {
        return registers.get(instruction.source_register, 0) > instruction.value;
    } else if (instruction.operator=="<=") {
        return registers.get(instruction.source_register, 0) <= instruction.value;
    } else if (instruction.operator==">=") {
        return registers.get(instruction.source_register, 0) >= instruction.value;
    } else if (instruction.operator=="!=") {
        return registers.get(instruction.source_register, 0) != instruction.value;
    } else {
        throw new Exception("Invalid operator " ~ instruction.operator);
    }
}

int execute(Instruction instruction, ref int[string] registers) {
    if (condition(instruction, registers)) {
        registers[instruction.target_register] =
            registers.get(instruction.target_register, 0)
            + instruction.multiple * instruction.addend;
    }
    return registers.get(instruction.target_register, 0);
}

auto part1(T)(T lines) {
    int[string] registers;

    lines
        .map!instruction
        .each!(instruction => instruction.execute(registers));

    return registers.byValue.maxElement;
}

auto part2(T)(T lines) {
    int[string] registers;

    return lines
        .map!instruction
        .map!(x => x.execute(registers))
        .cache
        .maxElement;
}

unittest {
    immutable example = [
        "b inc 5 if a > 1",
        "a inc 1 if b < 5",
        "c dec -10 if a >= 1",
        "c inc -20 if c == 10"
    ];

    example.part1.should.equal(1);
    example.part2.should.equal(10);
}
