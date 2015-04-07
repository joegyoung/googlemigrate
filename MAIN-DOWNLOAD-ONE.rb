#!/usr/bin/env ruby
# Encoding: utf-8

require 'mongo'
include Mongo
require 'pp'



require File.dirname(__FILE__)+"/../class/google.class.rb" 
require File.dirname(__FILE__)+"/../class/mongo.class.rb" 
require File.dirname(__FILE__)+"/../class/timer.class.rb" 
require File.dirname(__FILE__)+"/../class/rocketio.class.rb" 
require File.dirname(__FILE__)+"/../class/logging.class.rb" 
require File.dirname(__FILE__)+"/../class/yaml.class.rb" 
require File.dirname(__FILE__)+"/../class/optparse.class.rb" 

#require_relative "lib/zip.rb" 

$configuration = Yamlconfig::load("../config.yml")


opts = CUIoptions::load




timer = Timer.new()
trap "SIGINT" do
  puts ""
  puts "_=Exiting=_"
  timer.stop
  exit 130
end


name = "Logger"
puts "Name:  #{name}" 




$logging = MyLogging.new(name)
#WebSocketIO = WebSocket_RocketIO.new("SOCK1") # This is in the MyLogging object
test = Localuserrecords.new

###
###

savedirectory = $configuration["savedirectory"]
numberdir = 1 
Dir.mkdir(savedirectory) unless File.exists?(savedirectory)
numberdir = Dir["#{savedirectory}/*"].length
if numberdir == 0 
  numberdir = 1
  Dir.mkdir("#{savedirectory}/#{numberdir}/") unless File.exists?("#{savedirectory}/#{numberdir}/") 
end

###



  user = <emailaddress>" # _id holds the email addres
  user = ARGV[0]
  person_object = GoogleAPI.new(user)

  puts  "Starting #{person_object.info.name.fullName}"
  $logging.log(user,"INFO","START","--- Starting")
  $logging.push("Working on #{person_object.info.name.fullName}")

  ###
  ###
  ###
  folderlength = Dir["#{savedirectory}/#{numberdir}/*"].length
  if folderlength >= 700
    numberdir += 1 
    $workingdirectory = "#{savedirectory}/#{numberdir}/"
    Dir.mkdir($workingdirectory) unless File.exists?($workingdirectory) 
   # puts "Going to next dir '#{$workingdirectory}'"
  else
     $workingdirectory = "#{savedirectory}/#{numberdir}/"
    #  puts "Staying at dir '#{$workingdirectory}'"

  end
  ###



  person_object.retrieve_files("'me' in owners")





  $logging.log(user,"INFO","END","--- Finished")

 
timer.stop



