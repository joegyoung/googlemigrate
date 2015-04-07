
require 'optparse'

class CUIoptions

  def initialize
    #@start_time = Time.now()
  end
  def self.load
      options = {}
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: MAIN-SCRIPT.rb [options]"
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
        options[:name] = nil
        opts.on( '-n', '--name FILE', 'Write log to FILE' ) do|name|
             options[:name] = name
        end

        options[:daemon] = nil
        opts.on( '-d', '--daemonize', 'Write log to FILE' ) do|v|
             options[:daemon] = v
        end



        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end # end.parse!


      begin opts.parse! ARGV
      rescue OptionParser::InvalidOption => e
        puts e
        puts opts
        exit 1
      end
      options
  end



end
#timer = Timer.new()
#timer.stop