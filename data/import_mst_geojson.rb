require 'json'
require 'sequel'

DB = Sequel.connect("postgres://postgres:postgres@localhost/ndw")

INSERT = <<-SQL
INSERT INTO mst (mst_id, name, location, carriageway, direction, distance, method, equipment, lanes, characteristics, geom) VALUES
SQL

filename = ARGV.first
if not filename or filename.length == 0
  puts "Please provide path to mst.geojson"
  exit
end

rows = []
geojson = JSON.parse(File.read(filename), {:symbolize_names => true})
geojson[:features].each do |feature|
  p = feature[:properties]
  
  rows << {
    mst_id: p[:mst_id],
    name: p[:name],
    location: p[:location],
    carriageway: p[:carriageway],
    direction: p[:direction],
    distance: p[:distance],
    method: p[:method],
    equipment: p[:equipment],
    lanes: p[:lanes],
    characteristics: p[:characteristics].to_json,
    geom: Sequel.function(:ST_SetSRID, Sequel.function(:ST_GeomFromGeoJSON, feature[:geometry].to_json), 4326)
  }

  if rows.length > 500  
    DB[:mst].multi_insert(rows)
    rows = []
  end
  
end
DB[:mst].multi_insert(rows)
