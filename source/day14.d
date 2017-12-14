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

private import day10;

bool[] nibble_bits(char nibble) {
    final switch (nibble) {
        case '0': return [ false, false, false, false ];
        case '1': return [ false, false, false, true  ];
        case '2': return [ false, false, true,  false ];
        case '3': return [ false, false, true,  true  ];
        case '4': return [ false, true,  false, false ];
        case '5': return [ false, true,  false, true  ];
        case '6': return [ false, true,  true,  false ];
        case '7': return [ false, true,  true,  true  ];
        case '8': return [ true,  false, false, false ];
        case '9': return [ true,  false, false, true  ];
        case 'a': return [ true,  false, true,  false ];
        case 'b': return [ true,  false, true,  true  ];
        case 'c': return [ true,  true,  false, false ];
        case 'd': return [ true,  true,  false, true  ];
        case 'e': return [ true,  true,  true,  false ];
        case 'f': return [ true,  true,  true,  true  ];
    }
}

auto grid(const char[] input) {
    return
        iota(0,128)
        .map!(i => "%s-%d".format(input, i))
        .map!(hash_input => day10.part2([hash_input]))
        .map!(hash =>
            hash
            .map!(to!char)
            .map!(nibble => nibble.nibble_bits)
            .joiner
            .array)
        .array;
}

auto bit_count(bool[][] grid) {
    return
        grid
        .joiner
        .filter!(x => x)
        .count;
}

auto part1(T)(T lines) {
    auto input = lines.front;
    return
        grid(input)
        .bit_count;
}

auto first_bit(bool[][] grid) {
    return
        iota(0,grid.length)
        .filter!(i => grid[i].any!(j => j))
        .map!(i =>
            tuple(
                i,
                iota(0,grid[i].length)
                    .filter!(j => grid[i][j])
                    .front))
        .front;
}

void clear_neighbors(ref bool[][] grid, Tuple!(ulong,ulong) bit) {
    auto i = bit[0];
    auto j = bit[1];
    grid[i][j] = false;
    if (i > 0 && grid[i-1][j]) {
        grid.clear_neighbors(tuple(i-1,j));
    }
    if (i < (grid.length-1) && grid[i+1][j]) {
        grid.clear_neighbors(tuple(i+1,j));
    }
    if (j > 0 && grid[i][j-1]) {
        grid.clear_neighbors(tuple(i,j-1));
    }
    if (j < (grid[i].length-1) && grid[i][j+1]) {
        grid.clear_neighbors(tuple(i,j+1));
    }
}

auto part2(T)(T lines) {
    auto input = lines.front;
    auto remaining = grid(input);
    int count = 0;
    while (remaining.bit_count > 0) {
        auto first_bit = remaining.first_bit;
        remaining.clear_neighbors(first_bit);
        ++count;
    }
    return count;
}

