##  reover .keep file to make enable checkout
##  checkout �����ϵ��� �ϱ����� �ٽ� ������
for i in `git status | grep deleted: | awk -F "deleted:" '{print $2}' `; do git checkout -- $i; echo "recover $i"; done;