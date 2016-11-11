
####################################################################
#########            Copyright 2016 BigSQL               ###########
####################################################################

import os
import util

PGC_HOME = os.getenv('PGC_HOME', '')
dir_name = os.path.join(PGC_HOME, 'pgadmin3')

if util.get_platform() == "Windows":

    util.delete_shortlink_windows("pgAdmin3 LTS by BigSQL.lnk")
    util.delete_shortlink_windows("pgAdmin3 Documentation.lnk")

elif util.get_platform() == "Darwin":

    short_link = "pgAdmin3 LTS by BigSQL.app"
    util.delete_shortlink_osx(short_link)
