module repo;

import std.stdio : File, writeln;
import std.array : split, join;
import std.conv : to;
import std.path : chainPath, absolutePath;
import std.file : exists, mkdir, isDir, mkdirRecurse, dirEntries, SpanMode;
import inifiled : INI, readINIFile, writeINIFile;

class GitRepository {
    private {
        string worktree;
        string gitdir;
        core conf;
    }
    this(string path, bool force = false) {
        this.worktree = path;
        this.gitdir = chainPath(path, ".git").to!string;
        if (!(force || gitdir.isDir)) {
            throw new Exception("Not a Git repository " ~ path);
        }
        string cf = repo_file(this, "config");
        if (cf.exists) {
            readINIFile(conf, cf);
        } else if (!force) {
            throw new Exception("Configuration file missing");
        }
        if (!force) {
            int vers = conf.repositoryformatversion;
            if (vers != 0) {
                throw new Exception("Unsupported repositoryformatversion");
            }
        }
    }
}

string repo_path(GitRepository repo, string path) {
    string chainedPath = chainPath(repo.gitdir, path).to!string;
    return chainedPath;
}

string repo_file(GitRepository repo, string path, bool mkdir = false) {
    if (repo_dir(repo, path.split("/")[0 .. $ - 1].join("/"), mkdir)) {
        return repo_path(repo, path);
    }
    return path;
}

string repo_dir(GitRepository repo, string path, bool mkdir = false) {
    path = repo_path(repo, path);
    if (path.exists && path.isDir) {
        return path;
    }
    if (mkdir) {
        path.mkdirRecurse;
        return path;
    } else {
        return "";
    }
}

GitRepository repo_create(string path) {
    GitRepository repo = new GitRepository(path, true);
    if (repo.worktree.exists) {
        if (!repo.worktree.isDir) {
            throw new Exception(path ~ " is not a directory");
        }
        if (repo.gitdir.exists && !dirEntries(repo.gitdir, SpanMode.depth).empty) {
            throw new Exception(repo.gitdir ~ " is not empty");
        }
    } else {
        repo.gitdir.mkdirRecurse;
    }

    repo_dir(repo, "branches", true);
    repo_dir(repo, "objects", true);
    repo_dir(repo, "refs/tags", true);
    repo_dir(repo, "refs/heads", true);
    File description_file = File(repo_file(repo, "description"), "w");
    description_file.write("Unnamed repository; edit this file 'description' to name the repository.\n");

    File head_file = File(repo_file(repo, "head"), "w");
    head_file.write("ref: refs/heads/master\n");

    core config = repo_default_config();
    writeINIFile(config, repo_file(repo, "config"));
    return repo;
}

core repo_default_config() {
    return core(0, false, false);
}

/// 再帰的に.gitがある場所まで遡る
GitRepository repo_find(string path = "", bool required = true) {
    GitRepository repo;
    path = absolutePath(path);
    string gitdir = chainPath(path, ".git").to!string;
    if (gitdir.exists && gitdir.isDir) {
        repo = new GitRepository(path);
        return repo;
    }
    string parent = absolutePath(chainPath(path, "..").to!string);
    if (parent == path) {
        if (required) {
            throw new Exception("No git directory");
        } else {
            return repo;
        }
    }
    return repo_find(parent, required);
}

/// configのcoreセクション
@INI struct core {
    @INI int repositoryformatversion;
    @INI bool filemode;
    @INI bool bare;
}
