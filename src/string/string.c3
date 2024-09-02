module collecter::string;
import collecter::collection;
import std::io::file;
import std::core::dstring;

distinct CollectionString(Collection) = CollectionBase;

fn CollectionString *new() {
        CollectionString *ret = mem::new(CollectionString);
        ret.name = "String".copy();
        ret.upperName = name.copy();
        foreach(&c : self.upperName) {
                if(c == ' ' || c == '.') {
                        c = '_';
                } else {
                        c = c.to_upper();
                }
        }
        return ret;
}

fn void CollectionString.makeHeader(&self) @dynamic {
        File f;
        @pool() {
                DString headerName = dstring::temp_new(self.name);
                headerName.append(".h");
                foreach(&c : headerName) {
                        c = c.to_lower();
                }
                f = file::open(headerName.str_view(), "w")!!;
        };
        self.header = f;
        self.header.printf("#ifndef %s_H\n", self.upperName);
        self.header.printf("#define %s_H\n", self.upperName);
        self.header.printf("\n");
        self.header.printf("#include <stdint.h>\n");
        self.header.printf("#include <stdbool.h>\n");
        self.header.printf("\n");
        self.header.printf("#define %s_zero() (struct %s){0}\n", self.name, self.name);
        self.header.printf("#define %s_len(s) (s).len\n", self.name);
        self.header.printf("#define %s_lenP(s) (s)->len\n", self.name);
        self.header.printf("\n");
        self.header.printf("struct %s {\n", self.name);
        self.header.printf("        uint64_t len;\n");
        self.header.printf("        uint64_t capacity;\n");
        self.header.printf("        char *ptr;\n");
        self.header.printf("        bool owned;\n");
        self.header.printf("};\n");
        self.header.printf("typedef struct %s %s;", self.name, self.name);
        self.header.printf("\n");
        self.header.printf("struct %sIterator {\n");
        self.header.printf("        struct %s *ref;\n", self.name);
        self.header.printf("        uint64_t idx;\n");
        self.header.printf("};\n");
        self.header.printf("typedef struct %sIterator %sIterator;", self.name, self.name);
        self.header.printf("\n");
}

fn void CollectionString.makeError(&self) @dynamic {
        self.header.printf("enum %sError {\n", self.name);
        self.header.printf("};\n");
        self.header.printf("typedef enum %sError %sError;\n", self.name, self.name);
        self.header.printf("extern enum %sError _%sError;\n", self.name, self.name);
        self.header.printf("\n");
        self.header.printf("char *%sError_toCstr();\n", self.name);
        self.header.printf("\n");
}

fn void CollectionString.makeMethods(&self) @dynamic {
        self.makeConstructors();
}


fn void CollectionString.end(&self) @dynamic {
        self.header.printf("#endif // %s_H", self.upperName);
        self.header.close();
        self.name.free();
        self.upperName.free();
}

fn void CollectionString.setName(&self, String name) @dynamic {
        self.name.free();
        self.upperName.free();
        self.name = name.copy();
        ret.upperName = name.copy();
        foreach(&c : self.upperName) {
                if(c == ' ' || c == '.') {
                        c = '_';
                } else {
                        c = c.to_upper();
                }
        }
}

fn void CollectionString.makeConstructorProto(self, String constructor) {
        self.header.printf("struct %s %s_%s;\n", self.name, self.name, constructor);
}

fn void CollectionString.makeConstructorDef(self, File f, String constructor) {
        f.printf("struct %s %s_%s {\n", self.name, self.name, constructor);
}

fn void CollectionString.makeConstructors(self) {
        self.makeConstructorProto("newFromCstr(char *ptr)");
        self.makeConstructorProto("new(char *ptr, uint64_t len)");
        self.makeConstructorProto("newUnownedFromCstr(char *ptr)");
        self.makeConstructorProto("newWithCapacity(uint64_t capacity)");
        self.makeConstructorProto("newUnowned(char *ptr, uint64_t len)");
        self.header.printf("\n");

        File f;
        @pool() {
                DString file = dstring::temp_new(self.name);
                foreach(&c : headerName) {
                        c = c.to_lower();
                }
                headerName.append("_constructors.c");
                f = file::open(headerName.str_view(), "w")!!;
                headerName.free();
                String tmp = self.name.tcopy();
                foreach(&c : tmp) c = c.to_lower();
                f.printf("#include \"%s.h\"", tmp);
        };
        f.printf("#include <stdlib.h>\n");
        f.printf("#include <string.h>\n");
        self.makeConstructorDef(f, "newFromCstr(char *ptr)");
        f.printf("        return (struct %s) {\n");
        f.printf("                .len = strlen(ptr),\n");
        f.printf("                .capacity = strlen(ptr) + 1,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "new(char *ptr, uint64_t len)");
        f.printf("        return (struct %s) {\n");
        f.printf("                .len = len,\n");
        f.printf("                .capacity = len,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "newUnownedFromCstr(char *ptr)");
        f.printf("        return (struct %s) {\n");
        f.printf("                .len = strlen(ptr),\n");
        f.printf("                .capacity = strlen(ptr) + 1,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "newWithCapacity(uint64_t capacity)");
        f.printf("        char *ptr = malloc(capacity * sizeof(char));\n");
        f.printf("        return (struct %s) {\n");
        f.printf("                .len = 0,\n");
        f.printf("                .capacity = capacity,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "newUnowned(char *ptr, uint64_t len)");
        f.printf("        return (struct %s) {\n");
        f.printf("                .len = len,\n");
        f.printf("                .capacity = len,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = false,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        f.close();
}
