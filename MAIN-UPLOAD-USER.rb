#!/usr/bin/env ruby
# Encoding: utf-8

#exit;

require 'mongo'
include Mongo

require 'pp'


require File.dirname(__FILE__)+"/lib/functions.rb" 
require File.dirname(__FILE__)+"/class/mongo.class.rb" 
require File.dirname(__FILE__)+"/class/timer.class.rb" 
require File.dirname(__FILE__)+"/class/rocketio.class.rb" 
require File.dirname(__FILE__)+"/class/logging.class.rb" 
require File.dirname(__FILE__)+"/class/google.class.rb" 
require File.dirname(__FILE__)+"/class/yaml.class.rb" 
require File.dirname(__FILE__)+"/class/optparse.class.rb" 


$configuration = Yamlconfig::load("config.yml")
opts = CUIoptions::load



name = opts[:name] || "Logger"
puts "Name:  #{name}" 




$logging = MyLogging.new(name)

$logging.newwebsocket("upload")


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



###

if opts[:daemon]

  #Process.daemon
  pid = Process.pid
  pp pid
  Process.daemon pid
  pid = Process.pid
  File.open("./pids/#{name}-log.txt", 'w') { |file| file.write("#{pid}") }

end







listofFiles = FileAccount.new(name)
#listofFiles.unlockall
#listofFiles.undoneallbyemail("<emailaddress>")


begin
    onefile =  listofFiles.locknextundone
    if onefile
    pp onefile['emailaddress']

      $logging.push("Working on <b>#{onefile['title']}</b> of #{onefile['emailaddress']}")



    puts "#{onefile['title']}, description, #{onefile['orginalfiletype']}, #{onefile['filelocation']}"

    file = GoogleFileAPI.new([onefile['emailaddress']])
    uploaded = file.insert_o(onefile['title'], "description", onefile['orginalfiletype'], onefile['filelocation'])


    listofFiles.done(onefile['_id'])
    listofFiles.unlock(onefile['_id'])
    end
end while listofFiles.countundone != 0 
timer.stop



