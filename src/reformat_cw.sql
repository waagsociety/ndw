CREATE OR REPLACE FUNCTION reformat_cw(_cw text)
RETURNS text
AS $$
DECLARE cw text;
BEGIN
	CASE
		WHEN _cw = 'mainCarriageway' THEN cw = 'HR';
		WHEN _cw = 'parallelCarriageway' THEN cw = 'VBR';
		WHEN _cw = 'entrySlipRoad' THEN cw = 'OPR';
		WHEN _cw = 'exitSlipRoad' THEN cw = 'AFR';
		WHEN _cw = 'connectingCarriageway' THEN cw = 'VBD';
		ELSE cw = NULL;
	END CASE;

	IF cw IS NULL THEN
		RAISE NOTICE 'unknown carriageway type: %', _cw;
	END IF;

	RETURN cw;
END $$ LANGUAGE plpgsql IMMUTABLE;
