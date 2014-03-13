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
roadNumber text;
relativeTrafficDirection bool;
chainDirection text;
hLoc int;
locTcm int;
cw text;

BEGIN
	select gid, location, direction,  carriageway, distance as offset from mst where mst_id = _id  INTO meetpunt;
	RAISE NOTICE 'gid: %, location: % measurement direction: %, offset: % carriageway: %', meetpunt.gid, meetpunt.location, meetpunt.direction, meetpunt.offset, meetpunt.carriageway;
	
	-- 1. pak het VILD punt met alle relevante informatie
	select loc_nr, loc_type, vild.roadnumber, hstart_pos, hstart_neg, pos_off, neg_off from vild where loc_nr = meetpunt.location INTO vildlocatie;
	
	--1a. calculate the relative traffic direction and reformat roadnumber for comparison
	SELECT calc_chain_direction_for_vild(vildlocatie.loc_nr) INTO chainDirection;
	SELECT (chainDirection = meetpunt.direction) into relativeTrafficDirection;
  	SELECT reformat_roadnumber(vildlocatie.roadnumber) INTO roadNumber;
	SELECT reformat_cw(meetpunt.carriageway) INTO cw;
	--1d. select the base hectoNumber based on the measurement direction
	SELECT vildlocatie.hstart_pos INTO hLoc;
	IF meetpunt.direction = 'negative' THEN
		SELECT vildlocatie.hstart_neg into hLoc;
	END IF;		
	--2.find the hecto base position, taking rijrichting into account if applicable, should always be a maincarriageway.
	select * from (
		select wegvakken.wvk_id as wegvakid, wegnummer, hectomtrng, admrichtng, rijrichtng, afstand, baansubsrt, (rijrichtng = admrichtng) as flow, beginkm, eindkm from wegvakken JOIN hectopunten ON hectopunten.wvk_id = wegvakken.wvk_id where wegnummer = roadNumber AND hectomtrng = hLoc
	) 
	as vakjes WHERE (vakjes.flow = relativeTrafficDirection OR vakjes.rijrichtng IS NULL) AND vakjes.baansubsrt = 'HR'
	INTO paaltje;
	RAISE NOTICE 'wvk_id hectometerpaal: %', paaltje.wegvakid;
	RAISE NOTICE 'rijrichtng: %, admrichtng: %', paaltje.rijrichtng, paaltje.admrichtng;
	RAISE NOTICE 'relative direction %', relativeTrafficDirection;
	-- 3. bereken de plek van het meetpunt als de basishectometerpaal in meters en tel daar de offset van het meetpunt bij op, als de richting met de weg mee is, tellen we het op,als het tegen de richting is trekken we het af.
	-- disregard trafic direction if connecting or parralelcarriageway
	IF relativeTrafficDirection = 't' OR cw = 'VBR' OR cw = 'VBD' THEN
		SELECT (paaltje.beginKm * 1000 + paaltje.afstand) + meetpunt.offset INTO locTcm;
	ELSE
		SELECT (paaltje.beginKm * 1000 + paaltje.afstand) - meetpunt.offset INTO locTcm;
	END IF;
	RAISE NOTICE 'locatie meetpunt op weg % in meters: %', roadNumber, locTcm;
	-- 4. zoek het ene wegvak waarbij de rijrichting + wegnummer hetzelfde zijn, en de loc_tcm ligt tussen beginkm en eindkm, afh van admrichting is begin groter of kleiner
	
	-- disregard traffic direction if parralelcarriageway
	IF paaltje.admrichtng = 'H' THEN
		select wvk_id, beginkm, eindkm, baansubsrt from wegvakken where (wegnummer = roadNumber) AND baansubsrt = cw AND admrichtng = paaltje.admrichtng AND (rijrichtng = paaltje.rijrichtng OR rijrichtng IS NULL OR cw = 'VBR') AND locTcm BETWEEN beginkm * 1000 AND eindkm * 1000 INTO wegvak;
	ELSE
		select wvk_id, beginkm, eindkm, baansubsrt from wegvakken where (wegnummer = roadNumber) AND baansubsrt = cw AND admrichtng = paaltje.admrichtng AND (rijrichtng = paaltje.rijrichtng OR rijrichtng IS NULL OR cw = 'VBR') AND locTcm BETWEEN eindkm * 1000 AND beginkm * 1000 INTO wegvak;
	END IF;

	--special treatment for connecting carriageways apparently, find the closest
	IF cw = 'VBD' AND wegvak IS NULL THEN
		select wvk_id, (abs(eindkm * 1000 - locTcm)) as distance, beginkm, eindkm, baansubsrt from wegvakken where (wegnummer = roadNumber) AND baansubsrt = cw ORDER BY distance LIMIT 1 INTO wegvak;
	END IF;
	
	RAISE NOTICE 'beginpunt: % in eindpunt: %, baansubsoort: %', wegvak.beginkm, wegvak.eindkm, wegvak.baansubsrt;
	
	--if wegvak is still null, dynamic segmentation does not work, so we fall back to coordinates
	IF wegvak IS NULL THEN
		select wegvakken.wvk_id from wegvakken ORDER BY wegvakken.geom <-> (select geom from mst where mst_id = _id) LIMIT 1 INTO wegvak; 
	
	RAISE NOTICE 'Closest based on coordinates: %', wegvak.wvk_id;
	END IF;
	RETURN wegvak.wvk_id;
END $$ LANGUAGE plpgsql IMMUTABLE;
