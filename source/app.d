import std.stdio: writeln;
import std.range: empty;
import commandr;
import repo;

void main(string[] args){
    Program program = new Program("small-git", "1.0")
          .summary("Write-Yourself-a-git implemented in D")
          .author("DYGV");

    // add "init" command
    program.add(new Command("init")
              .add(new Argument("dir", "directory").defaultValue("./")));

    // add "cat-file"
    program.add(new Command("cat-file")
              .add(new Flag("t", null, "show object type")
                .name("type"))
              .add(new Flag("s", null, "show object type")
                .name("size"))
              .add(new Flag("p", null, "pretty-print object's content")
                .name("pprint"))
            .add(new Argument("object", "object id")));

    auto a = program.parse(args);

    a.on("init", (args){
        cmd_init(args.arg("dir"));
    });

    a.on("cat-file", (args){
        bool type = args.flag("type"),
             size = args.flag("size"),
             pprint = args.flag("pprint");
        if(!(type|size|pprint)){
            program.commands["cat-file"].printHelp();
            return;
        }
        string object = args.arg("object");
    });
}

void cmd_add(string args){

}

void cmd_cat_file(string args){

}

void cmd_checkout(string args){

}

void cmd_commit(string args){

}

void cmd_hash_object(string args){

}

void cmd_init(string arg){
    repo_create(arg);
}

void cmd_log(string args){

}

void cmd_is_tree(string args){

}

void cmd_merge(string args){

}

void cmd_rebase(string args){

}

void cmd_rev_parse(string args){

}

void cmd_rm(string args){

}

void cmd_show_ref(string args){

}

void cmd_tag(string args){

}

