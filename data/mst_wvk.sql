-- finds one wegvak id for a given measurement site
-- input: measurement site id
-- output: 1 wegvak id

--1. voor de meetlocatie pak het VILD punt

--1b. (nog doen) kijk of het meetpunt ligt op een (gehectometriseerde) hoofdweg is of iets anders.
--2a. pak voor het VILD punt alle wegvakken die overeenkomen met het wegnummer (van het VILD punt)
--2b. voor het VILD punt pak de matching hectometerpalen  afh van de richting van het meetpunt)
--2c. maak een doorsnede (join) van de wegvakken uit 2a op wegvak id van de basis hectometerpaal
--3. we houden  1 hectometerpaal over (kunnen verifieren of het een van de max 4 is)
--4. dan tel je de offset gespecificeerd in de meetlocatie op bij het hectometer paaltje.
--5. dan pak je het het ene wegvak waarbinnen de berekende locatie valt.

CREATE OR REPLACE FUNCTION mst2wvk(_id text) 
RETURNS  int
AS $$
BEGIN
  RETURN (
    SELECT 
      wv.wvk_id::int
    FROM mst m 
    JOIN tmcpoints
    ON loc_nr = m.location
    JOIN vild v
    ON m.location = v.loc_nr
    JOIN wegvakken wv2
    ON lpad(substring(roadnumber from 2 for length(roadnumber)), 3, '000') = wegnummer
    JOIN hectopunten hp
    ON (
      CASE direction WHEN 'positive' THEN hp.hectomtrng = hstart_pos
                     WHEN 'negative' THEN hp.hectomtrng = hstart_neg
      END
    ) 
    AND hp.wvk_id = wv2.wvk_id
    JOIN wegvakken wv
    ON wv.wegnummer = wv2.wegnummer
    WHERE 
    wv.rijrichtng = wv2.rijrichtng
    AND
    wv.rpe_code = wv2.rpe_code
    AND (
      CASE wv.rpe_code WHEN 'R' 
      THEN wv2.beginkm * 1000 + afstand + distance * (CASE wv.rijrichtng WHEN 'H' THEN 1 ELSE -1 END) BETWEEN wv.beginkm * 1000 AND wv.eindkm * 1000
      ELSE wv2.beginkm * 1000 + afstand - distance * (CASE wv.rijrichtng WHEN 'H' THEN 1 ELSE -1 END) BETWEEN wv.eindkm * 1000 AND wv.beginkm * 1000
      END
    ) AND        
    m.mst_id = _id
    LIMIT 1
  );
END $$ LANGUAGE plpgsql IMMUTABLE;

DROP TABLE mst_wvk CASCADE;

CREATE TABLE mst_wvk AS
  SELECT * FROM (
    SELECT mst_id, mst2wvk(mst_id) AS wvk_id FROM mst
  ) c 
  WHERE c IS NOT NULL;

CREATE INDEX ON mst_wvk USING btree(mst_id);
CREATE INDEX ON mst_wvk USING btree(wvk_id);
