require 'stringio'
require 'zlib'
require 'json'
require 'ox'

file = Zlib::GzipReader.open('tmp/measurement.gz')

class MST2GeoJSON < ::Ox::Sax
  
  def initialize    
    @data = {}
    @first = true  
    @elements = []
    puts "{\n \"type\": \"FeatureCollection\",\n\"features\": ["
  end
    
  def start_element(name)
    @elements << name
  end
  
  def end_element(name)
    @elements.pop
    if name == :measurementSiteRecord
      puts ",\n" if not @first      
      @first = false
      
      feature = {
    		:type => "Feature",
    		:properties => {
    		  id: @data[:id],     
    		  name: @data[:name],
          location: @data[:location],
          carriagewy: @data[:carriageway],
          direction: @data[:direction],
          distance: @data[:distance]   
    		},
    		:geometry =>
    		{
    			:type => "Point",
    			:coordinates => [
    			  @data[:longitude],
            @data[:latitude]
    			]
    		}
    	}      
      puts feature.to_json
      
      @data = {}      
    end
    
    if @elements.length == 0
      puts "]}"
    end
    
  end
  
  def attr(name, value)
    case @elements[-1]
    when :measurementSiteRecord
      if name == :id
        @data[:id] = value
      end
    end
  end
  
  def text(value)
    case @elements[-1]
    when :specificLocation 
      @data[:location] = value.to_i
    when :latitude
      if @elements.include? :locationForDisplay
        @data[:latitude] = value.to_f
      end
    when :longitude      
      if @elements.include? :locationForDisplay
        @data[:longitude] = value.to_f        
      end
    when :value
      if @elements.include? :measurementSiteName
        @data[:name] = value
      end
    when :carriageway
      @data[:carriageway] = value
    when :alertCDirectionCoded
      @data[:direction] = value      
    when :offsetDistance      
      @data[:distance] = value.to_i
    end

  end
  
end

handler = MST2GeoJSON.new
Ox.sax_parse(handler, file)
