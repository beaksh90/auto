## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.03.31
## Default source Directory

TAG_DIR[1]=/var/opt/gitlab/git-data/repositories/mfo/mfonp.git;  ## MFONP_DIR
TAG_DIR[2]=/var/opt/gitlab/git-data/repositories/mfo/mfoweb.git; ## MFOWEB_DIR
TAG_DIR[3]=/var/opt/gitlab/git-data/repositories/mfo/mfosql.git; ## MFOSQL_DIR
TAG_DIR[4]=/var/opt/gitlab/git-data/repositories/mfo/mfodg.git;  ## MFODG_DIR
TAG_DIR[5]=/var/opt/gitlab/git-data/repositories/mfo/mforts.git; ## MFORTS_DIR
TAG_DIR[6]=/var/opt/gitlab/git-data/repositories/mfo/mfobuild.git; ## MFOBUILD_DIR
WORKING_DIR=`pwd`
sh /root/.bash_profile

TAG_COUNT()
{
TAG_COUNT1[1]=15
TAG_COUNT1[2]=23
TAG_COUNT1[3]=14
TAG_COUNT1[4]=26
TAG_COUNT1[5]=12
TAG_COUNT1[6]=36

cd ${TAG_DIR[1]} ; ## MFONP_DIR
TAG_COUNT2[1]=`git tag -l "mfonp*\_[0-9]*[.][0-9][0-9]" | wc -l`
cd ${TAG_DIR[2]} ; ## MFOWEB_DIR
TAG_COUNT2[2]=`git tag -l "mfoweb*\_[0-9]*[.][0-9][0-9]" | wc -l`
cd ${TAG_DIR[3]} ; ## MFOSQL_DIR
TAG_COUNT2[3]=`git tag -l "mfosql*\_[0-9]*[.][0-9][0-9]" | wc -l`
cd ${TAG_DIR[4]} ; ## MFODG_DIR
TAG_COUNT2[4]=`git tag -l "mfodg*\_[0-9]*[.][0-9][0-9]" | wc -l`
cd ${TAG_DIR[5]} ; ## MFORTS_DIR
TAG_COUNT2[5]=`git tag -l "mforts*\_[0-9]*[.][0-9][0-9]" | wc -l`
cd ${TAG_DIR[6]} ; ## MFORTS_DIR
TAG_COUNT2[6]=`git tag -l "mfobuild*\_[0-9]*[.][0-9][0-9]" | wc -l`

MFO_BUILD_TAG_NEWEST=`git tag -l | tail -n 1`
}

PREVENT_FROM_DUPLE_EXEC ()
{
TAG_CHECKER_PID=`ps -ef | grep -v grep | grep -v $$ | grep "/var/opt/gitlab/tag_checker.sh" | awk '{print $2}' | wc -l `
SONAR_SCANNER_PID=`ps -ef | grep -v "grep" | grep "/app/sonarqube/sonar-scanner" | awk '{print $2}'`

    if [ "$TAG_CHECKER_PID" -gt 1 ]||[ "$SONAR_SCANNER_PID" != "" ];
    then
        echo "Due to existing Process tag_checker process number : $TAG_CHECKER_PID , sonar_scanner : $SONAR_SCANNER_PID, Exit. "
        exit
    else 
        echo -e "\nNothing previous Process..!\n"
    fi;
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

            for TAG in `git tag -l "${TAG_KEY[$i]}*\_[0-9]*[.][0-9][0-9]"`
                do
                STEP=`expr $STEP + 1`
                if [ ${PASS_COUNT} -lt ${STEP} ]; then
                    EXTRACT_DEV_MENTION
                    echo "insert into  mfo_tag_part values('${TAG}','${MFO_BUILD_TAG_NEWEST}','${QUERY_DEV_MENTION}');" >> insert_tag.sql
                    UPDATER=`expr $UPDATER + 1`
                    STATIC_ANALYSIS_SONARQUBE
                    SEND_MAIL
                else
                    PREVIOUS_TAG=$TAG
                fi
            done

            echo exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql
            sleep 1
            rm insert_tag.sql
        fi
done
}

EXTRACT_DEV_MENTION ()
{
IFS="
"
for STATEMENT in `git log ${PREVIOUS_TAG}..${TAG}`;
do
    HEAD_WORD=`echo $STATEMENT | awk '{print $1}'`;
    FILTERED_HEAD_WORD=`echo $HEAD_WORD | grep -E "commit|Author:|Date:|Merge|Merge:"`
    if [ -z  $FILTERED_HEAD_WORD ]&&[ "$HEAD_WORD" != "" ]; then
        DEV_MENTION="$DEV_MENTION $STATEMENT\n"
        STATEMENT=`echo $STATEMENT | sed -re 's:\x27:\x27\x27:g'`
        echo $STATEMENT;
        QUERY_DEV_MENTION="$QUERY_DEV_MENTION $STATEMENT"
    fi;
done;
IFS=" "
}


