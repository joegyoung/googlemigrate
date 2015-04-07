


class Localuserrecords
  attr_accessor :students, :db
  def initialize
  	host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    @db = MongoClient.new(host, port,  :pool_size =>45, :pool_timeout => 45 ).db('googlefiles')
 
    @students = @db.collection('students')
    puts "start"
    #@students.create_index("emailaddress", :unique => true)
   # students.ensureIndex({"emailaddress" => 1 }, {:unique => true })
  end


  def add(emailaddress)
  	@students.insert({'_id' => emailaddress,"lock" => false, "done" => false})

    rescue Mongo::OperationFailure => e
    if e.result['writeErrors'][0]['code'] == 11000
      puts "Duplicate key"
      #puts "Duplicate key error #{$!}"
      # do something to recover from duplicate
    else
      raise e
    end
  end


  def nextundone()
   item =  (@students.find({'done' => false,'lock' => false},{:sort => ['_id', Mongo::ASCENDING]})).first
   #item =  (@students.find({'done' => false,'lock' => false},{:sort => ['_id', Mongo::DESCENDING]})).first

  end

  def locknextundone()
   #item =  (@students.find({'done' => false,'lock' => false},{:sort => ['_id', Mongo::ASCENDING]})).first.update({}, {'$set' => { 'done' => true }})
  result =  @students.find_and_modify({'query'=>{'done' => false,'lock' => false},'sort'=>{'_id'=> Mongo::ASCENDING}, 'update'=>{'$set' => { 'lock' => true }}})
  
  begin
  item =  (@students.find({'_id' => result["_id"]})).first
  rescue
    $logging.push("<span style='red'>I am Done!!!!!</span>")
    puts "@@@@@ I am Done!!!!!"
    $logging.log("OWNER","INFO","STATE","I am Done!!!!!")
    timer.stop
    exit 
  end


   #item =  (@students.find({'done' => false,'lock' => false},{:sort => ['_id', Mongo::DESCENDING]})).first

  end




  def counttotal()
   item =  (@students.find({})).count

  end

  def countundone()
   item =  (@students.find({'done' => false})).count

  end

    def countdone()
   item =  (@students.find({'done' => true})).count

  end


  def edit(emailaddress,newitem)
   item =  (@students.find({'_id' => emailaddress})).first
   newnewitem =  item.merge(newitem)
  @students.update({'_id' => emailaddress},newnewitem)
  end


  def lock(emailaddress)
   item = Hash.new; item["lock"] = true
   edit(emailaddress,item)
  end
  def unlock(emailaddress)
   item = Hash.new; item["lock"] = false
   edit(emailaddress,item)
  end

def done(emailaddress)
   item = Hash.new; item["done"] = true
   edit(emailaddress,item)
end
def undone(emailaddress)
   item = Hash.new; item["done"] = false
   edit(emailaddress,item)
end


def unlockall()
  result =   @students.update({ }, {'$set' => { 'lock' => false }}, { :multi => 1 })
  puts result
end


def undoneall()
 result =  @students.update({}, {'$set' => { 'done' => false }}, { :multi => true })
 puts result
end



def reset()
 @students.remove({})
end



end  





