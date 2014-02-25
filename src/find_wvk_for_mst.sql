-- finds one wegvak id for a given measurement site
-- input: measurement site id
-- output: 1 wegvak id
CREATE OR REPLACE FUNCTION find_wvk_for_mst(_id text)
RETURNS int
AS $$
DECLARE
meetpunt RECORD;
vildlocatie RECORD;
vildref RECORD;
paaltje RECORD;
wegvak RECORD;
wegId text;
wegDirection bool;
chainDirection text;
hLoc int;
locTcm int;
BEGIN
	select gid, location, direction, distance as offset from mst where mst_id = _id  INTO meetpunt;
	--direction = meetrichting / alertc rijrichting
	RAISE NOTICE 'gid: %, location: % measurement direction: %, offset: %', meetpunt.gid, meetpunt.location, meetpunt.direction, meetpunt.offset;
	-- 1. pak het VILD punt met alle relevante informatie
	select loc_nr, loc_type, roadnumber, hstart_pos, hstart_neg, pos_off, neg_off from vild where loc_nr = meetpunt.location INTO vildlocatie;
	
	--1a. get the chain direction
	select calc_chain_direction_for_vild(vildlocatie.loc_nr) INTO chainDirection;
	RAISE NOTICE 'chain direction: %', chainDirection;

	--1b. reformat the roadnumber so we can compare it with the wegvakken table
  	SELECT lpad(substring(vildlocatie.roadnumber from 2 for length(vildlocatie.roadnumber)), 3, '000') INTO wegId;
	RAISE NOTICE '% > %',vildlocatie.roadnumber, wegId;

	--1d. select the right hectoNumber based on the measurement direction
	SELECT vildlocatie.hstart_pos INTO hLoc;
	IF meetpunt.direction = 'negative' THEN
		SELECT vildlocatie.hstart_neg into hLoc;
	END IF;		
	RAISE NOTICE 'hloc: %', hLoc;

	--1e. adjust the measurement direction to the chain direction (t means positive, f means negative)
	SELECT (chainDirection = meetpunt.direction) into wegDirection;
	
	--2. zoek het basis hectometerpaaltje, deze is afhankelijk van de richting van het meetpunt
select * from (
	select wegvakken.wvk_id as wegvakid, wegnummer, hectomtrng, admrichtng, rijrichtng, afstand, (rijrichtng = admrichtng) as flow, beginkm, eindkm from wegvakken JOIN hectopunten ON hectopunten.wvk_id = wegvakken.wvk_id where (wegnummer = wegId OR wegnummer = vildlocatie.roadnumber) AND hectomtrng = hLoc) 
	as vakjes WHERE vakjes.flow = wegDirection OR vakjes.rijrichtng IS NULL
	INTO paaltje;
	RAISE NOTICE 'wvk_id hectometerpaal: %', paaltje.wegvakid;
	RAISE NOTICE 'rijrichtng: %, admrichtng: %', paaltje.rijrichtng, paaltje.admrichtng;

	-- 3. bereken de plek van het meetpunt als de basishectometerpaal in meters en tel daar de offset van het meetpunt bij op, als de richting met de weg mee is, tellen we het op,als het tegen de richting is trekken we het af.
	IF wegDirection = 't' THEN
		SELECT (paaltje.beginKm * 1000 + paaltje.afstand) + meetpunt.offset INTO locTcm;
	ELSE
		SELECT (paaltje.beginKm * 1000 + paaltje.afstand) - meetpunt.offset INTO locTcm;
	END IF;
	RAISE NOTICE 'locatie meetpunt op weg % in meters: %', wegId, locTcm;
	-- 4. zoek het ene wegvak waarbij de rijrichting + wegnummer hetzelfde zijn, en de loc_tcm ligt tussen beginkm en eindkm, afh van admrichting is begin groter of kleiner
	IF paaltje.admrichtng = 'H' THEN
		select wvk_id, beginkm, eindkm from wegvakken where (wegnummer = wegId OR wegnummer = vildlocatie.roadnumber) AND admrichtng = paaltje.admrichtng AND (rijrichtng = paaltje.rijrichtng OR rijrichtng IS NULL) AND locTcm BETWEEN beginkm * 1000 AND eindkm * 1000 INTO wegvak;
	ELSE
		select wvk_id, beginkm, eindkm from wegvakken where (wegnummer = wegId OR vildlocatie.roadnumber) AND admrichtng = paaltje.admrichtng AND (rijrichtng = paaltje.rijrichtng OR rijrichtng IS NULL) AND locTcm BETWEEN eindkm * 1000 AND beginkm * 1000 INTO wegvak;
	END IF;
	
	RAISE NOTICE 'beginpunt: % in eindpunt: %', wegvak.beginkm, wegvak.eindkm;
	RETURN wegvak.wvk_id;
END $$ LANGUAGE plpgsql IMMUTABLE;
