-- finds one wegvak id for a given measurement site
-- input: measurement site id
-- output: 1 wegvak id
CREATE OR REPLACE FUNCTION find_wvk_for_mst(_id text)
RETURNS int
AS $$
DECLARE
meetpunt RECORD;
wegvak int;

BEGIN
	select location, direction,  carriageway, distance as offset, geom from mst where mst_id = _id  INTO meetpunt;
	--RAISE NOTICE 'location: % measurement direction: %, offset: % carriageway: %', meetpunt.location, meetpunt.direction, meetpunt.offset, meetpunt.carriageway;

	-- 1. find wegvak lineair, (from distance relative to vild position)	
	select find_wvk_lineair(meetpunt.location, meetpunt.offset, meetpunt.direction, meetpunt.carriageway) INTO wegvak;
	
	-- 2. if wegvak not found dynamic segmentation does not work, so we fall back to coordinates (geometry)
	IF wegvak IS NULL THEN
		select find_wvk_point(meetpunt.geom) INTO wegvak;
	END IF;
	
	RETURN wegvak;
END $$ LANGUAGE plpgsql IMMUTABLE;
