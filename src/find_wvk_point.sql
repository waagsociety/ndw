-- expects point as geometry for example: 
-- ST_SetSRID(ST_Point(-71.1043443253471, 42.3150676015829),4326)
CREATE OR REPLACE FUNCTION find_wvk_point(_point GEOMETRY)
RETURNS int
AS $$
DECLARE
wegvak int;

BEGIN
	select wegvakken.wvk_id from wegvakken ORDER BY wegvakken.geom <-> _point LIMIT 1 INTO wegvak;
	--RAISE NOTICE 'Closest based on coordinates: %', wegvak;
	RETURN wegvak;
END $$ LANGUAGE plpgsql IMMUTABLE;
