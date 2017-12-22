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

alias Vec = int[3];

struct Particle {
    int id;
    Vec p;
    Vec v;
    Vec a;
};

auto particle(const char[] line, int id) {
    auto nums =
        line
        .tr("pva=<>,","       ")
        .split
        .map!(to!int)
        .array;
    enforce(9 == nums.length, "Expecting 9 numbers");
    return Particle(id, nums[0..3], nums[3..6], nums[6..9]);
}

unittest {
    import fluent.asserts;

    "p=<1,2,3>, v=< 4,5,6>, a=<-123,-456, -789>".particle(10).should.equal(Particle(10, [1,2,3],[4,5,6],[-123,-456,-789]));
}

auto distance_score(Particle x) {
    return x.a[].map!abs.sum;
}

auto closest_to_origin(T)(T particles) {
    return
        particles
        .array
        .sort!(((a,b) => distance_score(a) < distance_score(b)), SwapStrategy.stable)
        .front;
}

auto part1(T)(T lines) {
    return
        lines
        .enumerate
        .map!(x => x.value.particle(x.index.to!int))
        .closest_to_origin;
}

auto next(Particle particle) {
    particle.v = zip(particle.v[], particle.a[]).map!(pair => pair[0] + pair[1]).array;
    particle.p = zip(particle.p[], particle.v[]).map!(pair => pair[0] + pair[1]).array;
    return particle;
}

unittest {
    import fluent.asserts;

    "p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>".particle(0).next.should.equal("p=< 4,0,0>, v=< 1,0,0>, a=<-1,0,0>".particle(0));
    "p=< 4,0,0>, v=< 1,0,0>, a=<-1,0,0>".particle(0).next.should.equal("p=< 4,0,0>, v=< 0,0,0>, a=<-1,0,0>".particle(0));
    "p=< 4,0,0>, v=< 0,0,0>, a=<-1,0,0>".particle(0).next.should.equal("p=< 3,0,0>, v=<-1,0,0>, a=<-1,0,0>".particle(0));
    "p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>".particle(1).next.should.equal("p=< 2,0,0>, v=<-2,0,0>, a=<-2,0,0>".particle(1));
    "p=< 2,0,0>, v=<-2,0,0>, a=<-2,0,0>".particle(1).next.should.equal("p=<-2,0,0>, v=<-4,0,0>, a=<-2,0,0>".particle(1));
    "p=<-2,0,0>, v=<-4,0,0>, a=<-2,0,0>".particle(1).next.should.equal("p=<-8,0,0>, v=<-6,0,0>, a=<-2,0,0>".particle(1));
}

auto part2(T)(T lines) {
    Particle[] particles = lines.map!(x => x.particle(0)).array;
    auto prev = particles.length;
    auto iterations = 0;

    while (particles.length > 0 && iterations < 1000) {
        int[Vec] hits;
        particles.each!(particle =>
            hits[particle.p] = hits.get(particle.p, 0) + 1
        );
        particles =
            particles
            .filter!(particle => 1 == hits[particle.p])
            .map!(particle => particle.next)
            .array;
        if (prev > particles.length) {
            prev = particles.length;
        }
        ++iterations;
    }

    return particles.length;
}
