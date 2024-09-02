module collecter_test @test;
import collecter;

fn void check_no_args() {
        Collection c;
        int! f = collecter::getNextCollection({}, &c);
        assert(!@ok(f), "empty arguments should fail");
        assert(@catch(f) == CollectionFault.NO_COLLECTION, "sould fail with NO_COLLECTION fault");
}

fn void check_one_argument() {
        Collection c;
        int! f = collecter::getNextCollection({"list"}, &c);
        assert(!@ok(f), "list collection without type should fail");
        assert(@catch(f) == collecter::CollectionFault.NOT_ENOUGH_ARGUMENT, "should fail with NOT_ENOUGH_ARGUMENT fault");
        int b = collecter::getNextCollection({"string"}, &c)!!;
        assert(b == 1, "should skip 1 argument");
        assert(c.type == CollectionType.STRING, "should have type STRING");
}

fn void check_two_arguments_no_opt() {
        Collection c;
        int f = collecter::getNextCollection({"list", "int"}, &c)!!;
        assert(c.type == CollectionType.LIST, "should have type LIST");
        assert(c.types[0] == "int", "should have type \"int\"");
        int! b = collecter::getNextCollection({"list", "type.test"}, &c);
        assert(!@ok(b), "bad c type should fail");
        assert(@catch(b) == CollectionFault.BAD_C_TYPE, "should fail with BAD_C_TYPE fault");
}
