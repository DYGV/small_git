# Write-Yourself-a-Gitを参考にGitの実装
## Gitコマンドの対応状況
- [x] init
- [ ] add
- [x] cat-file
- [x] checkout
- [ ] commit
- [x] hash-object
- [x] log
- [x] ls-tree
- [ ] merge
- [ ] rebase
- [ ] rev-parse
- [ ] rm
- [x] show-ref
- [ ] tag

## Gitオブジェクトの対応状況
|  | serialize | deserialize |
|:----:|:----:|:----:|
| Blob | ○ | ○ |
| Commit | ○  | ○ |
| Tree | ○ |○|
| Tag | × | × |

## Setup
1.  Clone this repository
    ```
    git clone https://github.com/DYGV/small_git & cd ./small_git
    ```
2. Build with dub command
    ```
    dub build
    ```
## Usage Example
```
$ ./small_git log b902e8050973e1cef5e2c9f4110f90bb3be4de67
tree: 8838c8aaaad46621458f6a79eddc04948b920f09
parent: 50ce9be44e9246ffa385ed53627aef70f3f998e9
author: DYGV <11eisuke88@gmail.com> 1618126157 +0900
committer: DYGV <11eisuke88@gmail.com> 1618126157 +0900
update README.md

tree: bf4a54a729757e6dbea61047f09087ee0613f122
parent: 94c02a5f27fe3cb4cc8162cb67b775cc3cbaa58e
author: DYGV <11eisuke88@gmail.com> 1618126063 +0900
committer: DYGV <11eisuke88@gmail.com> 1618126063 +0900
add 'show-ref' command

...
```

```
$ ./small_git cat-file -t 50ce9be44e9246ffa385ed53627aef70f3f998e9
commit
```
```
$ ./small_git cat-file -p 50ce9be44e9246ffa385ed53627aef70f3f998e9
tree bf4a54a729757e6dbea61047f09087ee0613f122
parent 94c02a5f27fe3cb4cc8162cb67b775cc3cbaa58e
author DYGV <11eisuke88@gmail.com> 1618126063 +0900
committer DYGV <11eisuke88@gmail.com> 1618126063 +0900
 add 'show-ref' command
```

```
$ ./small_git hash-object ./test.txt
5ab2f8a4323abafb10abb68657d9d39f1a775057
```

```
$ ./small_git ls-tree 50ce9be44e9246ffa385ed53627aef70f3f998e9
100644  blob    6a75e08d7257bce6b361924e3ba65de9ee5832f7        .gitignore
100644  blob    ead8307d18733342c4bbb3d2065ca61c6c149ba5        README.md
100644  blob    69acf3d5de9343795bc08897023dede08b01df07        dub.json
100644  blob    db3037ef9dc614885cec83cce2757194221f30ae        dub.selections.json
40000   tree    19418802e007216273f47b89f5177d885be406c7        source
100644  blob    5ab2f8a4323abafb10abb68657d9d39f1a775057        test.txt
```

```
$ ./small_git show-ref
b902e8050973e1cef5e2c9f4110f90bb3be4de67        .git/refs/remotes/origin/HEAD
b902e8050973e1cef5e2c9f4110f90bb3be4de67        .git/refs/remotes/origin/master
b902e8050973e1cef5e2c9f4110f90bb3be4de67        .git/refs/heads/master
```

```
$ ./small_git checkout 78bec5a4132b2c8f443b2f27d2135b7f72685159 ./first_commit
$ ls
README.md  dub.json  dub.selections.json  first_commit  small_git  source  test.txt
```

