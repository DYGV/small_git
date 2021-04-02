import std.stdio: writeln;
import std.range: empty;
import commandr;
import repo;

void main(string[] args)
{
    auto a = new Program("small-git", "1.0")
          .summary("Write-Yourself-a-git implemented in D")
          .author("DYGV")
          .add(new Command("init")
              .add(new Argument("dir", "directory").defaultValue("./")))
          .add(new Command("cat-file")
              .add(new Flag("t", null, "show object type")
                .name("type"))
              .add(new Flag("s", null, "show object type")
                .name("size"))
              .add(new Flag("p", null, "pretty-print object's content")
                .name("pprint"))
            .add(new Argument("object", "object id"))
          )
          .parse(args);

  a.on("init", (args) {
      writeln("arg: ", args.arg("dir"));
      cmd_init(args.arg("dir"));
  });

  a.on("cat-file", (args) {
      writeln("t: ", args.flag("type"));
      writeln("s: ", args.flag("size"));
      writeln("p: ", args.flag("pprint"));
      writeln("object: ", args.arg("object"));
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

