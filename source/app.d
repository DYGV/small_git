import std.stdio: writeln;
import std.range: empty;
import repo;

int main(string[] args)
{
    if(args.length < 2){
        return -1;}
    string arg = "";
    if(args.length > 2)
        arg = args[2];
    switch(args[1]){
        case "add": cmd_add(arg); break;
        case "cat-file": cmd_cat_file(arg); break;
        case "checkout": cmd_checkout(arg); break;
        case "commit": cmd_commit(arg); break;
        case "hash-object": cmd_hash_object(arg); break;
        case "init": cmd_init(arg); break;
        case "log": cmd_log(arg); break;
        case "ls-tree": cmd_is_tree(arg); break;
        case "merge": cmd_merge(arg); break;
        case "rebase": cmd_rebase(arg); break;
        case "rev-parse": cmd_rev_parse(arg); break;
        case "rm": cmd_rm(arg); break;
        case "show-ref": cmd_show_ref(arg); break;
        case "tag": cmd_tag(arg); break;
        default: args[1].writeln(" is not found"); break;
  } 
    return 1;
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
    if(arg.empty){
        arg = "./";
    }
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

