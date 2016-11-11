PG_ROOT_HOME="C:/Database"
PG_HOME="C:/Multi-Runner/mfobuild/07_build_mfopg"
DGSERVER_M_HOME="C:/Multi-Runner/mfodg/deploy/MFO/tar/DGServer_M"
${PG_HOME}/install_pg94101.bat
##${PG_HOME}/install_pg9611.bat
cd ${DGSERVER_M_HOME}/bin
echo -e "1\n0\n" | java -jar DGServer.jar install
cp -a ${PG_HOME}/pg94101/pgadmin3 $PG_ROOT_HOME/
sc stop PostgreSQL