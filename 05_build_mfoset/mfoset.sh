echo "ready to finish"
NPSRC_DIR="C:\Multi-Runner\mfonp"
WEBSRC_DIR="C:\Multi-Runner\mfoweb"
SQLSRC_DIR="C:\Multi-Runner\mfosql"
DGSRC_DIR="C:\Multi-Runner\mfodg"
BUILD_DIR="C:\Multi-Runner\mfobuild"

# cd $SQLSRC_DIR
# git pull git@10.10.202.196:mfo/mfosql.git MFO5.3
# cd $WEBSRC_DIR
# git pull git@10.10.202.196:mfo/mfoweb.git 5.3.2_July
# cd $NPSRC_DIR
# git pull git@10.10.202.196:mfo/mfonp.git master
# cd $DGSRC_DIR
# git pull git@10.10.202.196:mfo/mfodg.git master
# cd $BUILD_DIR
# git pull git@10.10.202.196:mfo/mfobuild.git master


sh $BUILD_DIR/01_build_mfodg/A_dgbuild.sh
sh $BUILD_DIR/02_build_mfonp/npbuild.sh
sh $BUILD_DIR/05_build_mfoset/Innosetup.sh
