echo INPUT IPADDRESS
read REPO_OR_TARGET_IP
echo -e "y\n" | pscp sendfile.sh gitlab-runner@${REPO_OR_TARGET_IP}:/home/gitlab-runner/.oldone;