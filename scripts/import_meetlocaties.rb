#import zone prices from xml file
require 'xml'
require 'json'

$docstream = XML::Reader.file './data/meetlocaties.xml'


puts "{\n \"type\": \"FeatureCollection\",\n\"features: ["

def readAttributeForElement el, name
	while not ($docstream.node_type == XML::Reader::TYPE_ELEMENT && $docstream.name == el)
		$docstream.read
	end
	val = $docstream.get_attribute(name)
	return val
end

def readValueForElement el
	while not ($docstream.node_type == XML::Reader::TYPE_ELEMENT && $docstream.name == el)
		$docstream.read
	end

	if(el == "offsetDistance") #nested
		$docstream.read
		$docstream.read
	end
	
	val = $docstream.read_inner_xml
	return val
end

while $docstream.next
	id = readAttributeForElement "measurementSiteRecord", "id"
	latitude = readValueForElement "latitude"
	longitude = readValueForElement "longitude" 
	cw = readValueForElement "carriageway"
	direction = readValueForElement "alertCDirectionCoded"
	location = readValueForElement "specificLocation"
	distance = readValueForElement "offsetDistance"
	
	data = 
	{
		:type => "Feature",
		:properties => 
		{
			:id => id,
			:cw => cw,
			:direction => direction,
			:location => location.to_i,
			:distance => distance.to_i
		},
		:geometry =>
		{
			:type => "Point",
			:coordinates => [longitude.to_f,latitude.to_f]
		}
	}

	puts "#{data.to_json},"
end
