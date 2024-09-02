module collecter::collection;
import std::io::file;

fault CollectionFault {
        UNABLE_TO_OPEN_FILE,
        END_OF_ARGS,
        FAULTED,
}

struct CollectionBase {
        File header;
        String name;
        String upperName;
}

interface Collection {
        fn void makeHeader();
        fn void makeMethods();
        fn void makeError();
        fn void end();

        fn void setName(String name);
}
