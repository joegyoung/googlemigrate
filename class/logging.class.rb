




class MyLogging

    def initialize(name)
      @name = name
    	if $configuration["enable_websocket"]
      		@WebSocketIO = WebSocket_RocketIO.new(name)
      	end
     	@MongoFileLogger = LogRecords.new(name)
      @MongoFileAccount = FileAccount.new(name)
    end


def newwebsocket(channel)
  if $configuration["enable_websocket"]
    @WebSocketIO = WebSocket_RocketIO.new(@name,channel)
  end
end

def push(message)
	if $configuration["enable_websocket"] 
	  @WebSocketIO.send(message)
	end
end

  def log(user,level,event,status)
   @MongoFileLogger.add(user,level,event,status)
  end

  def file(id,emailaddress,orginalfiletype,title,version,filelocation)
    @MongoFileAccount.add(id,emailaddress,orginalfiletype,title,version,filelocation)
  end


  def dont_have_file(id,version)
     @MongoFileAccount.dont_have_file(id,version)
  end

 def file_check_for_current_location(id)
     @MongoFileAccount.current_location(id)
  end

 def file_counttotalforuser(emailaddress)
     @MongoFileAccount.counttotalforuser(emailaddress)
  end


end


