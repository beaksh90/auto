JAVASCRIPT_COMMPRESS()
{
JAVASCRIPT_MAXGAUGE_DIR="C:\Users\Vc\Desktop\Maxgauge"
WEBSRC_DIR="C:\Multi-Runner\mfoweb"
WEBOUT_DIR="C:\Multi-Runner\mfonp\deploy\mfo"

#common   ������ locale ������ ������ ��� JS
#config      ������ style ������ ������ ��� JS
#EventDescription  ���� X
#Exem       ��� �ҽ�. ���� ���� ��� JS
#Extjs       ���� X
#Images    ���� X
#Lib        ���� ���� IMXWS.js
#PA        style ������ ���� �� ��� JS
#Popup     ���� ���� app.js
#Report_download ? �ش� ����.
#RTM      style ������ ���� �� ��� JS

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