-- finds one wegvak id for a given measurement site
-- input: measurement site id
-- output: 1 wegvak id

CREATE OR REPLACE FUNCTION find_wvk_for_mst(_id text)
RETURNS int
AS $$
DECLARE

meetpunt RECORD;
vildlocatie RECORD;
paaltje RECORD;
wegvak RECORD;

wegId text;
wegDirection text;
hLoc int;
locTcm int;

BEGIN
	-- 0: haal het meetpunt record op, op basis van argument	
	select gid, location, direction, distance as offset from mst where mst_id = _id  INTO meetpunt;
	RAISE NOTICE 'gid: %, location: % direction: %, offset: %', meetpunt.gid, meetpunt.location, meetpunt.direction, meetpunt.offset;
	
	-- 1. pak het VILD punt met alle relevante informatie
	select loc_nr, loc_type, roadnumber, hstart_pos, hstart_neg from vild where loc_nr = meetpunt.location INTO vildlocatie;
	RAISE NOTICE 'vild road before: %', vildlocatie.roadnumber;
	
	--1b. reformat the roadnumber so we can compare it with the wegvakken table
    	select lpad(substring(vildlocatie.roadnumber from 2 for length(vildlocatie.roadnumber)), 3, '000') INTO wegId;
	RAISE NOTICE 'vild road after: %', wegId;

	--1c. reformat the direction so we can compare it with the wegvakken table
	--1d. select the right hectoNumber based on the current direction
	SELECT 'H' INTO wegDirection;
	SELECT vildlocatie.hstart_pos INTO hLoc;

	IF meetpunt.direction = 'negative' THEN
		SELECT 'T' INTO wegDirection;
		SELECT vildlocatie.hstart_neg into hLoc;
	END IF;		
	RAISE NOTICE 'wegDirection: %, hloc: %', wegDirection, hLoc;
	
	--2. zoek het basis hectometerpaaltje, deze is afhankelijk van de richting van het meetpunt 
	select wegvakken.wvk_id as wegvakid, wegnummer, hectomtrng, rijrichtng, afstand, beginkm from wegvakken JOIN hectopunten ON hectopunten.wvk_id = wegvakken.wvk_id where wegnummer = wegId AND hectomtrng = hLoc AND rijrichtng = wegDirection INTO paaltje;
	RAISE NOTICE 'wegvakid paaltje: %', paaltje.wegvakid;

	-- 3. bereken de plek van het meetpunt als de basishectometerpaal in meters en tel daar de offset van het meetpunt bij op
	IF meetpunt.direction = 'negative' THEN
		SELECT (paaltje.beginKm * 1000 + paaltje.afstand) - meetpunt.offset INTO locTcm;
	ELSE
		SELECT (paaltje.beginKm * 1000 + paaltje.afstand) + meetpunt.offset INTO locTcm;
	END IF;
	RAISE NOTICE 'locatie meetpunt op weg % in meters: %', wegId, locTcm;

	-- 4. zoek het ene wegvak waarbij de rijrichting + wegnummer hetzelfde zijn, en de loc_tcm ligt tussen beginkm en eindkm 
	select wvk_id, beginkm, eindkm from wegvakken where wegnummer = wegId AND rijrichtng = wegDirection AND locTcm BETWEEN beginkm * 1000 AND eindkm * 1000 INTO wegvak;
	
	RAISE NOTICE 'beginpunt: % in eindpunt: %', wegvak.beginkm, wegvak.eindkm;
	RETURN wegvak.wvk_id;

END $$ LANGUAGE plpgsql IMMUTABLE;
