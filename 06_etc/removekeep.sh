## Remove .keep file in the empty directory.
## 복사되는 소스내에 존재하는 keep 파일을 지워줌.
for i in `find . -name ".keepemptydir"` ; do rm $i; echo removed $i; done;