JANDI_WEBHOOK ()
{
echo "
curl \
-X POST https://wh.jandi.com/connect-api/webhook/11671944/2f7c4e5a519db8021cdbda11d6f12c16 \
-H \"Accept: application/vnd.tosslab.jandi-v2+json\" \
-H \"Content-Type: application/json\" \
--data-binary '{\"body\":\"The Pipeline ${PIPELINE_STATUS} \n:O\",\"connectColor\":\"#99CCFF\",\"connectInfo\":[
{\"title\":\"[[CHECK DETAIL HERE]](http://10.10.32.101/mfo/mfobuild/pipelines/${PIPELINE_NUM})\"}]}' " > jandi_api.sh
}

echo ${PIPELINE_NUM} ${PIPELINE_STATUS}

JANDI_WEBHOOK
sh jandi_api.sh
rm jandi_api.sh

