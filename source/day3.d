import fluent.asserts;
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
    with (Direction) {
        Right.next_desired_direction.should.equal(Up);
        Up.next_desired_direction.should.equal(Left);
        Left.next_desired_direction.should.equal(Down);
        Down.next_desired_direction.should.equal(Right);
    }
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
    with (Direction) {
        start.move(Up).should.equal(Coordinates(100, 101));
        start.move(Left).should.equal(Coordinates(99, 100));
        start.move(Down).should.equal(Coordinates(100, 99));
        start.move(Right).should.equal(Coordinates(101, 100));
        start.move(UpRight).should.equal(Coordinates(101, 101));
        start.move(UpLeft).should.equal(Coordinates(99, 101));
        start.move(DownLeft).should.equal(Coordinates(99, 99));
        start.move(DownRight).should.equal(Coordinates(101, 99));
    }
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
    zip(expected_coords, all_coordinates).count.should.equal(expected_coords.length)
        .because("make sure all_coordinates produces enough outputs to zip");
    zip(expected_coords, all_coordinates)
        .each!(pair => pair[1].should.equal(pair[0]));
}

auto distance(Coordinates coords) {
    return coords.x.abs + coords.y.abs;
}

unittest {
    Coordinates(1, 2).distance.should.equal(3);
    Coordinates(-2, 2).distance.should.equal(4);
    Coordinates(1, -3).distance.should.equal(4);
    Coordinates(-3, -2).distance.should.equal(5);
}


auto part1(T)(T lines) {
    int address = lines.map!(to!int).front;
    return all_coordinates.drop(address-1).front.distance;
}

unittest {
    [1].part1.should.equal(0);
    [2].part1.should.equal(1);
    [3].part1.should.equal(2);
    [4].part1.should.equal(1);
    [5].part1.should.equal(2);
    [6].part1.should.equal(1);
    [7].part1.should.equal(2);
    [8].part1.should.equal(1);
    [9].part1.should.equal(2);
    [10].part1.should.equal(3);
    [11].part1.should.equal(2);
    [12].part1.should.equal(3);
    [13].part1.should.equal(4);
    [14].part1.should.equal(3);
    [15].part1.should.equal(2);
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
    [747].part2.should.equal(806);
}
