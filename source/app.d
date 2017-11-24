import std.stdio;
import std.string;

private auto input(int day)
in {
    assert(day > 0);
    assert(day <= 25);
}
out (result) {
    assert(&result !is null);
}
body {
    return File("inputs/day%d.txt".format(day));
}

void main() {
    static foreach (day; 1..26) {
        mixin(`import day%d;`
                .format(day));
        static foreach (part; 1..3) {
            mixin(`write("Day %d Part %d: ");`
                    .format(day, part));
            mixin(`writeln(day%d.part%d(input(%d).byLine(KeepTerminator.no,'%s')));`
                    .format(day,part,day,mixin(`day%d.separator`.format(day))));
        }
    }
}
