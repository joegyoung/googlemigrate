


class LogRecords
  attr_accessor :logfiles
  def initialize(logger)
    @logger = logger
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    @db = MongoClient.new(host, port,  :pool_size =>45, :pool_timeout => 45 ).db('googlefiles')
 
    @logfiles = @db.collection('logfiles')
    puts "start logfiles db"
    #@students.create_index("emailaddress", :unique => true)
   # students.ensureIndex({"emailaddress" => 1 }, {:unique => true })
  end

  def add(user,level,event,status)
    #puts "------------> status: #{status}"
    @logfiles.insert({'time' => Time.now ,'user' => user,"level" => level, "event" => event,"status" => status,"logger" => @logger})
    rescue Mongo::OperationFailure => e
    if e.result['writeErrors'][0]['code'] == 11000
      puts "Duplicate key"

    else
      raise e
    end
  end

 def count
   item =  (@logfiles.find({})).count

  end


  def listwarn(sort,amount)
  case sort
    when "DESCENDING"
      sort = Mongo::DESCENDING
    when "ASCENDING"
      sort = Mongo::ASCENDING
    else
      sort = Mongo::ASCENDING
    end
     item =  (@logfiles.find({"level" => {"$ne" => "INFO"}},{:limit => amount ,:sort => ['time', sort]})) 
     # ASCENDING
     # DESCENDING
  end

  def list(sort,amount)
  case sort
    when "DESCENDING"
      sort = Mongo::DESCENDING
    when "ASCENDING"
      sort = Mongo::ASCENDING
    else
      sort = Mongo::ASCENDING
    end
     item =  (@logfiles.find({},{:limit => amount ,:sort => ['time', sort]})) 
     # ASCENDING
     # DESCENDING
  end
end



#require 'mongo'
#include Mongo
#require 'pp'

#n = LogRecords.new("logger1")
#n.add("joe2@n.com","WARN","FILE","buttereee")
#n.list("ASCENDING").each do |e|
#  pp e
#end
#exit;

