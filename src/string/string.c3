module collecter::string;
import collecter::collection;
import std::io::file;
import std::core::dstring;

distinct CollectionString(Collection) = CollectionBase;

fn void CollectionString.makeHeader(self) {
        DString headerName = dstring::new(self.name);
        headerName.append(".h");
        foreach(&c : headerName) {
                c = c.to_lower();
        }
        File! f = file::open(headerName.str_view(), "w");
        headerName.free();
        if(catch f) return UNABLE_TO
}
