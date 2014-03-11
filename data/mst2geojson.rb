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
    
    case @elements[-1]
    when :measurementSpecificCharacteristics
      if not @data.has_key? :characteristics
        @data[:characteristics] = []
      end      
    
      # measurementSpecificCharacteristics are nested twice:
      # <measurementSpecificCharacteristics index="n">
      #   <measurementSpecificCharacteristics>
      #     <... />
      #   </measurementSpecificCharacteristics>
      # </measurementSpecificCharacteristics>
      if not @elements[-2] == :measurementSpecificCharacteristics
        @data[:characteristics] << {}
      end 
    when :lengthCharacteristic
      if not @data[:characteristics][-1].has_key? :lengthCharacteristics
        @data[:characteristics][-1][:lengthCharacteristics] = []
      end
      @data[:characteristics][-1][:lengthCharacteristics] << {}
    end
  end
  
  def end_element(name)
    @elements.pop
    if name == :measurementSiteRecord
      puts ",\n" if not @first      
      @first = false
      
      feature = {
    		:type => "Feature",
    		:properties => {
    		  mst_id: @data[:mst_id],     
    		  name: @data[:name],
          location: @data[:location],
          carriageway: @data[:carriageway],
          direction: @data[:direction],
          distance: @data[:distance],
          method: @data[:method],
          equipment: @data[:equipment],
          lanes: @data[:lanes],
          characteristics: @data[:characteristics]
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
        @data[:mst_id] = value
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
      elsif @elements.include? :measurementEquipmentTypeUsed
        @data[:equipment] = value
      end
    when :carriageway
      @data[:carriageway] = value
    when :alertCDirectionCoded
      @data[:direction] = value      
    when :offsetDistance      
      @data[:distance] = value.to_i
    when :measurementSiteNumberOfLanes
      @data[:lanes] = value.to_i
    when :computationMethod
      @data[:method] = value      
    when :accuracy
      @data[:characteristics][-1][:accuracy] = value.to_f
    when :period
      @data[:characteristics][-1][:period] = value.to_f           
    when :specificLane
      @data[:characteristics][-1][:lane] = value[4..-1].to_i
    when :specificMeasurementValueType
      @data[:characteristics][-1][:type] = (value == "trafficSpeed") ? "speed" : "flow"
    when :vehicleType
      @data[:characteristics][-1][:vehicleType] = value
    when :comparisonOperator
      operator = value
      case value
      when "greaterThan"
        operator = ">"
      when "greaterThanOrEqualTo"
        operator = ">="
      when "lessThan"
        operator = "<"        
      when "lessThanOrEqualTo"
        operator = "<="
      end
      @data[:characteristics][-1][:lengthCharacteristics][-1][:operator] = operator
    when :vehicleLength
      @data[:characteristics][-1][:lengthCharacteristics][-1][:length] = value.to_i
    end

  end
  
end

handler = MST2GeoJSON.new
Ox.sax_parse(handler, file)
