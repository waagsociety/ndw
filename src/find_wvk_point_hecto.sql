-- expects hectomtrng as number & point as geometry for example: 
-- ST_SetSRID(ST_Point(-71.1043443253471, 42.3150676015829),4326)
CREATE OR REPLACE FUNCTION find_wvk_point_hecto(_hectomtrng double precision,_point GEOMETRY)
RETURNS int
AS $$
DECLARE
hectopunt RECORD;

BEGIN
	select hectopunten.wvk_id, _hectomtrng, (hectopunten.geom <-> _point) as diff from hectopunten where hectomtrng = _hectomtrng ORDER BY diff LIMIT 1 INTO hectopunt;
	
	RETURN hectopunt.wvk_id;

END $$ LANGUAGE plpgsql IMMUTABLE;
