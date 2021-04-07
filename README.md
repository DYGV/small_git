# Write-Yourself-a-Gitを参考にGitの実装 
## Gitコマンドの対応状況
- [x] init
- [ ] add
- [x] cat-file
- [ ] checkout
- [ ] commit
- [x] hash-object
- [x] log
- [ ] ls-tree
- [ ] merge
- [ ] rebase
- [ ] rev-parse
- [ ] rm
- [ ] show-ref
- [ ] tag

## Gitオブジェクトの対応状況
|  | serialize | deserialize |
|:----:|:----:|:----:|
| Blob | ○ | ○ |
| Commit | ○  | ○ |
| Tree | × |○|
| Tag | × | × |

