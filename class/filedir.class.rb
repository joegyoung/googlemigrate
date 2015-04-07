
class Filedirectory

    def initialize()

    end

	def self.count(location)
		Dir[File.join(location, '**', '*')].count { |file| File.file?(file) }
	end

end


#require 'pp'
#pp Filedirectory::count ""