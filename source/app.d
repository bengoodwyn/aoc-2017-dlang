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
        {
            mixin(`import day_module = day%d;`.format(day));
            immutable separator = mixin(`'%s'`.format(day_module.separator));
            static foreach (part; 1..3) {
                {
                    immutable description = "Day %d Part %d: ".format(day, part);
                    auto lines = input(day).byLine(KeepTerminator.no, separator);
                    auto result = mixin(`day_module.part%d`.format(part))(lines);
                    writeln(description, result);
                }
            }
        }
    }
}
