## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.10.25
## Default source Directory
sh /root/.bash_profile

curl ttps://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
yum -y install gitlab-ce
gitlab-ctl start
