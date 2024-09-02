module collecter;
import std;

fault CollectionFault {
        BAD_ARGUMENT,
        NO_COLLECTION,
        NOT_ENOUGH_ARGUMENT,
        UNKNOWN_COLLECTION,
        BAD_C_TYPE,
}

enum CollectionType {
        STRING,
        LIST,
}

struct Collection {
        CollectionType type;
        String[2] types;
}

fn bool isCorrectCType(String type) {
        foreach(c : type) {
                if(!ascii::is_alnum(c) && c != '_' && c != ' ') return false;
        }
        return true;
}

fn int! getNextCollection(String[] args, Collection *col) {
        if(args.len == 0) return CollectionFault.NO_COLLECTION?;
        int skip = 0;
        switch(args[0]) {
                case "string":
                        col.type = CollectionType.STRING;
                        skip = 1;
                        break;
                case "list":
                        if(args.len < 2) return CollectionFault.NOT_ENOUGH_ARGUMENT?;
                        col.type = CollectionType.LIST;
                        if(!isCorrectCType(args[1])) return CollectionFault.BAD_C_TYPE?;
                        col.types[0] = args[1];
                        break;
                default:
                        return CollectionFault.UNKNOWN_COLLECTION?;
        }
        return skip;
}

fn void usage(String program) {
        io::printfn("Usage : %s <collection> (<type> ...) [OPTIONS] ...", program);
}

fn void main(String[] args) {
        String program = args[0];
        if(args.len < 2) return usage(program);
        args = args[1 .. args.len - 1];
}
