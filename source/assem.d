import std.algorithm;
import std.ascii;
import std.conv;
import std.exception;
import std.functional;
import std.math;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

alias Registers = long[256];
alias Queue = long[];
alias Token = string;
alias Instruction = Token[];
alias Instructions = Instruction[];
alias Jit = bool delegate(ref Registers, ref Queue, ref Queue);

bool isRegister(const char[] str) {
    return str.length == 1 && str[0].isAlpha;
}

unittest {
    import fluent.asserts;

    "a".isRegister.should.equal(true);
    "aa".isRegister.should.equal(false);
    "1".isRegister.should.equal(false);
}

Jit jit_snd(Instruction instruction) {
    enforce(instruction.length == 2, "snd requires one argument");

    auto arg = instruction[1];
    if (arg.isRegister) {
        immutable source_register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[1] = registers[source_register];
            ++registers[0];
            return false;
        };
    } else {
        immutable source_immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[1] = source_immediate;
            ++registers[0];
            return false;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue qs;

    jit_snd(["snd","23"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);
    reg[1].should.equal(23);

    reg['a'] = 19;
    jit_snd(["snd","a"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(2);
    reg[1].should.equal(19);
}

Jit jit_rcv(Instruction instruction) {
    enforce(instruction.length == 2, "rcv requires one argument");

    auto arg = instruction[1];
    if (arg.isRegister) {
        immutable source_register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            if (0 != registers[source_register]) {
                registers[2] = registers[1];
                registers[0] = long.min;
            } else {
                ++registers[0];
            }
            return false;
        };
    } else {
        immutable source_immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            if (0 != source_immediate) {
                registers[2] = registers[1];
                registers[0] = long.min;
            } else {
                ++registers[0];
            }
            return false;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue qs;

    reg[1] = 999;

    jit_rcv(["rcv","0"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);
    reg[2].should.equal(0);

    jit_rcv(["rcv","a"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(2);
    reg[2].should.equal(0);

    reg['a'] = 1;
    jit_rcv(["rcv","a"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(long.min);
    reg[2].should.equal(999);

    reg[1] = 998;
    jit_rcv(["rcv","1"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(long.min);
    reg[2].should.equal(998);
}


Jit jit_add(Instruction instruction) {
    enforce(instruction.length == 3, "add requires two arguments");

    immutable target_register = instruction[1][0];
    auto arg = instruction[2];
    if (arg.isRegister) {
        immutable source_register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] += registers[source_register];
            ++registers[0];
            return false;
        };
    } else {
        immutable source_immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] += source_immediate;
            ++registers[0];
            return false;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue qs;

    reg['a'] = 1;
    jit_add(["add","a","5"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);
    reg['a'].should.equal(6);

    reg['b'] = 3;
    jit_add(["add","a","b"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(2);
    reg['a'].should.equal(9);
}

Jit jit_set(Instruction instruction) {
    enforce(instruction.length == 3, "set requires two arguments");

    immutable target_register = instruction[1][0];
    auto arg = instruction[2];
    if (arg.isRegister) {
        immutable source_register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] = registers[source_register];
            ++registers[0];
            return false;
        };
    } else {
        immutable source_immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] = source_immediate;
            ++registers[0];
            return false;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue qs;

    reg['a'] = 1;
    jit_set(["set","b","a"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);
    reg['b'].should.equal(1);

    jit_set(["set","b","9"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(2);
    reg['b'].should.equal(9);
}

Jit jit_mul(Instruction instruction) {
    enforce(instruction.length == 3, "mul requires two arguments");

    immutable target_register = instruction[1][0];
    auto arg = instruction[2];
    if (arg.isRegister) {
        immutable source_register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] *= registers[source_register];
            ++registers[0];
            return false;
        };
    } else {
        immutable source_immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] *= source_immediate;
            ++registers[0];
            return false;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue qs;

    reg['a'] = 2;
    jit_mul(["mul","a","5"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);
    reg['a'].should.equal(10);

    reg['b'] = 3;
    jit_mul(["mul","a","b"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(2);
    reg['a'].should.equal(30);
}

Jit jit_mod(Instruction instruction) {
    enforce(instruction.length == 3, "mod requires two arguments");

    immutable target_register = instruction[1][0];
    auto arg = instruction[2];
    if (arg.isRegister) {
        immutable source_register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] %= registers[source_register];
            ++registers[0];
            return false;
        };
    } else {
        immutable source_immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            registers[target_register] %= source_immediate;
            ++registers[0];
            return false;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue qs;

    reg['a'] = 7;
    jit_mod(["mod","a","4"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);
    reg['a'].should.equal(3);

    reg['b'] = 2;
    jit_mod(["mod","a","b"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(2);
    reg['a'].should.equal(1);
}

Jit jit_jgz(Instruction instruction) {
    enforce(instruction.length == 3, "add requires two arguments");

    immutable test_arg = instruction[1];
    bool delegate(const ref Registers) tester;
    if (test_arg.isRegister) {
        immutable test_register = test_arg[0];
        tester = delegate(const ref Registers registers) {
            return registers[test_register] > 0;
        };
    } else {
        immutable test_immediate = to!long(test_arg);
        tester = delegate(const ref Registers) {
            return test_immediate > 0;
        };
    }

    auto arg = instruction[2];
    if (arg.isRegister) {
        immutable jump_register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            if (tester(registers)) {
                registers[0] += registers[jump_register];
            } else {
                ++registers[0];
            }
            return false;
        };
    } else {
        immutable jump_immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            if (tester(registers)) {
                registers[0] += jump_immediate;
            } else {
                ++registers[0];
            }
            return false;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue qs;

    jit_jgz(["jgz","0","999"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);

    jit_jgz(["jgz","a","999"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(2);

    jit_jgz(["jgz","1","-1"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(1);

    reg['a'] = 1;
    jit_jgz(["jgz","a","10"])(reg,qs,qs).should.equal(false);
    reg[0].should.equal(11);
}

Jit jit_send(Instruction instruction) {
    enforce(instruction.length == 2, "snd requires one argument");

    auto arg = instruction[1];
    if (arg.isRegister) {
        immutable register = arg[0];
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            outq ~= registers[register];
            ++registers[0];
            ++registers[3];
            return true;
        };
    } else {
        immutable immediate = to!long(arg);
        return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
            outq ~= immediate;
            ++registers[0];
            ++registers[3];
            return true;
        };
    }
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue inq;
    Queue outq;

    jit_send(["send","42"])(reg,inq,outq).should.equal(true);
    reg[0].should.equal(1);
    outq.should.equal([42L]);

    reg['b']=99;
    jit_send(["send","b"])(reg,inq,outq).should.equal(true);
    reg[0].should.equal(2);
    outq.should.equal([42L,99L]);
}

Jit jit_recv(Instruction instruction) {
    enforce(instruction.length == 2, "recv requires one argument");

    auto arg = instruction[1];
    enforce(arg.isRegister, "recv arg must be a register");
    immutable register = arg[0];
    return delegate(ref Registers registers, ref Queue inq, ref Queue outq) {
        if (inq.length > 0) {
            registers[register] = inq[0];
            inq = inq[1..$];
            ++registers[0];
        }
        return true;
    };
}

unittest {
    import fluent.asserts;

    Registers reg;
    Queue inq;
    Queue outq;

    jit_recv(["recv","a"])(reg,inq,outq).should.equal(true);
    reg[0].should.equal(0);

    inq ~= 67;
    jit_recv(["recv","a"])(reg,inq,outq).should.equal(true);
    reg[0].should.equal(1);
    reg['a'].should.equal(67);
}

template DispatchOpcode(string token) {
    const char[] DispatchOpcode =
        `if (opcode == "%s") { return jit_%s(instruction); }`
            .format(token, token);
}

Jit jit_instruction(Instruction instruction) {
    enforce(instruction.length > 0, "Missing opcode");

    auto opcode = instruction[0];

    mixin(DispatchOpcode!("add"));
    mixin(DispatchOpcode!("mul"));
    mixin(DispatchOpcode!("mod"));
    mixin(DispatchOpcode!("set"));
    mixin(DispatchOpcode!("snd"));
    mixin(DispatchOpcode!("rcv"));
    mixin(DispatchOpcode!("send"));
    mixin(DispatchOpcode!("recv"));
    mixin(DispatchOpcode!("jgz"));

    throw new Exception("Unknown opcode '%s'".format(opcode));
}

Instructions collect_instructions(T)(T commands)
{
    Instructions seed;
    string[] tokens;
    return commands
        .fold!((instructions, line) =>
            instructions ~
                (line
                .split
                .fold!((a,b)=>a~b.dup)(tokens))
            )(seed);
}

Jit[] jit_compile(Instructions code) {
    Jit[] seed;
    return code
            .map!((instruction) => jit_instruction(instruction))
            .fold!((jits, jit) => (jits ~ jit))(seed);
}

auto deadlocked(const ref Registers[2] registers, const ref Queue[2] queues, const ref Instructions code) {
    return queues[0].length == 0
            && queues[1].length == 0
            && code[registers[0][0]][0] == "recv"
            && code[registers[1][0]][0] == "recv";
}

Registers[2] execute(Instructions code) {
    long active = 0;
    long idle = 1;
    Registers[2] registers;
    registers[1]['p'] = 1;
    Queue[2] queues;
    auto jits = code.jit_compile;
    auto running_programs = 1;
    auto forked = false;
    while (running_programs > 0
            && !deadlocked(registers, queues, code)) {
        auto ip = registers[active][0];
        if (ip >= 0 && ip < code.length) {
            auto yielded = jits[ip](registers[active], queues[active], queues[idle]);
            if (yielded) {
                swap(active, idle);
                if (!forked) {
                    ++running_programs;
                    forked = true;
                }
            }
            ip = registers[active][0];
            if (ip < 0 || ip >= code.length) {
                --running_programs;
            }
        } else {
            swap(active, idle);
        }
    }
    return registers;
}

unittest {
    import fluent.asserts;

    immutable example = [
        "set a 1",
        "add a 2",
        "mul a a",
        "mod a 5",
        "snd a",
        "set a 0",
        "rcv a",
        "jgz a -1",
        "set a 1",
        "jgz a -2"
    ];

    auto registers = example.collect_instructions.execute;
    registers[0][2].should.equal(4);
}

unittest {
    import fluent.asserts;

    immutable example = [
        "send 1",
        "send 2",
        "send p",
        "recv a",
        "recv b",
        "recv c",
        "recv d"
    ];

    auto registers = example.collect_instructions.execute;

    registers[0][3].should.equal(3);
    registers[1][3].should.equal(3);
}
