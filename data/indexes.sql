-- PostgreSQL indexes
CREATE INDEX ON hectopunten USING btree(wvk_id);
CREATE INDEX ON hectopunten USING btree(hectomtrng);
CREATE INDEX ON mst USING btree(location);
CREATE INDEX ON mst USING btree(id);
CREATE INDEX ON tmcpoints USING btree(loc_nr);
CREATE INDEX ON vild USING btree(loc_nr);
CREATE INDEX ON wegvakken USING btree(wvk_id);
CREATE INDEX ON wegvakken USING btree(wegnummer);
CREATE INDEX ON wegvakken USING btree(baansubsrt);
CREATE INDEX ON wegvakken USING btree(rijrichtng);