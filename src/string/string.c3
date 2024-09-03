module collecter::string;
import collecter::collection;
import std::io::file;
import std::core::dstring;
import std::ascii;

distinct CollectionString(Collection) = CollectionBase;

fn CollectionString *new() {
        CollectionString *ret = mem::new(CollectionString);
        ret.name = "String".copy();
        ret.upperName = ret.name.copy();
        ret.upperName.convert_ascii_to_upper();
        return ret;
}

fn File CollectionString.createNew(self, String append) {
        File f;
        @pool() {
                String headerName = self.name.tconcat(append).temp_ascii_to_lower();
                f = file::open(headerName, "w")!!;
        };
        return f;
}

fn void CollectionString.makeHeader(&self) @dynamic {
        File f = self.createNew(".h");
        self.header = f;
        self.header.printf("#ifndef %s_H\n", self.upperName);
        self.header.printf("#define %s_H\n", self.upperName);
        self.header.printf("\n");
        self.header.printf("#include <stdint.h>\n");
        self.header.printf("#include <stdbool.h>\n");
        self.header.printf("#include <string.h>\n");
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
        self.header.printf("typedef struct %s %s;\n", self.name, self.name);
        self.header.printf("\n");
        self.header.printf("struct %sIterator {\n", self.name);
        self.header.printf("        struct %s *ref;\n", self.name);
        self.header.printf("        uint64_t idx;\n");
        self.header.printf("};\n");
        self.header.printf("typedef struct %sIterator %sIterator;\n", self.name, self.name);
        self.header.printf("\n");
}

fn void CollectionString.makeError(&self) @dynamic {
        self.header.printf("enum %sError {\n", self.name);
        self.header.printf("        %s_MODIFY_UNWONED,\n", self.upperName);
        self.header.printf("        %s_ALLOC_ERROR,\n", self.upperName);
        self.header.printf("        %s_SUCCESS,\n", self.upperName);
        self.header.printf("};\n");
        self.header.printf("typedef enum %sError %sError;\n", self.name, self.name);
        self.header.printf("extern enum %sError g_%sError;\n", self.name, self.name);
        self.header.printf("\n");
        self.header.printf("char *%sError_toCstr();\n", self.name);
        self.header.printf("\n");

        File f = self.createNew("_errors.c");
        defer f.close()!!;
        @pool() {
                f.printf("#include \"%s.h\"\n", self.name.temp_ascii_to_lower());
        };
        f.printf("enum %sError g_%sError = %s_SUCCESS;\n", self.name, self.name, self.upperName);
        f.printf("\n");
        f.printf("char *%sError_toCstr() {\n", self.name);
        f.printf("        switch(g_%sError) {\n", self.name);
        f.printf("                case %s_MODIFY_UNWONED: return \"%s No Modify Unowned\";\n", self.upperName, self.name);
        f.printf("                case %s_ALLOC_ERROR: return \"%s Allocation Error\";\n", self.upperName, self.name);
        f.printf("                case %s_SUCCESS: return \"%s Success\";\n", self.upperName, self.name);
        f.printf("                default: return \"%s Unknown Error\";\n", self.name);
        f.printf("        }\n");
        f.printf("}\n");
}

fn void CollectionString.makeMethods(&self) @dynamic {
        self.makeConstructors();
        self.makeCharOp();
        self.makeCharPointerOp();
        self.makeUtils();
}

fn void CollectionString.end(&self) @dynamic {
        self.header.printf("#endif // %s_H", self.upperName);
        self.header.close()!!;
        self.name.free();
        self.upperName.free();
}

