CREATE TABLE mst_wvk AS
  SELECT * FROM (
    SELECT mst_id, mst2wegvak(mst_id) AS wvk_id FROM mst
  ) c 
  WHERE c IS NOT NULL;

CREATE INDEX ON mst_wvk USING btree(mst_id);
CREATE INDEX ON mst_wvk USING btree(wvk_id);