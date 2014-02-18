#!/bin/bash

#################################################################################
# Create table with links between measurement sites and road segments
#################################################################################

psql -h localhost -U postgres -d ndw -f calc_chain_direction_for_vild.sql #> /dev/null
psql -h localhost -U postgres -d ndw -f find_wvk_for_mst.sql #> /dev/null
psql -h localhost -U postgres -d ndw -f mst_wvk.sql #> /dev/null
