## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.10.25
## Default source Directory
TAG_DIR[1]=/var/opt/gitlab/git-data/repositories/mfo/mfonp.git;  ## MFONP_DIR
TAG_DIR[2]=/var/opt/gitlab/git-data/repositories/mfo/mfoweb.git; ## MFOWEB_DIR
TAG_DIR[3]=/var/opt/gitlab/git-data/repositories/mfo/mfosql.git; ## MFOSQL_DIR
TAG_DIR[4]=/var/opt/gitlab/git-data/repositories/mfo/mfodg.git;  ## MFODG_DIR
TAG_DIR[5]=/var/opt/gitlab/git-data/repositories/mfo/mforts.git; ## MFORTS_DIR
TAG_DIR[6]=/var/opt/gitlab/git-data/repositories/mfo/mfobuild.git; ## MFORTS_DIR
WORKING_DIR=`pwd`
sh /root/.bash_profile

TAG_COUNT()
{
TAG_COUNT1[1]=12
TAG_COUNT1[2]=10
TAG_COUNT1[3]=9
TAG_COUNT1[4]=16
TAG_COUNT1[5]=13
TAG_COUNT1[6]=24


cd ${TAG_DIR[1]} ; ## MFONP_DIR
TAG_COUNT2[1]=`git tag -l | grep -w mfonp*\_[0-9]*\.[0-9] | wc -l`
cd ${TAG_DIR[2]} ; ## MFOWEB_DIR
TAG_COUNT2[2]=`git tag -l | grep -w mfoweb*\_[0-9]*\.[0-9] | wc -l`
cd ${TAG_DIR[3]} ; ## MFOSQL_DIR
TAG_COUNT2[3]=`git tag -l | grep -w mfosql*\_[0-9]*\.[0-9] | wc -l`
cd ${TAG_DIR[4]} ; ## MFODG_DIR
TAG_COUNT2[4]=`git tag -l | grep -w mfodg*\_[0-9]*\.[0-9] | wc -l`
cd ${TAG_DIR[5]} ; ## MFORTS_DIR
TAG_COUNT2[5]=`git tag -l | grep -w mforts*\_[0-9]*\.[0-9] | wc -l`
cd ${TAG_DIR[6]} ; ## MFORTS_DIR
TAG_COUNT2[6]=`git tag -l | grep -w mfobuild*\_[0-9]*\.[0-9] | wc -l`

MFO_BUILD_TAG_NEWEST=`git tag -l | tail -n 1`
}

TAG_DIFF_GET()
{
TAG_KEY[1]="mfonp"
TAG_KEY[2]="mfoweb"
TAG_KEY[3]="mfosql"
TAG_KEY[4]="mfodg"
TAG_KEY[5]="mforts"
TAG_KEY[6]="mfobuild"
UPDATER=0

for i in 1 2 3 4 5 6
do
        if [ ${TAG_COUNT2[$i]} != ${TAG_COUNT1[$i]} ]; then
                        STEP=0
                        DIFF_COUNT=`expr ${TAG_COUNT2[$i]} - ${TAG_COUNT1[$i]}`
                        PASS_COUNT=`expr ${TAG_COUNT2[$i]} - ${DIFF_COUNT}`
                cd ${TAG_DIR[$i]}
                echo "Here is '${TAG_KEY[$i]}' Part "
                for TAG in `git tag -l | grep -w ${TAG_KEY[$i]}*\_[0-9]*\.[0-9]`
                do
                        STEP=`expr $STEP + 1`
                        if [ ${PASS_COUNT} -lt ${STEP} ]; then
                        echo "insert into  mfo_tag_part values('${TAG}','${MFO_BUILD_TAG_NEWEST}');" >> insert_tag.sql
                        fi
                done
                echo exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql
                sleep 1
                rm insert_tag.sql
                UPDATER=`expr $UPDATER + 1`
        fi
done
if [ $UPDATER != 0 ]; then
	UPDATE_THIS_FILE
fi
}


UPDATE_THIS_FILE ()
{
cd $WORKING_DIR
i=0
for i in 6 5 4 3 2 1
do
	ATTACHMENT="TAG_COUNT1[$i]=${TAG_COUNT2[$i]}\n$ATTACHMENT";
	echo "TAG_COUNT1[$i]=${TAG_COUNT2[$i]}"
done
	sed -e "14 a$ATTACHMENT" $0 > .mxctl2.sh;

sed -n '1,20p;28,$p' .mxctl2.sh > .mxctl.sh;
echo  "TAG COUNT VALUE UPDATE START ======================= ";
echo  -e "sleep 1\nmv .mxctl.sh $0\nrm -rf mxctlsaver.sh\nrm -rf .mxctl2.sh" >> mxctlsaver.sh
echo  "chmod 775 $0" >> mxctlsaver.sh
echo  "echo  TAG COUNT VALUE UPDATE FINISH ======================" >> mxctlsaver.sh
sh mxctlsaver.sh
}

ORACLE_ENV_VAR()
{
export ORACLE_HOSTNAME=DEVQA101
export ORACLE_UNQNAME=DEVQA101
export ORACLE_BASE=/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0.1/db_1
export ORACLE_SID=DEVQA101
export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
}

ORACLE_ENV_VAR
echo $PATH
TAG_COUNT
TAG_DIFF_GET
