-- returns all wegvakken between a given wegvak and a hectoposition on the same road
CREATE OR REPLACE FUNCTION wvk_for_waypoint(_wvk_start int,_hectopos double precision)
RETURNS SETOF numeric 
AS $$
DECLARE
wegvak RECORD;
wegvak_end RECORD;

BEGIN
	--Get base wegvak
	select * from wegvakken where wvk_id = _wvk_start INTO wegvak;

	--Get end wegvak
	IF wegvak.admrichtng = 'H' THEN
		select * from wegvakken where wegnummer = wegvak.wegnummer AND wegdeelltr = wegvak.wegdeelltr AND admrichtng = wegvak.admrichtng AND rijrichtng = wegvak.rijrichtng AND baansubsrt = wegvak.baansubsrt AND _hectopos BETWEEN beginkm and eindkm INTO wegvak_end;
	ELSE
		select * from wegvakken where wegnummer = wegvak.wegnummer AND wegdeelltr = wegvak.wegdeelltr AND admrichtng = wegvak.admrichtng AND rijrichtng = wegvak.rijrichtng AND baansubsrt = wegvak.baansubsrt AND _hectopos BETWEEN eindkm and beginkm INTO wegvak_end;

	END IF;	
	RAISE NOTICE 'wvk_id end: %', wegvak_end.wvk_id;
	
	--Get everything in between
	IF wegvak.beginkm < wegvak_end.beginkm THEN	
		RETURN QUERY(
			SELECT wvk_id from wegvakken where wegnummer = wegvak.wegnummer AND wegdeelltr = wegvak.wegdeelltr AND admrichtng = wegvak.admrichtng AND rijrichtng = wegvak.rijrichtng AND baansubsrt = wegvak.baansubsrt AND beginkm >= wegvak.beginkm AND eindkm <= wegvak_end.eindkm ORDER BY beginkm
		);
	ELSE
		RETURN QUERY(
			SELECT wvk_id from wegvakken where wegnummer = wegvak.wegnummer AND wegdeelltr = wegvak.wegdeelltr AND admrichtng = wegvak.admrichtng AND rijrichtng = wegvak.rijrichtng AND baansubsrt = wegvak.baansubsrt AND beginkm >= wegvak_end.beginkm AND eindkm <= wegvak.eindkm ORDER BY beginkm
		);
	END IF;

END $$ LANGUAGE plpgsql IMMUTABLE;
