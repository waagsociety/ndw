CREATE OR REPLACE FUNCTION reformat_roadnumber(_roadnumber text)
RETURNS text
AS $$
DECLARE roadnumber text;
BEGIN
	IF(substring(_roadnumber from 1 for 1) = 'A') THEN
  		SELECT lpad(substring(_roadnumber from 2 for length(_roadnumber)), 3, '000') INTO roadnumber;
	ELSE
		SELECT _roadnumber INTO roadnumber;
	END IF;	

	RETURN roadnumber;
END $$ LANGUAGE plpgsql IMMUTABLE;
