JANDI_WEBHOOK ()
{
echo "
curl \
-X POST ${JANDI_API_KEY} \
-H \"Accept: application/vnd.tosslab.jandi-v2+json\" \
-H \"Content-Type: application/json\" \
--data-binary '{\"body\":\"The Pipeline ${PIPELINE_STATUS} \n:O\",\"connectColor\":\"#99CCFF\",\"connectInfo\":[
{\"title\":\"[[CHECK DETAIL HERE]](http://10.10.32.101/${REQURIER_GROUP}/${REQURIER_GROUP}build/pipelines/${PIPELINE_NUM})\"}]}' " > jandi_api.sh
}

echo ${PIPELINE_NUM} ${PIPELINE_STATUS}

JANDI_WEBHOOK
sh jandi_api.sh
rm jandi_api.sh

