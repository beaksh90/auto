## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.09.02
## Default source Directory

DG_TAR_FILE_DIR="C:/Multi-Runner/mfodg/deploy/MFO/tar"
PJS_FILE_DIR="C:/Multi-Runner/mfonp/deploy/MFO/PlatformJS"

DG_FILE_SEND()
{
cd $DG_TAR_FILE_DIR
DG_TAR_FILE=`ls Maxgauge*.tar`
echo -e "git" | pscp $DG_TAR_FILE gitlab-runner@10.10.202.201:/home/gitlab-runner/dg7000
echo -e "git" | pscp $DG_TAR_FILE gitlab-runner@10.10.202.200:/home/gitlab-runner/dg7000
}

PJS_FILE_SEND()
{
cd $PJS_FILE_DIR
7z.exe a PlatformJS_day.zip -x!*.zip
PJS_FILE=`ls PlatformJS*.zip`
echo -e "git" | pscp $PJS_FILE gitlab-runner@10.10.202.201:/home/gitlab-runner/pjs8080
echo -e "git" | pscp $PJS_FILE gitlab-runner@10.10.202.200:/home/gitlab-runner/pjs8080

}

DG_FILE_SEND
PJS_FILE_SEND