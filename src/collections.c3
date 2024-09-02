module collecter::collection;
import std::io::file;

struct CollectionBase {
        File header;
        String name;
}

interface Collection {
        fn void makeHeader();
        fn void makeMethods();
        fn void makeError();
        fn void end();
}
