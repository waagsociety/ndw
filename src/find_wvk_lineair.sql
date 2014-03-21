-- find a wegvak using dynamic segmentation for the given (vild)location, carriageway, offset and direction
CREATE OR REPLACE FUNCTION find_wvk_lineair(_location int, _offset double precision, _direction text, _carriageway text)
RETURNS int
AS $$
DECLARE
vildlocatie RECORD;
relativeTrafficDirection bool;
cw text;
roadNumber text;
base RECORD;
hLoc int;
linPos int;
wegvak RECORD;
BEGIN
	select loc_nr, loc_type, vild.roadnumber, hstart_pos, hstart_neg, pos_off, neg_off from vild where loc_nr = _location INTO vildlocatie;

	--1a. calculate the relative traffic direction and reformat roadnumber for comparison
	SELECT ((SELECT calc_chain_direction_for_vild(vildlocatie.loc_nr)) = _direction) into relativeTrafficDirection;
  	SELECT reformat_roadnumber(vildlocatie.roadnumber) INTO roadNumber;
	SELECT reformat_cw(_carriageway) INTO cw;

	--1d. select the base hectoNumber based on the measurement direction
	SELECT vildlocatie.hstart_pos INTO hLoc;
	IF _direction = 'negative' THEN
		SELECT vildlocatie.hstart_neg into hLoc;
	END IF;		
	
	--2.find the hecto base position, taking rijrichting into account if applicable, should always be a maincarriageway.
	select * from (
		select wegvakken.wvk_id as wegvakid, wegnummer, hectomtrng, admrichtng, rijrichtng, afstand, baansubsrt, (rijrichtng = admrichtng) as flow, beginkm, eindkm from wegvakken JOIN hectopunten ON hectopunten.wvk_id = wegvakken.wvk_id where wegnummer = roadNumber AND hectomtrng = hLoc
	) 
	as vakjes WHERE (vakjes.flow = relativeTrafficDirection OR vakjes.rijrichtng IS NULL) AND vakjes.baansubsrt = 'HR'
	INTO base;
	--RAISE NOTICE 'wvk_id hectometerpaal: %', base.wegvakid;
	--RAISE NOTICE 'rijrichtng: %, admrichtng: %', base.rijrichtng, base.admrichtng;
	--RAISE NOTICE 'relative direction %', relativeTrafficDirection;

	--3. apply offset, disregard trafic direction if connecting or parralelcarriageway
	IF relativeTrafficDirection = 't' OR cw = 'VBR' OR cw = 'VBD' THEN
		SELECT (base.beginKm * 1000 + base.afstand) + _offset INTO linPos;
	ELSE
		SELECT (base.beginKm * 1000 + base.afstand) - _offset INTO linPos;
	END IF;

	--4. calculate appropriate wegvak based on linearPosition, disregard traffic direction if parralelcarriageway
	IF base.admrichtng = 'H' THEN
		select wvk_id, beginkm, eindkm, baansubsrt from wegvakken where (wegnummer = roadNumber) AND baansubsrt = cw AND admrichtng = base.admrichtng AND (rijrichtng = base.rijrichtng OR rijrichtng IS NULL OR cw = 'VBR') AND linPos BETWEEN beginkm * 1000 AND eindkm * 1000 INTO wegvak;
	ELSE
		select wvk_id, beginkm, eindkm, baansubsrt from wegvakken where (wegnummer = roadNumber) AND baansubsrt = cw AND admrichtng = base.admrichtng AND (rijrichtng = base.rijrichtng OR rijrichtng IS NULL OR cw = 'VBR') AND linPos BETWEEN eindkm * 1000 AND beginkm * 1000 INTO wegvak;
	END IF;

	--special treatment for connecting carriageways apparently, find the closest
	IF cw = 'VBD' AND wegvak IS NULL THEN
		select wvk_id, (abs(eindkm * 1000 - locTcm)) as distance, beginkm, eindkm, baansubsrt from wegvakken where (wegnummer = roadNumber) AND baansubsrt = cw ORDER BY distance LIMIT 1 INTO wegvak;
	END IF;

	RETURN wegvak.wvk_id;
END $$ LANGUAGE plpgsql IMMUTABLE;
