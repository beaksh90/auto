## Remove .keep file in the empty directory.
## ����Ǵ� �ҽ����� �����ϴ� keep ������ ������.
for i in `find . -name ".keepemptydir"` ; do rm $i; echo removed $i; done;