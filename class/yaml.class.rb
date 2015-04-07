
require 'yaml'

class Yamlconfig

  def initialize
    #@start_time = Time.now()
  end
  def self.load(location)
    parsed = begin
 	data =  YAML.load(File.open(location))
	rescue ArgumentError => e
	  puts "Could not parse YAML: #{e.message}"
	end
	data
  end

end
#timer = Timer.new()
#timer.stop