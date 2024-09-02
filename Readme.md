# Collecter

this program name is composed of collection and maker, it is a C colletion library maker

## how to use it

this command will be used as:

```Bash
collecter <collection> (<type> ...) [OPTIONS] ...
```

## list of collections

 - `list`: simply linked list (1 type);
 - `dlist`: doubled linked list (1 type);
 - `stack`: stack (1 type);
 - `array`: dynamic array (1 type);
 - `map`: unordered map (2 type);
 - `string`: dynamic strings (0 type);
 - `btree`: binary tree (1 type);
 - `ntree`: dynamic tree (1 type);

## type

collections need types, and any type that is available in c can be used (custom structures, integers, pointers, etc...)

## list of options

 - `-i <file>` or `--include <file>`: specify and include to add to the header file;
 - `-n <norme>` or `--norme <norme>`: specify the norm to use; [42, linux(default)]
 - `-s <name>` or `--structure <name>`: specify the collection structure name;
 - `-t <name>` or `--iterator <name>`: specify the iterator structure name;
 - `-h <name>` or `--header <name>`: specify the collection header name;
 - `-p <prefix>` or `--prefix <prefix>`: specify the sources file prefix;
 - `-b` or `--boolean`: use gnu2x standard instead of stdbool.h library;
 - `-d <directory>` or `--directory <directory>`: specify a source directory (by default all the files will be put inside of it);
 - `-r <directory>` or `--hdirectory <directory>`: specify a header directory; 