STATIC_ANALYSIS_SONARQUBE ()
{
if [ "${TAG_KEY[$i]}" = "mfonp" ]||[ "${TAG_KEY[$i]}" = "mfoweb" ]||[ "${TAG_KEY[$i]}" = "mfodg" ]; then
    cd /app/sonarqube/static_analysis_items/${TAG_KEY[$i]}
    git fetch git@10.10.32.101:mfo/${TAG_KEY[$i]}.git --tag
    git checkout $TAG
    sed -i s/sonar.projectVersion=.*/sonar.projectVersion=$TAG/g ./sonar-project.properties
    sonar-scanner
    cd ${TAG_DIR[$i]}
    pwd
    SONAR_URL=" 3.SONAR QUBE URL : http://10.10.32.101:9000/ "
fi
}

SEND_MAIL ()
{
    CONF_ITEM=`echo ${PREVIOUS_TAG} | awk -F "_" '{print $1}'`

    ALL_RECEIVER="beaksh90@naver.com mookiang@ex-em.com bsa@ex-em.com cryingpcs@ex-em.com"
    MFOSQL_WEB_RECEIVER="hwankb@ex-em.com daru87@ex-em.com kangjm103@ex-em.com wnsrl56@ex-em.com gayoon.huh@ex-em.com"
    MFODG_RECEIVER="ezra@ex-em.com magyeon@ex-em.com"
    MFORTS_RECEIVER="jeungwoo.we@ex-em.com jcwon@ex-em.com wonsik@ex-em.com"
    MFONP_RECEIVER="uizu99@ex-em.com hwankb@ex-em.com "

    GET_WEBPAGE_SCREENSHOT $CONF_ITEM $PREVIOUS_TAG $TAG

    MAIL_TEXT $ALL_RECEIVER
    
    if [ `echo ${TAG} | grep mfosql` ]||[ `echo ${TAG} | grep mfoweb` ]; then
        MAIL_TEXT $MFOSQL_WEB_RECEIVER
    elif [ `echo ${TAG} | grep mfodg` ]; then
        MAIL_TEXT $MFODG_RECEIVER
    elif [ `echo ${TAG} | grep mforts` ]; then
                MAIL_TEXT $MFORTS_RECEIVER
    elif [ `echo ${TAG} | grep mfonp` ]; then
                MAIL_TEXT $MFONP_RECEIVER
    fi

    rm -rf ./difference*.png
    rm -rf ./getpage.js
}

MAIL_TEXT ()
{
    echo -e " 1.GITLAB URL : http://10.10.32.101/mfo/${CONF_ITEM}/compare/${PREVIOUS_TAG}...${TAG}?view=parallel\n\n 2.DEV_COMMENT\n$DEV_MENTION\n\n$SONAR_URL"  | mail -a difference*.png -s "MFO TAG '${TAG}' is just pushed." $@
}

GET_WEBPAGE_SCREENSHOT ()
{
echo "var page = new WebPage(), testindex = 0, loadInProgress = false;

page.onConsoleMessage = function(msg) {
  console.log(msg);
};

page.onLoadStarted = function() {
  loadInProgress = true;
  console.log(\"load started\");
};

page.onLoadFinished = function() {
  loadInProgress = false;
  console.log(\"load finished\");
};

var stepName = [\"page open\", \"insert id pw\", \"login\", \"render\"];
var steps = [
function() {
  page.viewportSize = { width: 1980, height: 1200 }
  page.open(\"http://10.10.32.101/mfo/$1/compare/$2...$3?view=parallel\");
},
function() {
  page.evaluate(function() {
    document.getElementById('user_login').value = 'maxgauge';
    document.getElementById('user_password').value = 'dev7u8i9o0p';
  });
},
function() {
  page.evaluate(function() {
    document.getElementById('new_user').submit();
  });
},
function() {
   page.render('difference_$2..$3.png');
  }
  ];

  interval = setInterval(function() {
    if (!loadInProgress && typeof steps[testindex] == \"function\") {
      console.log(stepName[(testindex)] + \" start\");
      steps[testindex]();
      testindex++;
    }
    if (typeof steps[testindex] != \"function\") {
      console.log(\"finish!!!!\");
      phantom.exit();
    }
}, 50);" > getpage.js

phantomjs getpage.js
}

UPDATE_THIS_FILE ()
{
if [ $UPDATER != 0 ]; then
    cd $WORKING_DIR
    i=0
    for i in 6 5 4 3 2 1
    do
        ATTACHMENT="TAG_COUNT1[$i]=${TAG_COUNT2[$i]}\n$ATTACHMENT";
        echo "TAG_COUNT1[$i]=${TAG_COUNT2[$i]}"
    done
        sed -e "15 a$ATTACHMENT" $0 > .mxctl2.sh;

    sed -n '1,21p;29,$p' .mxctl2.sh > .mxctl.sh;
    echo  "TAG COUNT VALUE UPDATE START ======================= ";
    echo  -e "sleep 1\nmv .mxctl.sh $0\nrm -rf mxctlsaver.sh\nrm -rf .mxctl2.sh" >> mxctlsaver.sh
    echo  "chmod 775 $0" >> mxctlsaver.sh
    echo  "echo  TAG COUNT VALUE UPDATE FINISH ======================" >> mxctlsaver.sh
    sh mxctlsaver.sh
fi
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
export NLS_LANG=AMERICAN_AMERICA.UTF8
}

PREVENT_FROM_DUPLE_EXEC
ORACLE_ENV_VAR
TAG_COUNT
TAG_DIFF_GET
UPDATE_THIS_FILE