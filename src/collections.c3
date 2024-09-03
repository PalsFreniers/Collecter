module collecter::collection;
import std::io::file;

fault CollectionFault {
        NOT_ENOUGH_ARGUMENT,
        UNABLE_TO_OPEN_FILE,
        BAD_STRUCTURE_NAME,
        UNKNOWN_OPTION,
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
