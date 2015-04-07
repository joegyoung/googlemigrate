

class FileAccount
  #attr_accessor :students, :db
  attr_accessor :fileaccount
  def initialize(logger)
    @logger = logger
    host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
    port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
    @db = MongoClient.new(host, port,  :pool_size =>45, :pool_timeout => 45 ).db('googlefiles')
 
    @fileaccount = @db.collection('fileaccount')
    puts "start fileaccount db"

  end


  def add(id,emailaddress,orginalfiletype,title,version,filelocation)
      @fileaccount.insert({ '_id'=>id, 'emailaddress' => emailaddress,'orginalfiletype' => orginalfiletype,'title' => title,'version' => version,'filelocation' => filelocation ,"lock" => false, "done" => false,"logger"=>@logger})
     rescue Mongo::OperationFailure => e
    if e.result['writeErrors'][0]['code'] == 11000
     puts "Trying to edit"

    item =  (@fileaccount.find({'_id' => id})).first
   newnewitem =  item.merge({ '_id'=>id, 'emailaddress' => emailaddress,'orginalfiletype' => orginalfiletype,'title' => title,'version' => version,'filelocation' => filelocation ,"lock" => false, "done" => false,"logger"=>@logger})
    @fileaccount.update({'_id' => id},newnewitem)
    puts "Done"


    else
      raise e
    end


  end



   def dont_have_file(id,version)
      item =  (@fileaccount.find({'_id' => id,'version' => version},{:sort => ['_id', Mongo::ASCENDING]})).first
      if item 
        false
      else
        true
      end
    end


  def current_location(id)
      item =  (@fileaccount.find({'_id' => id},{:fields => ["filelocation"],:sort => ['_id', Mongo::ASCENDING]})).first
      if item
        item["filelocation"]
      else
        nil
      end
    end




    def nextundone()
      item =  (@fileaccount.find({'done' => false,'lock' => false},{:sort => ['_id', Mongo::ASCENDING]})).first
    end

       def nextundonebyemail(emailaddress)
      item =  (@fileaccount.find({'emailaddress' => emailaddress,'done' => false,'lock' => false},{:sort => ['_id', Mongo::ASCENDING]})).first
    end


def countundonebyemail(emailaddress)
   item =  (@fileaccount.find({'emailaddress' => emailaddress,'done' => false})).count

  end



    def locknextundoneold()
      result =  @fileaccount.find_and_modify({'query'=>{'done' => false,'lock' => false},'sort'=>{'_id'=> Mongo::ASCENDING}, 'update'=>{'$set' => { 'lock' => true }}})
      if result != nil
        item =  (@fileaccount.find({'_id' => result["_id"]})).first
      else
        nil
      end
    end






    def locknextundone()
    if @lastemailaddress 
      #puts "Saved email address: #{@lastemailaddress }"
      result =  @fileaccount.find_and_modify({'query'=>{'done' => false,'lock' => false,'emailaddress' => @lastemailaddress},'sort'=>{'_id'=> Mongo::ASCENDING}, 'update'=>{'$set' => { 'lock' => true }}})
      if result != nil
        #puts "There wasa result"
        item =  (@fileaccount.find({'_id' => result["_id"]})).first
        @lastemailaddress = item["emailaddress"]
        item
      else
        item = locknextundoneold()
        @lastemailaddress = item["emailaddress"]
        item
      end


    else
      #puts "Not last email"
      item = locknextundoneold()
      if item != nil
        @lastemailaddress = item["emailaddress"]
        item
      else
        nil
      end
    end
    end





  def counttotalforuser(emailaddress)
   item =  (@fileaccount.find({"emailaddress" => emailaddress })).count
  end




  def counttotal()
   item =  (@fileaccount.find({})).count
  end

  def countundone()
   item =  (@fileaccount.find({'done' => false})).count

  end

    def countdone()
   item =  (@fileaccount.find({'done' => true})).count

  end


  def edit(id,newitem)
   item =  (@fileaccount.find({'_id' => id})).first
   newnewitem =  item.merge(newitem)
    @fileaccount.update({'_id' => id},newnewitem)
  end


  def lock(id)
   item = Hash.new; item["lock"] = true
   edit(id,item)
  end
  def unlock(id)
   item = Hash.new; item["lock"] = false
   edit(id,item)
  end

def done(id)
   item = Hash.new; item["done"] = true
   edit(id,item)
end
def undone(id)
   item = Hash.new; item["done"] = false
   edit(id,item)
end


def unlockall()
  result =   @fileaccount.update({ }, {'$set' => { 'lock' => false }}, { :multi => 1 })
  puts result
end


def undoneall()
 result =  @fileaccount.update({}, {'$set' => { 'done' => false }}, { :multi => true })
 puts result
end

def undoneallbyemail(emailaddress)
 result =  @fileaccount.update({"emailaddress" => emailaddress }, {'$set' => { 'done' => false }}, { :multi => true })
 puts result
end



def reset()
 @fileaccount.remove({})
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


     item =  (@fileaccount.find({},{:limit => amount ,:sort => ['filelocation', sort]})) 
     # ASCENDING
     # DESCENDING
  end



end

