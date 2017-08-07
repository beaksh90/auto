#!/bin/bash

PSQL_PATH=/home/maxgauge/pgsql/bin

$PSQL_PATH/psql --host 127.0.0.1 --port 5432 --username postgres -d MFO -f age_check.sql >> age_check.log
