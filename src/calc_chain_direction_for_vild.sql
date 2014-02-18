-- calculate the chain direction for a VILD location
-- this is the direction of the VILD chain relative to the administrative direction of the road
CREATE OR REPLACE FUNCTION calc_chain_direction_for_vild(_loc_nr int)
RETURNS text 
AS $$
DECLARE

vildlocatie RECORD;
vildref RECORD;
chainDirection text;

BEGIN

	--get the VILD location for which we want the direction calculated
	select loc_nr, loc_type, roadnumber, hstart_pos, hstart_neg, pos_off, neg_off from vild where loc_nr = _loc_nr INTO vildlocatie;
	
	--get the reference VILD location (positive or negative if positive not available)
	IF vildlocatie.pos_off > -1 THEN
		select hstart_pos, hstart_neg from vild where loc_nr = vildlocatie.pos_off INTO vildref;
		
		IF vildlocatie.hstart_pos > -1 AND vildref.hstart_pos > -1 THEN
			IF vildlocatie.hstart_pos < vildref.hstart_pos THEN
				select 'positive' INTO chainDirection;
			ELSE
				select 'negative' INTO chainDirection;
			END IF;
		ELSE
			IF vildlocatie.hend_pos > -1 AND vildref.hend_pos > -1 THEN
				IF vildlocatie.hend_pos < vildref.hend_pos THEN
					select 'positive' INTO chainDirection;
				ELSE
					select 'negative' INTO chainDirection;
				END IF;
			END IF;
		END IF;
	ELSE	
		-- calculate from negative
		IF vildlocatie.neg_off > -1 THEN
			select hstart_pos, hstart_neg from vild where loc.nr = vildlocatie.neg_off INTO vildref;
			IF vildlocatie.hstart_pos > -1 AND vildref.hstart_pos > -1 THEN
				IF vildlocatie.hstart_pos < vildref.hstart_pos THEN
					select 'negative' INTO chainDirection;
				ELSE
					select 'positive' INTO chainDirection;
				END IF;
			ELSE
				IF vildlocatie.hend_pos > -1 AND vildref.hend_pos > -1 THEN
					IF vildlocatie.hend_pos < vildref.hend_pos THEN
						select 'negative' INTO chainDirection;
					ELSE
						select 'positive' INTO chainDirection;
					END IF;
				END IF;
			END IF;
		END IF;
	
	END IF;

	return chainDirection;

END $$ LANGUAGE plpgsql IMMUTABLE;
