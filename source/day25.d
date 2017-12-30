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

enum SIZE = 1024*1024*1024;

auto part1(T)(T lines) {
    bool[] tape = new bool[SIZE];
    int cursor = SIZE/2;
    char state = 'A';

    auto current_0 = delegate() {return !tape[cursor];};
    auto write_1 = delegate() {tape[cursor] = true;};
    auto write_0 = delegate() {tape[cursor] = false;};
    auto move_left = delegate() {cursor = (cursor+SIZE-1) % SIZE;};
    auto move_right = delegate() {cursor = (cursor+1) % SIZE;};
    auto set_state = delegate(char new_state) {state = new_state;};

    foreach (x; 0..12425180) {
        final switch (state) {
            case 'A':
                if (current_0()) {
                    write_1();
                    move_right();
                    set_state('B');
                } else {
                    write_0();
                    move_right();
                    set_state('F');
                }
                break;
            case 'B':
                if (current_0()) {
                    write_0();
                    move_left();
                    set_state('B');
                } else {
                    write_1();
                    move_left();
                    set_state('C');
                }
                break;
            case 'C':
                if (current_0()) {
                    write_1();
                    move_left();
                    set_state('D');
                } else {
                    write_0();
                    move_right();
                    set_state('C');
                }
                break;
            case 'D':
                if (current_0()) {
                    write_1();
                    move_left();
                    set_state('E');
                } else {
                    write_1();
                    move_right();
                    set_state('A');
                }
                break;
            case 'E':
                if (current_0()) {
                    write_1();
                    move_left();
                    set_state('F');
                } else {
                    write_0();
                    move_left();
                    set_state('D');
                }
                break;
            case 'F':
                if (current_0()) {
                    write_1();
                    move_right();
                    set_state('A');
                } else {
                    write_0();
                    move_left();
                    set_state('E');
                }
                break;
        }
    }

    return tape.filter!(x => x).count;
}

auto part2(T)(T lines) {
    return 0;
}
