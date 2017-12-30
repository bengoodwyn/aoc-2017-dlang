import assem;
import std.range;
import std.stdio;
import std.string;

auto part1(T)(T lines) {
    auto code =
        lines
        .collect_instructions;
    return code.execute[0][4];
}


auto part2_v1(T)(T lines) {
    auto code =
        ["set a 1"]
        .collect_instructions
        ~
        lines
        .collect_instructions;
    return code.execute[0]['h'];
}

auto part2_v2(T)(T lines) {
    int b,c,d,e,f,g,h;
    b=93;                   //set b 93
    c=b;                    //set c b
                            //jnz a 2
                            //jnz 1 5
    b*=100;                 //mul b 100
    b+=100000;              //sub b -100000
    c=b;                    //set c b
    c+=17000;               //sub c -17000
    do {
        f=1;                    //set f 1
        d=2;                    //set d 2
        
        do {
            e=2;                    //set e 2
            do {
                g=d;                    //set g d
                g*=e;                   //mul g e
                g-=b;                   //sub g b
                if (0 == g) {           //jnz g 2
                    f=0;                //set f 0
                }
                ++e;                    //sub e -1
                g=e;                    //set g e
                g-=b;                   //sub g b
            } while (0 != g);       //jnz g -8
            ++d;                    //sub d -1
            g=d;                    //set g d
            g-=b;                   //sub g b
        } while (0 != g);       //jnz g -13

        if (0 == f) {           //jnz f 2
            ++h;                    //sub h -1
        }

        g=b;                    //set g b
        g-=c;                   //sub g c

        if (0 == g) {           //jnz g 2
            return h;               //jnz 1 3
        }

        b+=17;                  //sub b -17
    } while (true);           //jnz 1 -23
}

auto part2_v3(T)(T lines) {
    int d,e,g,composites;
    immutable start_value = 93 * 100 + 100000;
    immutable term_value = start_value + 17000;
    foreach (b; iota(start_value, term_value+1, 17)) {
        auto is_prime=true;
        d=2;
        do {
            e=2;
            do {
                g=d;
                g*=e;
                g-=b;
                if (0 == g) {
                    is_prime=false;
                }
                ++e;
                g=e;
                g-=b;
            } while (0 != g);
            ++d;
            g=d;
            g-=b;
        } while (0 != g);

        if (!is_prime) {
            ++composites;
        }
    }
    return composites;
}

auto is_prime(int x) {
    foreach (y; iota(2, x/2)) {
        if (0 == x % y) {
            return false;
        }
    }
    return true;
}

auto part2_v4(T)(T lines) {
    int composites = 0;
    immutable start_value = 93 * 100 + 100000;
    immutable term_value = start_value + 17000;
    foreach (x; iota(start_value, term_value+1, 17)) {
        if (!x.is_prime) {
            ++composites;
        }
    }
    return composites;
}

alias part2 = part2_v4;
