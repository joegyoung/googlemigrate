#!/usr/bin/env ruby
# Encoding: utf-8

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

class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end

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







$listofFiles = FileAccount.new(name)



##
##
##






def uploadthefilesfor( theemailaddress )


$listofFiles = FileAccount.new("name")
timeremail = Timer.new()
#theemailaddress = "<emailaddress>"

#pp theemailaddress

totalnumber = $listofFiles.fileaccount.find({"emailaddress"=> theemailaddress}).count
mongo_notdonecount = $listofFiles.fileaccount.find({"emailaddress" => theemailaddress,"done" => false}).count()
#pp totalnumber
#pp $listofFiles.countundonebyemail( theemailaddress )
workingnumber = 1




begin
    onefile =  $listofFiles.nextundonebyemail( theemailaddress )
    if onefile
    email = onefile['emailaddress'];
    puts "[#{workingnumber}/#{mongo_notdonecount}] #{email} #{onefile['title']}, #{onefile['orginalfiletype']}, #{onefile['filelocation']}"
    file = GoogleFileAPI.new([ theemailaddress ])
    uploaded = file.insert_o(onefile['title'], "description", onefile['orginalfiletype'], onefile['filelocation'])
    $logging.push("[#{workingnumber}/#{mongo_notdonecount}] #{email} #{onefile['title']}, #{onefile['orginalfiletype']}")


    $listofFiles.done(onefile['_id'])
    $listofFiles.unlock(onefile['_id'])
    end
    workingnumber += 1
end while $listofFiles.countundonebyemail( theemailaddress ) != 0 
timeremail.stop
end


File.open('report.txt', 'w') { |file| 


listofstudents = $listofFiles.fileaccount.aggregate([{"$group" => {_id: "$emailaddress", count: { "$sum" => 1 }}},{ "$sort" => { "_id" => 1 }}])


skipnumber = ( listofstudents.index{ |x| x['_id'] == "<emailaddress>"} ) + 1




listofstudents.drop(skipnumber ).each do |obj|
 ## uploadthefilesfor( line.delete!("\n") )

emailaddress = obj['_id']

student  =  GoogleAPI.new( emailaddress  )
googlecount = student.filecount(q="")
mongo_donecount = $listofFiles.fileaccount.find({"emailaddress" => emailaddress,"done" => true}).count()
mongo_totalcount = $listofFiles.fileaccount.find({"emailaddress" => emailaddress}).count()
puts "#{emailaddress} G[#{googlecount}] T[#{mongo_totalcount}] D[#{mongo_donecount}]"

$logging.push("#{emailaddress} G[#{googlecount}] T[#{mongo_totalcount}] D[#{mongo_donecount}]")



 if googlecount >= mongo_totalcount && mongo_donecount != mongo_totalcount
      puts "UPDATING"
      #pp $listofFiles.fileaccount.update({'emailaddress' => emailaddress}, {"$set" => {"done" => true}}, {:multi => true })

elsif googlecount < mongo_totalcount && googlecount.percent_of(mongo_totalcount) < 90
  puts googlecount.percent_of(mongo_totalcount)
  puts "UPLOADING"
  file.write("UPLOADING - #{emailaddress} G[#{googlecount}] T[#{mongo_totalcount}] D[#{mongo_donecount}]\n") 
  $listofFiles.undoneallbyemail(emailaddress)
  uploadthefilesfor( emailaddress )
    end







end


}

timer.stop


