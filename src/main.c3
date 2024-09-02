module collecter;
import std;
import std::collections::list;
import collecter::string;

fn int! getNextCollection(String[] args, Collection *c) {
        if(args.len == 0) return CollectionFault.END_OF_ARGS?;
        String name = args[0];
        switch(name) {
                case "string":
                        *c = string::new();
        }
        return 1;
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
                        args = args[a .. args.len - 1];
                } else {
                        if(@catch(a) == CollectionFault.END_OF_ARGS) break LOOP;
                        lst.free();
                        io::eprintn("Error during argument parsing");
                        return;
                }
        }
        foreach(c : lst) {
                c.makeError();
                c.makeHeader();
                c.makeMethods();
                c.end();
        }
        lst.free();
}
