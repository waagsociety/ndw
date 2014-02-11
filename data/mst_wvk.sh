#!/bin/bash

#################################################################################
# Create table with links between measurement sites and road segments
#################################################################################

psql -h localhost -U postgres -d ndw -f mst_wvk.sql > /dev/null

