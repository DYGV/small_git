module objects;

import std.format : format;
import std.range : empty;
import std.array : replace;
import std.format : format;
import std.file : read, mkdir, dirEntries, SpanMode, exists;
import std.zlib : compress, uncompress;
import std.uni : toLower;
import std.stdio : File;
import std.conv : to, parse;
import std.algorithm.searching : countUntil, startsWith;
import std.digest.sha : SHA1Digest, toHexString;
import std.typecons;
import repo;

class GitObject {
    GitRepository repo;
    string fmt, size;
    this(GitRepository repo, string size, string data = "") {
        this.repo = repo;
        this.size = size;
        if (!data.empty) {
            this.deserialize(data);
        }
    }

    abstract string serialize();
    abstract void deserialize(string data);
}

class GitBlob : GitObject {
    string blobdata;

    this(GitRepository repo, string size, string data = "") {
        super(repo, size, data);
        fmt = "blob";
    }

    override string serialize() {
        return blobdata;
    }

    override void deserialize(string data) {
        this.blobdata = data;
    }
}

class GitCommit : GitObject {
    KVLM_TBL[] commit_data;

    this(GitRepository repo, string size, string data = "") {
        super(repo, size, data);
        fmt = "commit";
    }

    override string serialize() {
        return kvlm_serialize(this.commit_data);
    }

    override void deserialize(string data) {
        this.commit_data = kvlm_parse(data);
    }
}

class GitTreeLeaf {
    string mode, path, sha;
    this(string mode, string path, string sha) {
        this.mode = mode;
        this.path = path;
        this.sha = sha;
    }
}

alias Leaf = Tuple!(long, GitTreeLeaf);
Leaf tree_parse_one(string raw, long start = 0) {
    long x = raw[start .. $].countUntil(' ') + start;
    string mode = raw[start .. x];
    long y = raw[x .. $].countUntil('\0') + x;
    string path = raw[x + 1 .. y];
    ubyte[] sha_byte = cast(ubyte[])raw[y + 1 .. y + 21];
    string sha = sha_byte.toHexString.toLower;
    GitTreeLeaf tree_leaf = new GitTreeLeaf(mode, path, sha);
    Leaf leaf;
    leaf[0] = y + 21;
    leaf[1] = tree_leaf;
    return leaf;
}

string tree_serialize(GitTree object) {
    string ret = "";
    foreach (obj; object.leaf) {
        ubyte[] buffer;
        ret ~= obj.mode;
        ret ~= ' ';
        ret ~= obj.path;
        ret ~= '\0';
        for (int i = 0; i < 20; i++) {
            string b = obj.sha[i * 2 .. i * 2 + 2];
            buffer ~= parse!ubyte(b, 16);
        }
        ret ~= (cast(string)buffer);
    }
    return ret;
}

auto tree_parse(string raw) {
    long pos = 0;
    long max = raw.length;
    GitTreeLeaf[] ret = [];
    while (pos < max) {
        Leaf leaf = tree_parse_one(raw, pos);
        pos = leaf[0];
        ret ~= leaf[1];
    }
    return ret;
}

class GitTree : GitObject {
    string tree_data;
    GitTreeLeaf[] leaf;
    this(GitRepository repo, string size, string data = "") {
        super(repo, size, data);
        fmt = "tree";
    }

    override string serialize() {
        return tree_serialize(this);
    }

    override void deserialize(string data) {
        this.leaf = tree_parse(data);
    }
}

string ref_resolve(GitRepository repo, string refer) {
    if (!refer.exists) {
        refer = repo_file(repo, refer);
    }
    string data = cast(string)refer.read[0 .. $ - 1];
    if (data.startsWith("ref: ")) {
        return ref_resolve(repo, data[5 .. $]);
    } else {
        return data;
    }
}

TBL[] ref_list(GitRepository repo, string path = "") {
    if (path.empty) {
        path = repo_dir(repo, "refs");
    }
    TBL[] ret;
    foreach (f; dirEntries(path, SpanMode.depth)) {
        if (!f.isDir) {
            ret ~= KVLM_TBL(f, ref_resolve(repo, f));
        }
    }
    return ret;
}

