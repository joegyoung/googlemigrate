#!/usr/bin/env ruby
# Encoding: utf-8

require 'mongo'
include Mongo
#require 'docx'
require 'pp'
#require 'optparse'
#require 'digest/md5'
require 'google/api_client'
require 'net/http'
require "base64"
require 'fileutils'



#require File.dirname(__FILE__)+"/test/functions.rb" 
require File.dirname(__FILE__)+"/class/google.class.rb" 
require File.dirname(__FILE__)+"/class/mongo.class.rb" 
require File.dirname(__FILE__)+"/class/timer.class.rb" 
require File.dirname(__FILE__)+"/class/rocketio.class.rb" 
require File.dirname(__FILE__)+"/class/logging.class.rb" 

require File.dirname(__FILE__)+"/class/yaml.class.rb" 
require File.dirname(__FILE__)+"/class/optparse.class.rb" 

#require_relative "lib/zip.rb" 


$configuration = Yamlconfig::load("config.yml")



opts = CUIoptions::load

name = opts[:name] || "Logger"
puts "Name:  #{name}" 




$logging = MyLogging.new(name)


timer = Timer.new()

trap "SIGINT" do
  puts ""
  puts "_=Exiting=_"
  timer.stop
  exit 130
end


trap "EXIT" do
  $logging.push("<span style='red'>I died!!!!!</span>")
  puts "@@@@@ I died!!!!!"
  $logging.log("OWNER","ERROR","LIFE","I died!!!!!")
  timer.stop
  exit 130
end


API = 'https://www.googleapis.com/auth/drive'



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

if opts[:daemon]

  #Process.daemon
  pid = Process.pid
  pp pid
  Process.daemon pid
  pid = Process.pid
  File.open("./pids/#{name}-log.txt", 'w') { |file| file.write("#{pid}") }

end

begin
  record = test.locknextundone # Get the next useraccount and lock from further access
  user = record["_id"] # _id holds the email addres
  $logging.log(record["_id"],"INFO","START","--- Starting")

  #client = build_client(user,API)
  #userfolder = "temp/" + user
  #Dir.mkdir(userfolder) unless File.exists?(userfolder)
  #save_files_in_folder(client,"ROOT",userfolder,logging)



  person_object = GoogleAPI.new(user)
  puts  "Starting #{person_object.info.name.fullName} - #{user}"

  $logging.push("Working on #{person_object.info.name.fullName} - #{user}")


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





  #io.push :chat, {:message => record["_id"], :name => name}
  #WebSocketIO.send(record["_id"])


  $logging.log(record["_id"],"INFO","END","--- Finished")

  #$logging.push(record["_id"])
  test.done(record["_id"])
  test.unlock(record["_id"])

end while test.countundone != 0 
timer.stop



