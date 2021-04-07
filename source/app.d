import std.stdio : write, writeln, writefln;
import std.range : front;
import std.format : format;
import commandr : Argument, Flag, Program, Command, printHelp, parse;
import repo;
import objects;

void main(string[] args) {
    Program program = new Program("small-git", "1.0").summary(
            "Write-Yourself-a-git implemented in D").author("DYGV");

    // add "init" command
    program.add(new Command("init").add(new Argument("dir",
            "directory").defaultValue("./")));

    // add "cat-file"
    program.add(new Command("cat-file").add(new Flag("t", null,
            "show object type").name("type")).add(new Flag("s", null,
            "show object type").name("size"))
            .add(new Flag("p", null, "pretty-print object's content").name("pprint"))
            .add(new Argument("object", "object id")));

    // add "hash-object"
    program.add(new Command("hash-object").add(new Flag("w", null,
            "show object type").name("write")).add(new Argument("path", "path")));

    // add "log"
    program.add(new Command("log").add(new Argument("commit", "commit object id")));

    // add "ls-tree"
    program.add(new Command("ls-tree").add(new Argument("object", "The object to show")));

    auto a = program.parse(args);

    a.on("init", (args) { cmd_init(args.arg("dir")); });

    a.on("cat-file", (args) {
        bool type = args.flag("type");
        bool size = args.flag("size");
        bool pprint = args.flag("pprint");
        string object = args.arg("object");
        cmd_cat_file(object, type, size, pprint).write;
    });

    a.on("hash-object", (args) {
        bool w = args.flag("write");
        string path = args.arg("path");
        cmd_hash_object(w, path).writeln;
    });

    a.on("log", (args) { cmd_log(args.arg("commit")).writeln; });

    a.on("ls-tree", (args) { cmd_ls_tree(args.arg("object")).writeln; });
}

void cmd_add(string args) {

}

string cmd_cat_file(string args, bool t, bool s, bool p) {
    GitRepository repo = repo_find();
    GitObject object = object_read(repo, args);
    if (t) {
        return object.fmt;
    } else if (s) {
        return object.size;
    }
    return object.serialize;
}

void cmd_checkout(string args) {

}

void cmd_commit(string args) {

}

string cmd_hash_object(bool w, string args) {
    GitRepository repo = null;
    if (w) {
        repo = new GitRepository("./");
    }
    return object_hash(args, "blob", repo);
}

void cmd_init(string arg) {
    repo_create(arg);
}

string cmd_log(string args) {
    GitRepository repo = repo_find();
    return log(repo, args);
}

string cmd_ls_tree(string args) {
    GitRepository repo = repo_find();
    GitTree object = cast(GitTree)object_read(repo, args);
    if (object.fmt != "tree") {
        (cast(GitCommit)object).commit_data.front.writeln;
    }
    string ls_tree = "";
    foreach (obj; (cast(GitTree)object).leaf) {
        string fmt = object_read(repo, obj.sha).fmt;

        ls_tree = format!"%s\t%s\t%s\t%s"(obj.mode, fmt, obj.sha, obj.path);
    }
    return ls_tree;
}

void cmd_merge(string args) {

}

void cmd_rebase(string args) {

}

void cmd_rev_parse(string args) {

}

void cmd_rm(string args) {

}

void cmd_show_ref(string args) {

}

void cmd_tag(string args) {

}
