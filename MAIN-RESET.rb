#!/usr/bin/env ruby
# Encoding: utf-8

trap "SIGINT" do
	puts ""
  puts "_=Exiting=_"
  exit 130
end


#require_relative "lib/functions.rb" 
require_relative "class/mongo.class.rb" 
require_relative "class/timer.class.rb" 

require 'mongo'
include Mongo




test = Localuserrecords.new

#test.reset()
print "UNlockAll";test.unlockall()
print "UNDoneAll";test.undoneall()
