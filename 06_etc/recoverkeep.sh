##  reover .keep file to make enable checkout
##  checkout 가능하도록 하기위해 다시 원복함
for i in `git status | grep deleted: | awk -F "deleted:" '{print $2}' `; do git checkout -- $i; echo "recover $i"; done;