fn void CollectionString.setName(&self, String name) @dynamic {
        self.name.free();
        self.upperName.free();
        self.name = name.copy();
        self.upperName = self.name.copy();
        self.upperName.convert_ascii_to_upper();
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

        File f = self.createNew("_constructors.c");
        defer f.close()!!;
        @pool() {
                f.printf("#include \"%s.h\"\n", self.name.temp_ascii_to_lower());
        };
        f.printf("#include <stdlib.h>\n");
        self.makeConstructorDef(f, "newFromCstr(char *ptr)");
        f.printf("        return (struct %s) {\n", self.name);
        f.printf("                .len = strlen(ptr),\n");
        f.printf("                .capacity = strlen(ptr) + 1,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "new(char *ptr, uint64_t len)");
        f.printf("        return (struct %s) {\n", self.name);
        f.printf("                .len = len,\n");
        f.printf("                .capacity = len,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "newUnownedFromCstr(char *ptr)");
        f.printf("        return (struct %s) {\n", self.name);
        f.printf("                .len = strlen(ptr),\n");
        f.printf("                .capacity = strlen(ptr) + 1,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "newWithCapacity(uint64_t capacity)");
        f.printf("        char *ptr = malloc(capacity * sizeof(char));\n");
        f.printf("        if(!ptr) g_%sError = %s_ALLOC_ERROR;\n", self.name, self.upperName);
        f.printf("        return (struct %s) {\n", self.name);
        f.printf("                .len = 0,\n");
        f.printf("                .capacity = capacity,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = true,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
        self.makeConstructorDef(f, "newUnowned(char *ptr, uint64_t len)");
        f.printf("        return (struct %s) {\n", self.name);
        f.printf("                .len = len,\n");
        f.printf("                .capacity = len,\n");
        f.printf("                .ptr = ptr,\n");
        f.printf("                .owned = false,\n");
        f.printf("        };\n");
        f.printf("}\n");
        f.printf("\n");
}

fn void CollectionString.makeUtils(self) {
        self.header.printf("void %s_grow(struct %s *self);\n", self.name, self.name);
        File f = self.createNew("_utils.c");
        defer f.close()!!;
        @pool() {
                f.printf("#include \"%s.h\"\n", self.name.temp_ascii_to_lower());
        };
        f.printf("#include <stdlib.h>\n");
        f.printf("\n");
        f.printf("#define DEFAULT_%s_CAPACITY 1024\n", self.upperName);
        f.printf("\n");
        f.printf("void %s_grow(struct %s *self) {\n", self.name, self.name);
        f.printf("        if(!self->owned) {\n");
        f.printf("                g_%sError = %s_MODIFY_UNWONED;\n", self.name, self.upperName);
        f.printf("                return;\n");
        f.printf("        }\n");
        f.printf("        if(self->ptr == NULL || self->capacity == 0) self->capacity = DEFAULT_%s_CAPACITY;\n", self.upperName);
        f.printf("        else self->capacity *= 2;\n");
        f.printf("        self->ptr = realloc(self->ptr, self->capacity);\n");
        f.printf("        if(!self->ptr) g_%sError = %s_ALLOC_ERROR;\n", self.name, self.upperName);
        f.printf("}\n");
}

fn void CollectionString.makeCharOp(self) {
        self.header.printf("char %s_pop(struct %s *self);\n", self.name, self.name);
        self.header.printf("char %s_popBack(struct %s *self);\n", self.name, self.name);
        self.header.printf("void %s_push(struct %s *self, char c);\n", self.name, self.name);
        self.header.printf("void %s_pushBack(struct %s *self, char c);\n", self.name, self.name);

        File f = self.createNew("_char_op.c");
        defer f.close()!!;
        @pool() {
                f.printf("#include \"%s.h\"\n", self.name.temp_ascii_to_lower());
        };
        f.printf("\n");
        f.printf("char %s_pop(struct %s *self) {\n", self.name, self.name);
        f.printf("        if(!self->owned) {\n");
        f.printf("                g_%sError = %s_MODIFY_UNWONED;\n", self.name, self.upperName);
        f.printf("                return 0;\n");
        f.printf("        }\n");
        f.printf("        if(self->ptr == NULL || self->len == self->capacity) %s_grow(self);\n", self.name);
        f.printf("        if(g_%sError != %s_SUCCESS) return 0;\n", self.name, self.upperName);
        f.printf("        char c = self->ptr[0];\n");
        f.printf("        memmove(self->ptr, self->ptr + 1, --self->len);\n");
        f.printf("        return c;\n");
        f.printf("}\n");
        f.printf("\n");
        f.printf("char %s_popBack(struct %s *self) {\n", self.name, self.name);
        f.printf("        if(!self->owned) {\n");
        f.printf("                g_%sError = %s_MODIFY_UNWONED;\n", self.name, self.upperName);
        f.printf("                return 0;\n");
        f.printf("        }\n");
        f.printf("        if(self->ptr == NULL || self->len == self->capacity) %s_grow(self);\n", self.name);
        f.printf("        if(g_%sError != %s_SUCCESS) return 0;\n", self.name, self.upperName);
        f.printf("        return self->ptr[self->len--];\n");
        f.printf("}\n");
        f.printf("\n");
        f.printf("void %s_push(struct %s *self, char c) {\n", self.name, self.name);
        f.printf("        if(!self->owned) {\n");
        f.printf("                g_%sError = %s_MODIFY_UNWONED;\n", self.name, self.upperName);
        f.printf("                return;\n");
        f.printf("        }\n");
        f.printf("        if(self->ptr == NULL || self->len == self->capacity) %s_grow(self);\n", self.name);
        f.printf("        if(g_%sError != %s_SUCCESS) return;\n", self.name, self.upperName);
        f.printf("        memmove(self->ptr + 1, self->ptr, self->len++);\n");
        f.printf("        self->ptr[0] = c;\n");
        f.printf("}\n");
        f.printf("\n");
        f.printf("void %s_pushBack(struct %s *self, char c) {\n", self.name, self.name);
        f.printf("        if(!self->owned) {\n");
        f.printf("                g_%sError = %s_MODIFY_UNWONED;\n", self.name, self.upperName);
        f.printf("                return;\n");
        f.printf("        }\n");
        f.printf("        if(self->ptr == NULL || self->len == self->capacity) %s_grow(self);\n", self.name);
        f.printf("        if(g_%sError != %s_SUCCESS) return;\n", self.name, self.upperName);
        f.printf("        self->ptr[self->len++] = c;\n");
        f.printf("}\n");
}

fn void CollectionString.makeCharPointerOp(self) {
        // append insert erease find 
        self.header.printf("void %s_append(struct %s *self, struct %s other);\n", self.name, self.name, self.name);
        self.header.printf("uint64_t %s_find(struct %s *self, struct %s *needle);\n", self.name, self.name, self.name);
        self.header.printf("void %s_erease(struct %s *self, uint64_t start, uint64_t len);\n", self.name, self.name);
        self.header.printf("void %s_insert(struct %s *self, struct %s other, uint64_t pos);\n", self.name, self.name, self.name);

        File f = self.createNew("_char_p_op.c");
        defer f.close()!!;
        @pool() {
                f.printf("#include \"%s.h\"\n", self.name.temp_ascii_to_lower());
        };
        f.printf("\n");
}
