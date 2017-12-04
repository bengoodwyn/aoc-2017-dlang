import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.range;
import std.string;
import std.traits;

struct Coordinates {
    int x;
    int y;
};

alias Grid = int[Coordinates];

enum Direction {
    Up = 0,
    Left = 1,
    Down = 2,
    Right = 3,
    UpRight = 4,
    UpLeft = 5,
    DownLeft = 6,
    DownRight = 7
}

immutable Directions = [EnumMembers!Direction];

Direction next_desired_direction(Direction dir) {
    return to!Direction((dir+1)%4);
}

unittest {
    assert(Direction.Up    == next_desired_direction(Direction.Right), "Right -> Up");
    assert(Direction.Left  == next_desired_direction(Direction.Up),    "Up -> Left");
    assert(Direction.Down  == next_desired_direction(Direction.Left),  "Left -> Down");
    assert(Direction.Right == next_desired_direction(Direction.Down),  "Down -> Right");
}

Coordinates move(Coordinates from, Direction dir) {
    final switch (dir) with (Direction) {
        case Up:        return Coordinates(from.x,   from.y+1);
        case Left:      return Coordinates(from.x-1, from.y);
        case Down:      return Coordinates(from.x,   from.y-1);
        case Right:     return Coordinates(from.x+1, from.y);
        case UpRight:   return Coordinates(from.x+1, from.y+1);
        case UpLeft:    return Coordinates(from.x-1, from.y+1);
        case DownLeft:  return Coordinates(from.x-1, from.y-1);
        case DownRight: return Coordinates(from.x+1, from.y-1);
    }
}

unittest {
    immutable start = Coordinates(100,100);
    assert(Coordinates(100,101) == start.move(Direction.Up), "Up");
    assert(Coordinates( 99,100) == start.move(Direction.Left), "Left");
    assert(Coordinates(100, 99) == start.move(Direction.Down), "Down");
    assert(Coordinates(101,100) == start.move(Direction.Right), "Right");
    assert(Coordinates(101,101) == start.move(Direction.UpRight), "UpRight");
    assert(Coordinates( 99,101) == start.move(Direction.UpLeft), "UpLeft");
    assert(Coordinates( 99, 99) == start.move(Direction.DownLeft), "DownLeft");
    assert(Coordinates(101, 99) == start.move(Direction.DownRight), "DownRight");
}

auto all_coordinates() {
    Coordinates position = Coordinates(0,0);
    Direction direction = Direction.Down;
    Direction next_direction = next_desired_direction(direction);
    Grid visited;

    visited[position] = 1;

    Coordinates next_coordinates() {
        immutable desired_position = position.move(next_direction);
        if (desired_position !in visited) {
            position = desired_position;
            direction = next_direction;
            next_direction = next_desired_direction(direction);
        } else {
            position = position.move(direction);
        }
        visited[position] = 1;
        return position;
    }

    return [Coordinates(0,0)].chain(generate!next_coordinates);
}

unittest {
    immutable expected_coords =[
            Coordinates(0,0),
            Coordinates(1,0),
            Coordinates(1,1),
            Coordinates(0,1),
            Coordinates(-1,1),
            Coordinates(-1,0),
            Coordinates(-1,-1),
            Coordinates(0,-1),
            Coordinates(1,-1),
            Coordinates(2,-1),
            Coordinates(2,0),
            Coordinates(2,1),
            Coordinates(2,2),
            Coordinates(1,2),
            Coordinates(0,2),
            Coordinates(-1,2),
            Coordinates(-2,2),
            Coordinates(-2,1),
            Coordinates(-2,0),
            Coordinates(-2,-1),
            Coordinates(-2,-2),
            Coordinates(-1,-2),
            Coordinates(0,-2),
            Coordinates(1,-2),
            Coordinates(2,-2)
        ];
    assert(25 == zip(expected_coords, all_coordinates).count, "all_coordinates and expected_coords zip to 25 items");
    zip(expected_coords, all_coordinates)
        .each!(pair => assert(
                            pair[0] == pair[1],
                            "Expected:%s Actual:%s".format(pair[0], pair[1])));
}

auto distance(Coordinates coords) {
    return coords.x.abs + coords.y.abs;
}

unittest {
    assert(3 == Coordinates( 1, 2).distance, "Positive Positive");
    assert(4 == Coordinates(-2, 2).distance, "Negative Positive");
    assert(4 == Coordinates( 1,-3).distance, "Positive Negative");
    assert(5 == Coordinates(-3,-2).distance, "Negative Negative");
}


auto part1(T)(T lines) {
    int address = lines.map!(to!int).front;
    return all_coordinates.drop(address-1).front.distance;
}

unittest {
    assert(0 == part1([1]), "part1:1");
    assert(1 == part1([2]), "part1:2");
    assert(2 == part1([3]), "part1:3");
    assert(1 == part1([4]), "part1:4");
    assert(2 == part1([5]), "part1:5");
    assert(1 == part1([6]), "part1:6");
    assert(2 == part1([7]), "part1:7");
    assert(1 == part1([8]), "part1:8");
    assert(2 == part1([9]), "part1:9");
    assert(3 == part1([10]),"part1:10");
    assert(2 == part1([11]),"part1:11");
    assert(3 == part1([12]),"part1:12");
    assert(4 == part1([13]),"part1:13");
    assert(3 == part1([14]),"part1:14");
    assert(2 == part1([15]),"part1:15");
}

auto part2(T)(T lines) {
    immutable limit = lines.map!(to!int).front;

    Grid grid;
    return
        all_coordinates
        .map!(delegate(Coordinates base_coords) {
                int value =
                        Directions
                        .map!(direction => base_coords.move(direction))
                        .filter!(coords => coords in grid)
                        .map!(coords => grid[coords])
                        .sum;
                value = max(value, 1);
                grid[base_coords] = value;
                return value;
            })
        .filter!(value => value > limit)
        .front;
}

unittest {
    assert(806 == part2([747]), "part2:747");
}
