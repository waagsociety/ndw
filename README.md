# Linking NDW and NWB

## Software prerequisites:

Install PostgreSQL/PostGIS, Ruby, Ruby gems:

    brew install postgis
    brew install ruby
    
    gem install sequel
    gem install ox
 
Create database `ndw`, install PostGIS extension: `CREATE EXTENSION postgis;`  

Download data, convert to shapefiles, import into database:

    cd data
    ./create_tables.sh    

## Example queries

Find out which field to use: `admrichtng`, `rpe_code`, or `pos_tv_wol`.  
  
    
    CREATE TYPE wvktype AS (wvk_id int);

    CREATE OR REPLACE FUNCTION mst2wegvak(_id text) 
    RETURNS SETOF wvktype
    AS $$
    BEGIN
      RETURN QUERY        
        SELECT DISTINCT
          wv.wvk_id::int
        FROM mst m 
        JOIN tmcpoints
        ON loc_nr = m.location
        JOIN vild v
        ON m.location = v.loc_nr
        JOIN wegvakken wv2
        ON lpad(substring(roadnumber from 2 for length(roadnumber)), 3, '000') = wegnummer
        JOIN hectopunten hp
        ON (
          CASE direction WHEN 'positive' THEN hp.hectomtrng = hstart_pos
                         WHEN 'negative' THEN hp.hectomtrng = hstart_neg
          END
        ) 
        AND hp.wvk_id = wv2.wvk_id
        JOIN wegvakken wv
        ON wv.wegnummer = wv2.wegnummer
        WHERE 
        wv.rijrichtng = wv2.rijrichtng
        AND
        wv.rpe_code = wv2.rpe_code
        AND (
          CASE wv.rpe_code WHEN 'R' 
          THEN wv2.beginkm * 1000 + afstand + distance * (CASE wv.rijrichtng WHEN 'H' THEN 1 ELSE -1 END) BETWEEN wv.beginkm * 1000 AND wv.eindkm * 1000
          ELSE wv2.beginkm * 1000 + afstand - distance * (CASE wv.rijrichtng WHEN 'H' THEN 1 ELSE -1 END) BETWEEN wv.eindkm * 1000 AND wv.beginkm * 1000
          END
        ) AND        
        m.mst_id = _id;
    END $$ LANGUAGE plpgsql IMMUTABLE;
      
    SELECT * FROM mst2wegvak('RWS01_MONIBAS_0271hrl0261ra');


    
   