string show_ref(GitRepository repo, TBL[] refs) {
    string ret = "";
    foreach (i; refs) {
        ret ~= format!"%s\t%s\n"(i.value, i.key);
    }
    return ret;
}

void tree_checkout(GitRepository repo, GitTree tree, string path) {
    foreach (item; tree.leaf) {
        GitObject obj = object_read(repo, item.sha);
        string dest = path ~ item.path;
        if (obj.fmt == "tree") {
            dest.mkdir;
            tree_checkout(repo, cast(GitTree)obj, dest ~ "/");
        } else if (obj.fmt == "blob") {
            auto f = File(dest, "wb");
            f.write((cast(GitBlob)obj).blobdata);
        }
    }
}

KVLM_TBL[] kvlm_parse(string raw, KVLM_TBL[] dct = null) {
    long spc = raw.countUntil(' ');
    long nl = raw.countUntil('\n');
    if (spc < 0 || nl < spc) {
        dct ~= KVLM_TBL("", raw[1 .. $]);
        return dct;
    }
    string key = raw[0 .. spc];
    string value = raw[spc + 1 .. nl];
    dct ~= KVLM_TBL(key, value);
    raw = raw[nl + 1 .. $];
    return kvlm_parse(raw, dct);
}

alias TBL = KVLM_TBL;
struct KVLM_TBL {
    string key, value;
    this(string key, string value) {
        this.key = key;
        this.value = value;
    }
}

string kvlm_serialize(KVLM_TBL[] kvlm) {
    string ret = "";
    foreach (kvlm_tbl; kvlm) {
        string value = kvlm_tbl.value;
        ret ~= kvlm_tbl.key ~ ' ' ~ value.replace('\n', "\n ") ~ '\n';
    }
    return ret;
}

string log(GitRepository repo, string sha, string commits = "") {
    if (!sha) {
        return commits;
    }
    string parent;
    GitObject obj = object_read(repo, sha, true);
    if (obj.fmt != "commit") {
        return "";
    }
    foreach (c; (cast(GitCommit)obj).commit_data) {
        parent = c.key == "parent" ? c.value : parent;
        commits ~= c.key.empty ? "" : format!"%s: "(c.key);
        commits ~= c.value ~ "\n";
    }
    return log(repo, parent, commits);
}

GitObject object_read(GitRepository repo, string sha, bool head = false) {
    string path = repo_file(repo, "objects/" ~ sha[0 .. 2] ~ "/" ~ sha[2 .. $]);
    string raw = cast(string)uncompress(path.read);
    long x = countUntil(raw, ' ');
    string fmt = raw[0 .. x];
    long y = countUntil(raw, '\0');
    string size = raw[x + 1 .. y];
    GitObject obj;
    switch (fmt) {
    case "commit":
        obj = new GitCommit(repo, size, raw[y + 1 .. $]);
        break;
    case "blob":
        obj = new GitBlob(repo, size, raw[y + 1 .. $]);
        break;
    case "tree":
        obj = new GitTree(repo, size, raw[y + 1 .. $]);
        break;
    default:
        break;
    }
    return obj;
}

string object_write(GitObject obj, bool actually_write = true) {
    ubyte[] result = cast(ubyte[])(
            obj.fmt ~ " " ~ obj.serialize.length.to!string ~ "\0" ~ obj.serialize);
    SHA1Digest sha_d = new SHA1Digest();
    string sha = toHexString(sha_d.digest(result)).toLower;
    if (actually_write) {
        string path = repo_file(obj.repo,
                "objects/" ~ sha[0 .. 2] ~ "/" ~ sha[2 .. $], actually_write);
        File file = File(path, "wb");
        file.write(cast(string)compress(result));
    }
    return sha;
}

string object_hash(string fd, string fmt, GitRepository repo) {
    string data = cast(string)fd.read();
    GitObject obj;
    switch (fmt) {
    case "blob":
        obj = new GitBlob(repo, data.length.to!string, data);
        break;
    case "commit":
        obj = new GitCommit(repo, data.length.to!string, data);
        break;
    case "tree":
        obj = new GitTree(repo, data.length.to!string, data);
        break;
    default:
        break;
    }
    return repo is null ? object_write(obj, false) : object_write(obj);
}

string object_find(GitRepository repo, string name, ubyte[] fmt = [], bool follow = true) {
    return name;
}
