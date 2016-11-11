
####################################################################
#########            Copyright 2016 BigSQL               ###########
####################################################################

import os
import util

PGC_HOME = os.getenv('PGC_HOME', '')
dir_name = os.path.join(PGC_HOME, 'pgadmin3')

if util.get_platform() == "Windows":

    short_link = "pgAdmin3 LTS by BigSQL.lnk"
    target_link = os.path.join(dir_name, "bin", "pgAdmin3.exe")
    link_desc = "pgAdmin3 LTS by BigSQL"
    # create short link for Exe
    util.create_short_link_windows(short_link, target_link, link_desc)

    # create short link for Documentation
    documentation_short_link = "pgAdmin3 Documentation.lnk"
    documentation_target_link = os.path.join(dir_name, "pgAdmin III", "docs", "en_US", "pgadmin3.chm")
    util.create_short_link_windows(documentation_short_link, documentation_target_link, link_desc)

elif util.get_platform() == "Darwin":
    short_link = "pgAdmin3 LTS by BigSQL.app"
    target_link = os.path.join(dir_name, "pgAdmin3.app")
    util.create_shortlink_osx(short_link, target_link)
