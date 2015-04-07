#!/usr/bin/env ruby
# Encoding: utf-8

require 'mongo'
include Mongo
require 'pp'
require 'optparse'

#require File.dirname(__FILE__)+"/lib/functions.rb" 
require File.dirname(__FILE__)+"/class/mongo.class.rb" 
require File.dirname(__FILE__)+"/class/timer.class.rb" 
require File.dirname(__FILE__)+"/class/rocketio.class.rb" 
require File.dirname(__FILE__)+"/class/logging.class.rb" 
require File.dirname(__FILE__)+"/class/google.class.rb" 
#require_relative "lib/zip.rb" 



timer = Timer.new()
trap "SIGINT" do
  puts ""
  puts "_=Exiting=_"
  timer.stop
  exit 130
end


###
###
###

require 'optparse'
options = {}
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: MAIN-SCRIPT.rb [options]"
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end


        options[:log2] = nil
        opts.on( '-w', '--w', 'Not log db' ) do|v|
             options[:log2] = v
        end

        options[:log] = nil
        opts.on( '-l', '--log', 'Read from log db' ) do|v|
             options[:log] = v
        end
        options[:file] = nil
        opts.on( '-f', '--file', 'Read from file db' ) do|v|
             options[:file] = v
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

###


if options[:log2]

    logrecords = LogRecords.new("checker")

    logrecords.listwarn('DESCENDING', 100).each do |log|
     puts "[#{log['time']}] #{log['user']} [#{log['level']}] #{log['event']} #{log['status']}" 
    end
    puts logrecords.count

end


if options[:log]

    logrecords = LogRecords.new("checker")

    logrecords.list('DESCENDING', 100).each do |log|
     puts "[#{log['time']}] #{log['user']} [#{log['level']}] #{log['event']} #{log['status']}"
    end
    puts logrecords.count

end

if options[:file]
    fileaccount = FileAccount.new("checker")

    fileaccount.list('DESCENDING', 100).each do |log|
     #puts log
     puts "[#{log['emailaddress']}] [#{log['title']}] #{log['filelocation']} "
    end
    puts fileaccount.counttotal()
end


timer.stop


