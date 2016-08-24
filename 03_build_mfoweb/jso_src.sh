JAVASCRIPT_COMMPRESS()
{
JAVASCRIPT_MAXGAUGE_DIR="C:\Users\Vc\Desktop\Maxgauge"
WEBSRC_DIR="C:\Multi-Runner\mfoweb"
WEBOUT_DIR="C:\Multi-Runner\mfonp\deploy\mfo"

#common   내부의 locale 폴더를 제외한 모든 JS
#config      내부의 style 폴더를 제외한 모든 JS
#EventDescription  압축 X
#Exem       모든 소스. 각각 폴더 모든 JS
#Extjs       압축 X
#Images    압축 X
#Lib        폴더 안의 IMXWS.js
#PA        style 폴더를 제외 한 모든 JS
#Popup     폴더 안의 app.js
#Report_download ? 해당 없음.
#RTM      style 폴더를 제외 한 모든 JS

# Cannot use array, cause too low bash version.

DIR="$JAVASCRIPT_MAXGAUGE_DIR"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\common"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\config"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\config\\view"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\Exem "
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\Exem\\chart"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\Exem\\config"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\PA"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\PA\\container"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\PA\\view"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\popup"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM\\Frame"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM\\tools"
DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM\\view"

#ls $JAVASCRIPT_MAXGAUGE_DIR\\lib\\IMXWS.js
for DIR_PRE in ${DIR}
	do
	cd $DIR_PRE; 
		for APP in `ls | grep \.js | grep -v extjs`;
		do
			APP_DIR=$DIR_PRE\\${APP}
			echo $APP_DIR
			jso -s -c $APP_DIR;
			unset APP_DIR;
		done
done

jso -s -c $JAVASCRIPT_MAXGAUGE_DIR\\lib\\IMXWS.js
}

JAVASCRIPT_COMMPRESS