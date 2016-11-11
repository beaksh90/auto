
####################################################################
#########            Copyright 2016 BigSQL               ###########
####################################################################

import os
import sys
import util
import tempfile

PGC_HOME = os.getenv('PGC_HOME', '')
dir_name = os.path.join(PGC_HOME, 'pgadmin3')

print "Starting pgAdmin III..."
logfile=tempfile.gettempdir() + os.sep + "pgadmin3.log"
print "  logging to: " + logfile

if util.get_platform() == "Windows":
  pgadmin3=dir_name + os.sep + "bin" + os.sep + "pgAdmin3.exe"
  util.system(pgadmin3 + " > " + logfile + " 2>&1")

if util.get_platform() == "Darwin":
  pgadmin3=dir_name + os.sep + "pgAdmin3.app/Contents/MacOS/pgAdmin3"
  os.system(pgadmin3 + " > " + logfile + " 2>&1 &")

sys.exit(0)
