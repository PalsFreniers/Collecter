module collecter;
import std::io;
import std::collections::list;
import collecter::string;
import std::ascii;
import std::math;

fn bool isValidStructName(String name) {
        if(name.len == 0) return false;
        if(!(name[0] == '_' || name[0].is_alpha())) return false;
        String tmp = name[1 .. name.len - 1];
        foreach(c : tmp) {
                if(!(c.is_alnum() || c == '_')) return false;
        }
        return true;
}

fn int! getNextCollection(String[] args, Collection *c) {
        if(args.len == 0) return CollectionFault.END_OF_ARGS?;
        String name = args[0];
        int skip = 1;
        switch(name) {
                case "string":
                        *c = string::new();
        }
        if(args.len <= skip) return skip;
        String[] opt = args[skip .. args.len - 1];
        while(opt[0][0] == '-') {
                int next = 0;
                switch(opt[0]) {
                        case "-s": nextcase;
                        case "--structure":
                                if(opt.len <= 1) return CollectionFault.NOT_ENOUGH_ARGUMENT?;
                                if(!isValidStructName(opt[1])) return CollectionFault.BAD_STRUCTURE_NAME?;
                                c.setName(opt[1]);
                                next = 2;
                                skip += 2;
                        default:
                                return CollectionFault.UNKNOWN_OPTION?;
                }
                if(next >= opt.len) break;
                opt = opt[next .. opt.len - 1];
        }
        return skip;
}

def CollectionList = list::List(<Collection>);

fn void usage(String program) {
        io::printfn("Usage : %s <collection> (<type> ...) [OPTIONS] ...", program);
}

fn void main(String[] args) {
        String program = args[0];
        if(args.len < 2) return usage(program);
        args = args[1 .. args.len - 1];
        CollectionList lst;
        while LOOP: (true) {
                Collection c;
                int! a = getNextCollection(args, &c);
                if(try a) {
                        lst.push(c);
                        if(args.len - 1 < a) break LOOP;
                        io::printfn("Err : %d", a);
                        args = args[a .. args.len - 1];
                } else {
                        if(@catch(a) == CollectionFault.END_OF_ARGS) break LOOP;
                        lst.free();
                        io::eprintn("Error during argument parsing");
                        return;
                }
        }
        foreach(c : lst) {
                c.makeHeader();
                c.makeError();
                c.makeMethods();
                c.end();
                mem::free(c);
        }
        lst.free();
}
