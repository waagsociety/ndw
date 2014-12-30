#!/bin/bash

#################################################################################
# Create table with links between measurement sites and road segments
#################################################################################

psql -h $NDWDBHOST -U $NDWUSER -d ndw -f mst_wvk.sql > /dev/null

