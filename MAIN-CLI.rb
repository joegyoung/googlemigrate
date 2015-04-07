#!/usr/bin/env ruby
require 'readline'
require 'pp'

require 'docx'
require "mongo"
include Mongo


require File.dirname(__FILE__)+"/class/mongo.class.rb" 
#require File.dirname(__FILE__)+"/class/timer.class.rb" 
#require File.dirname(__FILE__)+"/class/rocketio.class.rb" 
#require File.dirname(__FILE__)+"/class/logging.class.rb" 
require File.dirname(__FILE__)+"/class/google.class.rb" 
require File.dirname(__FILE__)+"/class/yaml.class.rb" 
#require File.dirname(__FILE__)+"/class/optparse.class.rb" 
require 'sentimental'

Sentimental.load_defaults
analyzer = Sentimental.new

#require_relative "lib/zip.rb" 


$configuration = Yamlconfig::load("config.yml")







db = MongoClient.new("localhost", 27017,  :pool_size =>45, :pool_timeout => 45).db("googlefiles")
coll = db.collection("students")






def putsHeader(stringr)
	print "\033[s\033[1A\033[1000D\033[K"
		puts stringr
	print "\033[u\033["
	print Readline.point + 2
	print "C"
	end

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i





Readline.completion_append_character = " "
Readline.completion_proc = Proc.new do |str|
Readline.completion_append_character = " "
	case Readline.line_buffer[0..Readline.point]

	when /^ .*/
		putsHeader "Remove that space"
		""
	when /^.* email.*/
		Readline.completion_append_character = ""
		emailaddress =  /^.* email (.*)/.match(Readline.line_buffer[0..Readline.point]).captures[0]
		putsHeader "Searching for #{emailaddress}"
		search = str
		return_emailaddress  = coll.find({"_id" =>/#{search}/ }, {:fields => ["_id"]})
		return_emailaddress.map {|a| a['_id'] }



		
	else
		['get','list','view','email','files','help'].grep(/^#{Regexp.escape(str)}/)
	end
 
end

##
##
##

while line = Readline.readline('> ', true)
	case line
	when /^help$/
		puts "####################################################################"
		puts "################       HELP                      ###################"
		puts "####################################################################"
		puts "Allowed Commands"
		print "  "
		 ['get','list','view','email','files','help'].each { |i|   print "#{i}, ";   } 
		 puts ""

	when /^e$/
		print "\033[s\033[1A\033[1000D\033[3C[xit]\033[u\033[1B\033[1000D"
		exit 130
	when /^exit$/
		exit 130
	when /^list email .* .*$/
		captures =  /^list email (.*) (.*)/.match(line).captures
		pp captures.count
		emailaddress = captures[0]
		amount = captures[1].to_i
		amount = 20 if amount == 0
	if 	( captures.count == 2 ) && (amount != 0)

		puts "## Custom Listing Emails for #{emailaddress}"
			person_object = GoogleAPI.new(emailaddress)
			puts "Total emails: #{person_object.total}"
			person_object.list_emails(amount).each do |listing|
				puts "[#{listing[0]}] #{listing[1]}"
			end
	end
	when /^list email [^-\s]*$/
		emailaddress =  /^list email (.*)/.match(line).captures[0]
		#pp emailaddress.class
		puts "## Listing Emails for #{emailaddress}"
			person_object = GoogleAPI.new(emailaddress)
			puts "Total emails: #{person_object.total}"
			person_object.list_emails(30).each do |listing|

				puts "[#{listing[0]}] #{listing[1]} [#{analyzer.get_sentiment listing[2]} #{analyzer.get_score listing[2]}]"
				#puts "[#{listing[02]}]"
			end


when /^get email [^-\s]* [^-\s]*/
		captures =  /^get email (.*) (.*)/.match(line).captures
		emailaddress = captures[0]
		emailid = captures[1]
		#pp emailaddress
		puts "## Get Email for #{emailaddress}"
			person_object = GoogleAPI.new(emailaddress)
			email =  person_object.email(emailid)
			puts email[1]
			puts email[2]

	else
		puts "## No Action"
		#puts line
	end

  
end

