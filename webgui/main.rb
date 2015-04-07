io = Sinatra::RocketIO

#require_relative "../class/mongo.class.rb" 

require 'mongo'
include Mongo
require 'erb'
require File.dirname(__FILE__)+"/../class/yaml.class.rb"


publicdir = File.dirname(__FILE__)+"/public"
configuration = Yamlconfig::load("../config.yml")
$hostname = configuration["website"]["host"]

##
##

    db = MongoClient.new("localhost", 27017, w: 1).db("googlefiles")

##





io.once :start do
  puts "RocketIO start!!!"
end

io.on :connect do |client|
  puts "new client  - #{client}"
  push :chat, {:name => "system", :message => "new #{client.type} client <#{client.session}>"}, :channel => client.channel
  push :chat, {:name => "system", :message => "welcome <#{client.session}>"}, :to => client.session
end

io.on :disconnect do |client|
  puts "disconnect client  - #{client}"
  push :chat, {:name => "system", :message => "bye <#{client.session}>"}, :channel => client.channel
end

io.on :chat do |data, client|
  puts "#{data['name']} : #{data['message']}  - #{client}"
  push :chat, data, :channel => client.channel
end

io.on :total do |data, client|
  puts "#{data['name']} : #{data['message']}  - #{client}"
  push :total, data, :channel => client.channel
end


io.on :error do |err|
  STDERR.puts "error!! #{err}"
end

get '/' do
    if request.host != $hostname
    redirect "http://#{$hostname}:5000/migrate/main"
  end
  redirect '/migrate/main'
end
get '/test' do
  if request.host != $hostname
    redirect "http://#{$hostname}:5000/migrate/main"
  end
  request.host
  #request.env.inspect
end

get '/image/filetype.png' do
        if request.host != $hostname
          redirect "http://#{$hostname}:5000/migrate/main"
        end

          coll = db.collection("fileaccount")

          content_type ' image/png'


          require 'gruff'
          g = Gruff::Bar.new
          g.title = 'Google Migration by File Types'
          g.labels = { 0 => 'count' }
          g.legend_font_size = 12;



          coll.aggregate([{"$group" => {_id: "$orginalfiletype", count: {"$sum" => 1 } }},{'$sort' => {'count' => -1 }}, { "$limit" => 10 }]).each do |itype|
            g.data itype['_id'], [itype['count']]
          end

g.to_blob()


end


get '/cvs' do
        if request.host != $hostname
          redirect "http://#{$hostname}:5000/migrate/main"
        end
      output = "<pre>"

    # db = MongoClient.new("localhost", 27017, w: 1).db("googlefiles")
          coll = db.collection("fileaccount")
      coll.aggregate([{"$group" => {_id: "$orginalfiletype", count: {"$sum" => 1 } }},{'$sort' => {'count' => -1 }}]).each do |itype|
        output << "#{itype['_id']},  #{itype['count']}\n"

      end
      output

end


get '/logs/warn/:amount' do
    coll = db.collection("logfiles")
    output = "<pre>"
    limit = params[:amount].to_i || 100
    output << "time,user,level,Event,status\n"
    item =  (coll.find({"level" => {"$ne" => "INFO"}},{:limit => limit ,:sort => ['time', Mongo::DESCENDING]})) 
    item.each do |log|
      output << "[#{log['time']}] #{log['user']}  #{log['level']}  #{log['event']} #{log['status']}\n"
    end
    output
end


get '/logs/warn' do
    coll = db.collection("logfiles")
    output = "<pre>"
    output << "time,user,level,Event,status\n"
    item =  (coll.find({"level" => {"$ne" => "INFO"}},{:limit => 400 ,:sort => ['time', Mongo::DESCENDING]})) 
    item.each do |log|
      output << "[#{log['time']}] #{log['user']}  #{log['level']}  #{log['event']} #{log['status']}\n"
    end
    output
end


get '/logs/:amount' do
    coll = db.collection("logfiles")
    output = "<pre>"
    output << "time,user,level,Event,status\n"
    limit = params[:amount].to_i || 100
    item =  (coll.find({},{:limit => limit ,:sort => ['time', Mongo::DESCENDING]})) 
    item.each do |log|
      output << "[#{log['time']}] #{log['user']}  #{log['level']}  #{log['event']} #{log['status']}\n"
    end
    output
end


get '/logs' do
    coll = db.collection("logfiles")
    output = "<pre>"
    output << "time,user,level,Event,status\n"
    item =  (coll.find({},{:limit => 100 ,:sort => ['time', Mongo::DESCENDING]})) 
    item.each do |log|
      output << "[#{log['time']}] #{log['user']}  #{log['level']}  #{log['event']} #{log['status']}\n"
    end
    output
end



get '/total/main' do
  test = Localuserrecords.new
  json :total => "#{test.countdone} / #{test.counttotal}"
end

get '/total/upload' do
  test = FileAccount.new("Check")
  json :total => "#{test.countdone} / #{test.counttotal}"
end


get '/migrate/:channel' do
  if request.host != $hostname
    redirect "http://#{$hostname}:5000/migrate/main"
  end
 case params[:channel]
  when "main"
    test = Localuserrecords.new
    @total = "#{test.countdone} / #{test.counttotal}"
  when "upload" 
    test = FileAccount.new("Check")
    @total = "#{test.countdone} / #{test.counttotal}"
    end
  @channel = params[:channel]
  #File.read(File.join(publicdir, 'chat.html'))

  @name = $hostname
  @hostname = $hostname
  erb :'chat.html'
end

get '/js/app.js' do
  content_type 'application/javascript'
  @hostname = $hostname
  erb :'app.js'
end

