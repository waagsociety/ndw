DROP TABLE IF EXISTS "mst";
CREATE TABLE "mst" (
  gid serial,
  "mst_id" text,
  "name" text,
  "location" int,
  "carriageway" text,
  "direction" text,
  "distance" double precision,
  "method" text,
  "equipment" text,
  "lanes" int,
  "characteristics" json
);
ALTER TABLE "mst" ADD PRIMARY KEY (gid);
SELECT AddGeometryColumn('','mst','geom','4326','POINT',2);