#!/usr/bin/env ruby
# Encoding: utf-8
require 'mongo'
include Mongo
require 'google/api_client'
require 'net/http'
require "base64"
require 'fileutils'


trap "SIGINT" do
	puts ""
  puts "_=Exiting=_"
  exit 130
end

require File.dirname(__FILE__)+"/class/google.class.rb" 
require File.dirname(__FILE__)+"/class/mongo.class.rb" 
require File.dirname(__FILE__)+"/class/timer.class.rb" 
require File.dirname(__FILE__)+"/class/rocketio.class.rb" 
require File.dirname(__FILE__)+"/class/logging.class.rb" 

require File.dirname(__FILE__)+"/class/yaml.class.rb" 






$configuration = Yamlconfig::load("config.yml")




test = Localuserrecords.new




#test.reset()
#test.undoneall()
#exit







     person_object = GoogleAPI.new($configuration["googleadminuser"])
     users = person_object.list_users( $configuration["domain"] )

    users.sort.each do |user|
      puts user
      test.add(user)
    end



#test.lock("<emailaddress>")





#puts " Amount of email addresses #{test.counttotal}"
#puts " Amount Undone #{test.countundone}"




