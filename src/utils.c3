module std::io::file;

fn usz! File.printf(&self, String format, args...) {
        return io::fprintf(self, format, args);
}
