## Make .keep file in the empty directory.
## cause git doesn't care for empty directory.
## �� ���丮�� keep ���� �����.
## git������ �� ���丮�� ���� �������� �ʴ´�.
for i in `git clean -nd | awk -F "Would remove " '{print $2}'`; do touch "$i/.keepemptydir"; echo make "$i.keepemptydir";  done;
git add *
echo 
git clean -nd