require 'docx'
require "mongo"
require "pp"

include Mongo



db = MongoClient.new("localhost", 27017,  :pool_size =>45, :pool_timeout => 45).db("googlefiles")
coll = db.collection("fileaccount")


begin
file  = coll.find({"_id" => ARGV[0] }).first
rescue
	puts "Not there"
	exit
end




begin

	# Retrieve and display paragraphs as html
	doc = Docx::Document.open( file["filelocation"] )

	puts "##"
	puts "##  #{file['filelocation']}"
	puts "##  #{file['emailaddress']}"
	puts "##  #{file['title']}"
	puts "##"


	doc.paragraphs.each do |p|
	  puts p
	end
	rescue
  		p 'I am rescuing an exception and can do what I want!'
end

