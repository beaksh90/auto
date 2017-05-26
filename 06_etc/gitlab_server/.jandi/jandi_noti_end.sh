QUERY_DIR="/home/maxgauge/sqls"

SET_BASELINE()
{
echo "
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
SELECT * FROM
        (SELECT mfo_release_ver, mfobuild_tag, mfoweb_tag, mfosql_tag, mfonp_tag, mfodg_tag
        FROM mfo_tag
        ORDER BY mfo_release_ver desc)
        WHERE mfo_release_ver
        IN (select p1 from mfo_report where req_tag='j' 
	union all 
	select p2 from mfo_report where req_tag='j'); " > vers.sql
VERS=`echo exit | sqlplus -silent git/git@DEVQA23 @vers.sql`
rm vers.sql

TO_BASELINE=`echo $VERS | awk '{print $1}' | awk -F "_" '{print $2}'`
FROM_BASELINE=`echo $VERS | awk '{print $7}' | awk -F "_" '{print $2}'`
mfobuild=`echo $VERS | awk '{print $2" "$8}'`
mfoweb=`echo $VERS | awk '{print $3" "$9}'`
mfosql=`echo $VERS | awk '{print $4" "$10}'`
mfonp=`echo $VERS | awk '{print $5" "$11}'`
mfodg=`echo $VERS | awk '{print $6" "$12}'`

}

FILL_IN_JANDI_TEXT()
{
## TOP GREETING PART
FRONT="curl \\
-X POST https://wh.jandi.com/connect-api/webhook/11671944/2f7c4e5a519db8021cdbda11d6f12c16 \\
-H \"Accept: application/vnd.tosslab.jandi-v2+json\" \\
-H \"Content-Type: application/json\" \\
--data-binary '{\"body\":\"MFO Build & Environment Setting Finish.\n:D\",\"connectColor\":\"#99CCFF\",\"connectInfo\":[ {\"title\":\""

## BASELINE & TAG_INFO PART
TITLE_BASELINE="[ Baseline ${FROM_BASELINE} >> ${TO_BASELINE} ]"
TAG_INFO_MIDDLE_PART="\",\"description\":\""

BODY_TEXT=" -------------------------------------------------"
for CONF_ITEM in mfodg mfonp mfoweb mfosql mfobuild
do
        TO_TAG=`echo ${!CONF_ITEM} | awk '{print $1}'`
	FROM_TAG=`echo ${!CONF_ITEM} | awk '{print $2}'`
	if [ ${TO_TAG} != ${FROM_TAG} ]; then
		GET_DEV_MENTION
	else
		BODY_TEXT=`echo "$BODY_TEXT\n  $TO_TAG"`
	fi
done


## TEST ENV PART
TEST_ENV_PART="{\"title\":\"[ TEST Environment ]\",\"description\":\"[DEVQA21 : ORACLE & LINUX (패치)](http://10.10.32.21:8080/MAXGAUGE/)\n[DEVQA24 : ORACLE & LINUX (신규)](http://10.10.32.24:8080/MAXGAUGE/)\n[DEVQA22 : PG & LINUX (패치)](http://10.10.32.22:8080/MAXGAUGE/)\n[DEVQA20 : PG & WIN (신규)](http://10.10.32.20:8080/MAXGAUGE/)\"}"
echo "${FRONT} ${TITLE_BASELINE}${TAG_INFO_MIDDLE_PART}${BODY_TEXT}\"},${TEST_ENV_PART}]}'" > jandi_api.sh

}

GET_DEV_MENTION()
{
	BODY_TEXT=`echo "$BODY_TEXT\n[  $FROM_TAG >> $TO_TAG](http://10.10.32.101/mfo/${CONF_ITEM}/compare/${FROM_TAG}...${TO_TAG})"`
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	exec  update_dev_mention_view('${FROM_TAG}','${TO_TAG}');
	SELECT * from mfo_jandi_noti;" > dev_comments.sql
	DEV_COMMENTS=`echo exit | sqlplus -silent git/git@DEVQA23 @dev_comments.sql`
	rm dev_comments.sql
IFS="
"
	BODY_TEXT="$BODY_TEXT\n   Dev_Comment :"
	for STATEMENT in $DEV_COMMENTS
	do
	        STATEMENT=`echo $STATEMENT | sed -re 's:\x27:\x27\x5C\x5C\x27\x27:g'` # ESCAPE   ' -> '//'' 
	        STATEMENT=`echo $STATEMENT | sed -re 's:\x5C\x28:\x27\x5C\x5C\x28\x27:g'` # ESCAPE   ) -> '//)'
		STATEMENT=`echo $STATEMENT | sed -re 's:\x5C\x29:\x27\x5C\x5C\x29\x27:g'` # ESCAPE   ( -> '//('
		MAKE_REDMINE_HYPERLINK
		BODY_TEXT=`echo "$BODY_TEXT\n${STATEMENT}"`
	done
	unset IFS
	#BODY_TEXT="$BODY_TEXT\n   QA_NOTEs :\n    will be supported"
}

MAKE_REDMINE_HYPERLINK()
{
if [ `echo $STATEMENT | grep -E "#[0-9]{3,6}"` ];
then
	unset IFS
	for FIND_NUM in $STATEMENT
	do
		if [ `echo $FIND_NUM | grep -E "#[0-9]{3,5}"` ]; then
		REDMINE_NUM=`echo $FIND_NUM | grep -E "#[0-9]{3,5}" | tr -d "#"`
		fi
	done		
	STATEMENT=`echo $STATEMENT | sed -re 's@'#$REDMINE_NUM'@['#$REDMINE_NUM'](http://115.178.73.20:32798/issues/'$REDMINE_NUM')@g'`
	STATEMENT="     $STATEMENT"
	echo $STATEMENT
IFS="
"
fi
}

SET_BASELINE
FILL_IN_JANDI_TEXT
sh jandi_api.sh
rm jandi_api.sh
