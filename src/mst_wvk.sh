#!/bin/bash

#################################################################################
# Create table with links between measurement sites and road segments
#################################################################################

psql -h $NDWDBHOST -U $NDWUSER -d ndw -f reformat_cw.sql > /dev/null
psql -h $NDWDBHOST -U $NDWUSER -d ndw -f reformat_roadnumber.sql > /dev/null
psql -h $NDWDBHOST -U $NDWUSER -d ndw -f calc_chain_direction_for_vild.sql > /dev/null
psql -h $NDWDBHOST -U $NDWUSER -d ndw -f find_wvk_for_mst.sql > /dev/null
psql -h $NDWDBHOST -U $NDWUSER -d ndw -f mst_wvk.sql > /dev/null
