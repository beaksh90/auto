## Make .keep file in the empty directory.
## cause git doesn't care for empty directory.
## 빈 디렉토리에 keep 파일 만들기.
## git에서는 빈 디렉토리에 대해 관리하지 않는다.
for i in `git clean -nd | awk -F "Would remove " '{print $2}'`; do touch "$i/.keepemptydir"; echo make "$i.keepemptydir";  done;
git add *
echo 
git clean -nd