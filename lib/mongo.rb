require 'mongo'
include Mongo





host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT



#puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port,  :pool_size =>45, :pool_timeout => 45 ).db('googlefiles')
Students = db.collection('students')
Students.create_index("emailaddress")

def add_database(emailaddress)
  new_post = { :emailaddress => emailaddress, :lock => false, :done => false }
  post_id = Students.insert(new_post)
end




def in_database(emailaddress)
    record = Students.find({:emailaddress => emailaddress}).first.has_key?("emailaddress")
    record
end

def not_in_database(emailaddress)
    record = Students.find({:emailaddress => emailaddress}).first
    if record != nil
      puts "YES"
    record.has_key?("emailaddress")
    record = !record
    else
      true

    end
end