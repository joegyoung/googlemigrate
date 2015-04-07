


class GoogleRecords
  #attr_accessor :students, :db
  def initialize
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    @db = MongoClient.new(host, port,  :pool_size =>45, :pool_timeout => 45 ).db('googlefiles')
 
    @files = @db.collection('files')
    puts "startfiles"
    #@students.create_index("emailaddress", :unique => true)
   # students.ensureIndex({"emailaddress" => 1 }, {:unique => true })
  end

def add(what,amount)
    item =  (@files.find({'what' => what})).first
    if item == nil then 
      item = Array([{'what' => what,"amount" => amount}])
      @files.insert({'what' => what,"amount" => amount})

    else
      #newamount = item["amount"] + amount
       item["amount"] += amount
      @files.update({'what' => what},item)
    end
    puts item
  end

end

#n = GoogleRecords.new
#n.add("buttereee",333)

#exit;